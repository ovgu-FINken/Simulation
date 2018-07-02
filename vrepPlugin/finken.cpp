#include "finken.h"
#include <iostream>
#include "v_repLib.h"
#include <cstring>
#include <cstdlib>
#include "vrepplugin.h"
#include <fstream>
#include "dataPacket.h"
#include <boost/archive/binary_oarchive.hpp>
#include <boost/archive/binary_iarchive.hpp>
#include <boost/filesystem.hpp>
#include <boost/filesystem/fstream.hpp>
#include <boost/asio.hpp>
#include <chrono>

ofstream csvdata;

using std::endl;
using std::ostream;
using boost::filesystem::ofstream;
using boost::filesystem::current_path;
using boost::asio::ip::tcp;
using Clock = std::chrono::high_resolution_clock;

/** Throttlevalues for the motors built into the FINken */
std::array<double,6> throttlevalues = {0, 0.5, 0.65, 0.75, 0.85, 1};
/** Thrust values in Newton coressponding to the trottle values */
std::array<double,6> thrustvalues = {0, 0.92,1.13,1.44,1.77,2.03};

static int kFinkenSonarCount = 4;
static int kFinkenHeightSensorCount = 1;
std::atomic<bool> sendSync(false);
std::atomic<bool> readSync(false);
vrepPacket outPacket;
paparazziPacket inPacket;
/*
struct ecef_coords {
    float x = 3862.7;
    float y = 750.8;
    float z = 5002.8;
}ecef;
struct lla_coords {
    float lat = 52;
    float lon = 11;
    float height = 50;
}lla;
*/

Finken::Finken(){}
Finken::Finken(int fHandle, int _ac_id) : handle(fHandle), ac_id(_ac_id){}
Finken::~Finken(){
    vrepLog << "deleting finken with id: " << this->handle <<std::endl;
    simCopters.emplace_back(std::make_pair(this->ac_id, this->handle));
    simStopSimulation();
    simAdvanceSimulationByOneStep();
}

void Finken::addSensor(std::unique_ptr<Sensor> &sensor){
    this->sensors.push_back(std::move(sensor));
    vrepLog << "Adding sensor to finken" << '\n';
}
void Finken::addRotor(std::unique_ptr<Rotor> &rotor){
    vrepLog << "Adding rotor with name" << simGetObjectName(rotor->handle) << '\n';
    this->rotors.push_back((std::move(rotor)));
}

std::vector<std::unique_ptr<Sensor>> &Finken::getSensors(){
    return this->sensors;
}
std::vector<std::unique_ptr<Rotor>> &Finken::getRotors(){
    return this->rotors;
}

void Finken::run(std::unique_ptr<tcp::iostream> sPtr){
  auto runStart = Clock::now();
    try {
        vrepLog << "[FINK] client connected" << std::endl;
	int simState = simGetSimulationState();
	vrepLog << "[FINK] simulation state: " << simState << std::endl;
	if (simState == 0 || simState == 1) {
		simStartSimulation();
	}
	std::this_thread::sleep_for(std::chrono::milliseconds(1000));
	//first connection:
	vrepLog << "[FINK] checking for copter id in simCopters" << std::endl;
    csvdata.open("log.csv");
    csvdata << "TIME,NE,SE,SW,NW,Quat.x,Quat.y,Quat.z,Quat.w" << "\n";

    int copter_id = simCopters.back().second;
        size_t id;
        int connection_nb =1;
        int commands_nb = 4;
	    vrepLog << "[FINK] first connection" << std::endl;
        //read commands
	    {
            boost::archive::binary_iarchive in(*sPtr);
            in >> inPacket;
            this->ac_id = inPacket.ac_id;
	    	this->commands[0]=inPacket.pitch;
	    	this->commands[1]=inPacket.roll;
	    	this->commands[2]=inPacket.yaw;
	    	this->commands[3]=inPacket.thrust;
            csvdata << simGetSimulationTime() << ",";
            for(int i=0;i<commands_nb;i++) {
                vrepLog << commands[i] << ((i==commands_nb-1)?"":", ");
                csvdata << commands[i] << ((i==commands_nb-1)?",":",");
            }

        }
    	/*
         *check for existence of a free(not associated with a paparazzi client yet) copter
         *with correct id and build it, then remove that id from uncoupled copters 
         */
        if(simCopters.size() > 0) {
            for(auto it = simCopters.begin(); it!=simCopters.end();it++){
                if(it->first==this->ac_id){
                    vrepLog << "[FINK] copter with correct id " << this->ac_id << " found" << std::endl;
		            buildFinken(*this, it->second);
		            vrepLog << "[FINK] building finken with id " << it->second << std::endl;
                    simCopters.erase(it);
                    vrepLog << "[FINK] simcopters size: " << simCopters.size() << std::endl;
                    vrepLog << "[FINK] recieved: " << inPacket.pitch << " | " << inPacket.roll << " | " << inPacket.yaw << " | " << inPacket.thrust << std::endl;
                    break;
                }
                else if(it == simCopters.end()-1){
                    //no copter with the given id present, rip
                    vrepLog << "[FINK] no copter with id " << this->ac_id << " found, terminating connection" << std::endl;
                    sPtr.get()->close();
                    return;
                }
            }
        }
        else {
            //no copter available at all, rip
            vrepLog << "[FINK] no finken available, terminating connection" << std::endl;
            sPtr.get()->close();
            return;
        }
        readSync = true;
        while (!sendSync.load()){
            //wait for vrep to actually apply the motor forces
            std::this_thread::sleep_for(std::chrono::milliseconds(1));
        }                         
        sendSync = false;

        //update position
        updatePos(*this);
        
        //send initial position packet
        {
    		boost::archive::binary_oarchive out(*sPtr);   	       
		    outPacket.pos = this->pos;
            outPacket.quat = this->quat;
            outPacket.vel = this->vel;
            outPacket.rotVel = this->rotVel;
            outPacket.accel = this->accel;
            outPacket.rotAccel = this->rotAccel;
            outPacket.dt = simGetSimulationTimeStep();
            outPacket.simTime = simGetSimulationTime();
   	    	out << outPacket;
        }
        csvdata << std::to_string(this->quat[0]) << "," << std::to_string(this->quat[1]) << "," << std::to_string(this->quat[2]) << "," << std::to_string(this->quat[3]) << std::endl;
        /*
         *paparazzi-vrep loop
         */
	    for (;;){
            auto runStart = Clock::now();
            auto then = Clock::now();
            int commands_nb = 0;
            //receive data:
            vrepLog << "[FINK] connection:" << connection_nb++ << std::endl;
            boost::archive::binary_iarchive in(*sPtr);
            in >> inPacket;
            this->commands[0]=inPacket.pitch;
	    this->commands[1]=inPacket.roll;
	    this->commands[3]=inPacket.yaw;
	    this->commands[2]=inPacket.thrust;
	    vrepLog << "[FINK] recieved: " << inPacket.pitch << " | " << inPacket.roll << " | " << inPacket.yaw << " | " << inPacket.thrust << std::endl << std::endl;
            auto now = Clock::now();
            vrepLog << "[FINK] time receiving data: " << std::chrono::nanoseconds(now-then).count()/1000000 << "ms" << std::endl;
            
            //vrep sim loop
            then = Clock::now();
            readSync = true;
            while (!sendSync.load()){
                //wait for vrep to actually apply the motor forces
                std::this_thread::sleep_for(std::chrono::milliseconds(1));
            }
            now = Clock::now();
            vrepLog << "[FINK] time finken is waiting for vrep: " << std::chrono::nanoseconds(now-then).count()/1000000 << "ms" << std::endl << std::endl;

            then = Clock::now();
            sendSync = false;
            updatePos(*this);
       	    //send position data
            boost::archive::binary_oarchive out(*sPtr);
            outPacket.pos = this->pos;
            outPacket.quat = this->quat;
            outPacket.vel = this->vel;
            outPacket.rotVel = this->rotVel;
            outPacket.accel = this->accel;
            outPacket.rotAccel = this->rotAccel;
            outPacket.simTime = simGetSimulationTime();

            vrepLog << "[FINK] sending position/attitude data: "<< std::endl
            << "time: " << outPacket.simTime << std::endl 
            << "pos: " << outPacket.pos[0] << " | "  << outPacket.pos[1] << " | " << outPacket.pos[2] << std::endl
            << "quat-xyzw: " << outPacket.quat[0] << " | "  << outPacket.quat[1] << " | " << outPacket.quat[2] << " | " << outPacket.quat[3] << std::endl
            << "vel: " << outPacket.vel[0] << " | "  << outPacket.vel[1] << " | " << outPacket.vel[2] << std::endl
            << "rotVel: " << outPacket.rotVel[0] << " | "  << outPacket.rotVel[1] << " | " << outPacket.rotVel[2] << std::endl
            << "accel: " << outPacket.accel[0] << " | "  << outPacket.accel[1] << " | " << outPacket.accel[2] << std::endl
            << "rotAccel: " << outPacket.rotAccel[0] << " | "  << outPacket.rotAccel[1] << " | " << outPacket.rotAccel[2] << std::endl << std::endl;
	    out << outPacket;

            now = Clock::now();
            vrepLog << "[FINK] time sending data: " << std::chrono::nanoseconds(now-then).count()/1000000 << "ms" << std::endl;
            auto runEnd = Clock::now();
            vrepLog << "[FINK] time total Finken::run() loop: " << std::chrono::nanoseconds(runEnd - runStart).count()/1000000 << "ms" << std::endl << "-------------------------------------------------------------------" << std::endl;;
            csvdata << simGetSimulationTime() << ",";
            for(int i=0;i<commands_nb;i++) {
                csvdata << commands[i] << ((i==commands_nb-1)?",":",");
            }

            csvdata << std::to_string(this->quat[0]) << "," << std::to_string(this->quat[1]) << "," << std::to_string(this->quat[2]) << "," << std::to_string(this->quat[3]) << std::endl;

        }
    }
  	catch (std::exception& e) {
	    std::cerr << "Exception in thread: " << e.what() << "\n";
	    std::cerr << "Error Message: " << sPtr->error().message() << std::endl;
            std::cerr << "cleaning up... " << std::endl;
            sPtr.reset();
            std::cerr <<  "cleanup finished, stopping sim" << std::endl;
	    simStopSimulation();
    	    simAdvanceSimulationByOneStep();

	}
}

/*
 *Takes a unique_ptr to a Finken and adds
 *the correct handles for the sensors & rotors
 *
 */
void buildFinken(Finken& finken, int fHandle){
    vrepLog << "[FINK] building finken" << std::endl;

    finken.handle = fHandle;
    finken.baseHandle = fHandle;
    int foundSensorCount = 0, foundBaseCount = 0;

    
    //Grab all Proximity sensors and add them to the finken:
    int* baseHandles = simGetObjectsInTree(fHandle, sim_object_dummy_type, 1, &foundBaseCount);
    
    for(unsigned int i=0;i<foundBaseCount;i++) {
      char* dummyNameTemp = simGetObjectName(baseHandles[i]);
      std::string dummyName  = dummyNameTemp;
      simReleaseBuffer(dummyNameTemp);
      ssize_t endPos = dummyName.rfind('#');
      vrepLog  << "Found dummy element with name: "  << dummyName << endl;
      if(dummyName.substr(0, endPos)=="SimFinken_base") {
        finken.baseHandle=baseHandles[i];
        vrepLog  << "Found copter base with handle: "  << finken.baseHandle  << endl;
        break;
      }
    }
    //create positionsensor and add to the finken:
    std::unique_ptr<Sensor> posSensor(new PositionSensor (finken.baseHandle));
    finken.addSensor(posSensor);

    
    int* proxSensorHandles = simGetObjectsInTree(fHandle, sim_object_proximitysensor_type, 1, &foundSensorCount);
    for(int i = 0; i<foundSensorCount; i++){
        //we have kFinkenSonarCount sonars:
        if(i < kFinkenSonarCount){
            std::unique_ptr<Sensor> ps(new Sonar (proxSensorHandles[i]));
            finken.addSensor(ps);
        }
        //the rest are HeightSensors:
        else {
            std::unique_ptr<Sensor> hs(new HeightSensor(proxSensorHandles[i]));
            finken.addSensor(hs);
        }

    }
    
   
    //Grab all Rotors and add them to the finken:

    for(int i = 1; i<5; i++){
        int rHandle = simGetObjectHandle(("SimFinken_rotor_respondable" + std::to_string(i)).c_str());
        std::unique_ptr<Rotor> vr(new Rotor(rHandle));
        finken.addRotor(vr);
    }
    simReleaseBuffer((char *) proxSensorHandles);
    simReleaseBuffer((char *) baseHandles);
}


void Finken::updatePos(Finken& finken) {
    std::vector<float> tempquat = {0,0,0,0};
    std::vector<float> temp = {0,0,0};
    std::vector<float> temp2 = {0,0,0};
    std::vector<float> oldVel = {0,0,0};
    std::vector<float> oldRotVel ={0,0,0};
    if(finken.getSensors().at(0)->get(temp) >0) {
        finken.pos[0] = temp[0];
        finken.pos[1] = temp[1];
        finken.pos[2] = temp[2];
    }
    else {
      simAddStatusbarMessage("Error retrieveing Finken Base Position");
      vrepLog << "[FINK] Error retrieveing Finken Base Position. Handle:" << finken.handle << std::endl;
    }
    if(simGetObjectQuaternion(finken.baseHandle, -1, &tempquat[0]) > 0) {
        //returns quat as x,y,z,w
        finken.quat[0] = tempquat[0];
        finken.quat[1] = tempquat[1];
        finken.quat[2] = tempquat[2];
        finken.quat[3] = tempquat[3];
    }
    else {
      simAddStatusbarMessage("error retrieveing Finken Base Orientation");
    }

    if(simGetObjectVelocity(finken.baseHandle, &temp[0], &temp2[0]) > 0) {
        finken.vel[0] = temp[0];
        finken.vel[1] = temp[1];
        finken.vel[2] = temp[2];
        finken.rotVel[0] = temp[0];
        finken.rotVel[1] = temp[1];
        finken.rotVel[2] = temp[2];
        std::transform(finken.vel.begin(), finken.vel.end(), oldVel.begin(), finken.accel.begin(),
            [](double a, double b) {return (a-b)/simGetSimulationTimeStep();});
        std::transform(finken.rotVel.begin(), finken.rotVel.end(), oldRotVel.begin(), finken.rotAccel.begin(),
            [](double a, double b) {return (a-b)/simGetSimulationTimeStep();});
        oldVel = temp;
        oldRotVel = temp2;
    }
    else {
        simAddStatusbarMessage("error retrieving finken velocity");
    }



}

/*
void ecef_from_enu(Eigen::Vector3f& ecef_coord, Eigen::Vector3f& enu_coord) {
    Eigen::Matrix<float, 3, 3> cMatrix;

    cMatrix << -sin(lla.lon), -sin(lla.lat)*cos(lla.lon), cos(lla.lat)*cos(lla.lon),
                cos(lla.lon), -sin(lla.lat)*sin(lla.lon), cos(lla.lat)*sin(lla.lon),
                -1,             cos(lla.lat),              sin(lla.lat);

    Eigen::Vector3f ecef_base(ecef.x, ecef.y, ecef.z);

    ecef_coord = cMatrix * enu_coord + ecef_base;
}
*/


/*
void remove_item(int id) {
    vec.erase(std::remove_if(
        vec.begin(), vec.end(), [id](const std::unique_ptr<item>& e)
                                    {   return id == e->id; })
        ,vec.end());
}
*/

double thrustFromThrottle(double throttle) {
    if (throttle <= 0) return 0;
    else if (throttle ==1) return 2.03;
    for(int i = 0; i<throttlevalues.size(); i++){
        if(throttle == throttlevalues[i]) return thrustvalues[i];
        else if (throttle < throttlevalues[i]){
            // y = y_1 + (x-x_1)*(y_2-y_2)/(x_2-x_1)
            return(thrustvalues.at(i-1)+((thrustvalues.at(i)-thrustvalues.at(i-1))/(throttlevalues.at(i)-throttlevalues.at(i-1)))*(throttle-throttlevalues.at(i-1)));         
        }
    }
    std::cerr << "invalid throttle value (>100%): " << throttle <<std::endl;
    return 0;
}

void Finken::setRotorSpeeds() {
    Eigen::Vector4f motorCommands(this->commands[0], this->commands[1], this->commands[2], this->commands[3]);
    motorCommands[0]=thrustFromThrottle(motorCommands[0]);
    motorCommands[1]=thrustFromThrottle(motorCommands[1]);
    motorCommands[2]=thrustFromThrottle(motorCommands[2]);
    motorCommands[3]=thrustFromThrottle(motorCommands[3]);

    //pprz: [NE, SE, SW, NW]
    std::vector<float> motorNW  = {0, 0, motorCommands[3]};
    std::vector<float> motorNE = {0, 0, motorCommands[0]};
    std::vector<float> motorSE   = {0, 0, motorCommands[1]};
    std::vector<float> motorSW  = {0, 0, motorCommands[2]};
    std::vector<float> vtorque = {0,0,0};
    std::vector<std::vector<float>> motorForces= {motorNW, motorNE, motorSW, motorSE};
    Eigen::Quaternionf rotorQuat;
    
    for (int i=0; i<4; i++) {
        simGetObjectQuaternion(this->getRotors().at(i)->handle, -1, &rotorQuat.x());
        vrepLog << "[FINK] Rotor #" << i << " Quaternion-xyzw: " << rotorQuat.x() << " | "  << rotorQuat.y() << " | " << rotorQuat.z() << " | " << rotorQuat.w() << std::endl;
        Eigen::Vector3f force(motorForces.at(i).data());
        //Eigen::Vector3f force(0,0,0); //for testing
        force = rotorQuat * force;
        vrepLog << "[FINK] Rotor #" << i << " force: " << force[0] << " | "  << force[1] << " | " << force[2] <<  std::endl;
        std::vector<float> simForce(&force[0], force.data() + force.rows() * force.cols());
        vrepLog << "[FINK] adding force to rotor " << i << ": " << simForce[0] << " | " << simForce[1] << " | " << simForce[2] << std::endl;
    
        this->getRotors().at(i)->set(simForce, vtorque);
        
    }


}
