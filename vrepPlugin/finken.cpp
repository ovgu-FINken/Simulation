/** 
 * @file finken.cpp 
 * \class Finken
 * \brief implementation of a Finken rotorcraft, includes communication loop.
 */
#include "finken.h"
#include <iostream>
#include <cstring>
#include <cstdlib>
#include "vrepplugin.h"
#include <fstream>
#include <boost/filesystem.hpp>
#include <boost/filesystem/fstream.hpp>
#include <boost/asio.hpp>
#include <chrono>
#include <mutex>
#include <ctime>
#include <cstdint>
#include <boost/random.hpp>

ofstream csvdata;

using std::endl;
using std::ostream;
using boost::filesystem::ofstream;
using boost::filesystem::current_path;
using boost::asio::ip::tcp;
using Clock = std::chrono::high_resolution_clock;
int curBlock, nav_block;
/** Throttlevalues for the motors built into the FINken */
std::array<double,6> throttlevalues = {0, 0.5, 0.65, 0.75, 0.85, 1};
/** Thrust values in Newton coressponding to the trottle values */
std::array<double,6> thrustvalues = {0, 0.92,1.13,1.44,1.77,2.03};

Sync readSync;
std::mutex readMutex, sendMutex, syncMutex;
std::condition_variable cv_read, cv_send;
bool readyToSend;

vrepPacket outPacket;
paparazziPacket inPacket;

std::string vrepHome=std::getenv("VREP_HOME");




Finken::Finken(int fHandle, int _ac_id, int _rotorCount, int _sonarCount, std::string _ac_name) : handle(fHandle), ac_id(_ac_id), rotorCount(_rotorCount), sonarCount(_sonarCount) {
    ac_name = _ac_name;
}

void Finken::addSonar(std::unique_ptr<Sensor> &sensor){
    this->sonars.emplace_back(std::move(sensor));
    vrepLog << "Adding sonar to finken" << '\n';
}
void Finken::addRotor(std::unique_ptr<Rotor> &rotor){
    vrepLog << "Adding rotor with name" << simGetObjectName(rotor->handle) << '\n';
    this->rotors.push_back((std::move(rotor)));
}


std::vector<std::unique_ptr<Sensor>> &Finken::getSonars(){
    return this->sonars;
}
std::vector<std::unique_ptr<Rotor>> &Finken::getRotors(){
    return this->rotors;
}

void Finken::run(std::unique_ptr<tcp::iostream> sPtr){
    auto runStart = Clock::now();
    try {
        this->syncID = readSync.extend();
        vrepLog << "[FINK] client connected" << std::endl;
	    int simState = simGetSimulationState();
	    vrepLog << "[FINK] simulation state: " << simState << std::endl;
	    
		simStartSimulation();
	    
        buildFinken(*this);
        std::this_thread::sleep_for(std::chrono::milliseconds(1000));
        //first connection:
        int connection_nb =1;
        int commands_nb = 4;
        vrepLog << "[FINK] first connection" << std::endl;
        //read commands
        sPtr->flush();
        {               
            boost::archive::binary_iarchive in(*sPtr,boost::archive::no_header);
            in >> inPacket;
        }
        this->commands[0]=inPacket.pitch;
        this->commands[1]=inPacket.roll;
        this->commands[2]=inPacket.yaw;
        this->commands[3]=inPacket.thrust;
        nav_block = inPacket.block_ID;
        curBlock = nav_block;
        std::cout << "setting block to " << std::to_string(nav_block) << std::endl;
        csvdata.open((vrepHome + "/vreplogs/navBlock" + std::to_string(nav_block) + ".csv").c_str());
        csvdata << "TIME,NE,SE,SW,NW,Quat.x,Quat.y,Quat.z,Quat.w,EAST,NORTH,UP" << "\n";
        csvdata << simGetSimulationTime() << ",";
        for(int i=0;i<commands_nb;i++) {
            vrepLog << commands[i] << ((i==commands_nb-1)?"":", ");
            csvdata << commands[i] << ((i==commands_nb-1)?",":",");
        }
        std::cout << "[FINK] first connection successfully read" << std::endl;
        
        

        readSync.set(this->syncID);
        cv_read.notify_all();
        {
            std::unique_lock<std::mutex> lck(sendMutex);
            if(cv_send.wait_for(lck, std::chrono::seconds(5), [](){return readyToSend;})){
            //all good, vrep done calculating
            }
            else{
                throw std::runtime_error("Finken waiting for more than 5 seconds");
            }
        }
        //update position
        updatePos(*this);
        

        //send initial position packet
        {
            boost::archive::binary_oarchive out(*sPtr, boost::archive::no_header);
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

        csvdata << this->quat[0] << "," << this->quat[1] << "," << this->quat[2] << "," << this->quat[3] << "," << this->pos[0] <<"," << this->pos[1] << "," << this->pos[2] << "\n";
        /*
            *paparazzi-vrep loop
            */
        for (;;){
            auto then = Clock::now();
            int commands_nb = 4;
            //receive data:
            vrepLog << "[FINK] connection:" << connection_nb++ << std::endl;
            {
                boost::archive::binary_iarchive in(*sPtr, boost::archive::no_header);
                in >> inPacket;
            }

            this->commands[0]=inPacket.pitch;
            this->commands[1]=inPacket.roll;
            this->commands[2]=inPacket.yaw;
            this->commands[3]=inPacket.thrust;
            nav_block=inPacket.block_ID;
            if (curBlock != nav_block) {
                curBlock = nav_block;
                std::cout << "switching block to " << std::to_string(nav_block) << std::endl;
                csvdata.close();
                csvdata.open((vrepHome + "/vreplogs/navBlock" + std::to_string(nav_block) + ".csv").c_str());
                csvdata << "TIME,NE,SE,SW,NW,Quat.x,Quat.y,Quat.z,Quat.w,EAST,NORTH,UP" << "\n";
            }
            vrepLog << "[FINK] recieved: " << inPacket.pitch << " | " << inPacket.roll << " | " << inPacket.yaw << " | " << inPacket.thrust << std::endl << std::endl;
            auto now = Clock::now();
            vrepLog << "[FINK] time receiving data: " << std::chrono::nanoseconds(now-then).count()/1000000 << "ms" << std::endl;

            //vrep sim loop
            then = Clock::now();
            readSync.set(this->syncID);
            cv_read.notify_all();
            now = Clock::now();
            vrepLog << "[FINK] time finken is waiting for vrep: " << std::chrono::nanoseconds(now-then).count()/1000000 << "ms" << std::endl << std::endl;
            then = Clock::now();
            {
                std::unique_lock<std::mutex> lck(sendMutex);
                if(cv_send.wait_for(lck, std::chrono::seconds(5), [](){return readyToSend;})){
                    //all good, vrep done calculating
                }            
                else{
                    throw std::runtime_error("Finken waiting for more than 5 seconds");
                }
            }
            updatePos(*this);
            //send position data
            {
                boost::archive::binary_oarchive out(*sPtr, boost::archive::no_header);
                outPacket.pos = this->pos;
                outPacket.quat = this->quat;
                outPacket.vel = this->vel;
                outPacket.rotVel = this->rotVel;
                outPacket.accel = this->accel;
                outPacket.rotAccel = this->rotAccel;
                outPacket.simTime = simGetSimulationTime();
                out << outPacket;
            }


            vrepLog << "[FINK] sending position/attitude data: "<< std::endl
            << "time: " << outPacket.simTime << std::endl
            << "pos: " << outPacket.pos[0] << " | "  << outPacket.pos[1] << " | " << outPacket.pos[2] << std::endl
            << "quat-xyzw: " << outPacket.quat[0] << " | "  << outPacket.quat[1] << " | " << outPacket.quat[2] << " | " << outPacket.quat[3] << std::endl
            << "vel: " << outPacket.vel[0] << " | "  << outPacket.vel[1] << " | " << outPacket.vel[2] << std::endl
            << "rotVel: " << outPacket.rotVel[0] << " | "  << outPacket.rotVel[1] << " | " << outPacket.rotVel[2] << std::endl
            << "accel: " << outPacket.accel[0] << " | "  << outPacket.accel[1] << " | " << outPacket.accel[2] << std::endl
            << "rotAccel: " << outPacket.rotAccel[0] << " | "  << outPacket.rotAccel[1] << " | " << outPacket.rotAccel[2] << std::endl << std::endl;
            

            now = Clock::now();
            vrepLog << "[FINK] time sending data: " << std::chrono::nanoseconds(now-then).count()/1000000 << "ms" << std::endl;
            auto runEnd = Clock::now();
            vrepLog << "[FINK] time total Finken::run() loop: " << std::chrono::nanoseconds(runEnd - runStart).count()/1000000 << "ms" << std::endl << "-------------------------------------------------------------------" << std::endl;;
            csvdata << simGetSimulationTime() << ",";
            for(int i=0;i<commands_nb;i++) {
                csvdata << commands[i] << ((i==commands_nb-1)?",":",");
            }

            csvdata << this->quat[0] << "," << this->quat[1] << "," << this->quat[2] << "," << this->quat[3] << ", " <<  this->pos[0] <<"," << this->pos[1] << "," << this->pos[2] << std::endl;

        }
    }
  	catch (std::exception& e) {
	    std::cerr << "Exception in thread: " << e.what() << "\n";
	    std::cerr << "Error Message: " << sPtr->error().message() << std::endl;
        vrepLog << "[FINK] Exception in thread: " << e.what() << "\n";
        std::cerr << "cleaning up... " << std::endl;
        sPtr->close();
        sPtr.reset();
        connected=0;
        std::cerr <<  "cleanup finished, stopping sim" << std::endl;
      //simAddStatusbarMessage("stopping sim from finken::run");
	    //simStopSimulation();
    	//simAdvanceSimulationByOneStep();

	}
}

/*
 *Takes a unique_ptr to a Finken and adds
 *the correct handles for the sensors & rotors
 *
 */
void buildFinken(Finken& finken){
    double sigma = 0.2; //TODO: sensor registration via vrep so sigma can be set indivdually for each sensor from the GUI
    vrepLog << "[FINK] building finken" << std::endl;
    std::time_t now = std::time(0);
    finken.gen = boost::random::mt19937{static_cast<std::uint32_t>(now)};
    int foundSensorCount = 0, foundBaseCount = 0;

    //get the baseHandle which is used for attitude calculations
    int* baseHandles = simGetObjectsInTree(finken.handle, sim_object_dummy_type, 1, &foundBaseCount);    
    for(int i=0;i<foundBaseCount;i++) {
      char* dummyNameTemp = simGetObjectName(baseHandles[i]);
      std::string dummyName  = dummyNameTemp;
      simReleaseBuffer(dummyNameTemp);
      ssize_t endPos = dummyName.rfind('#');
      vrepLog  << "[FINK] Found dummy element with name: "  << dummyName << endl;
      if(dummyName.substr(0, endPos)=="SimFinken_base") {
        finken.baseHandle=baseHandles[i];
        vrepLog  << "[FINK]Found copter base with handle: "  << finken.baseHandle  << endl;
        break;
      }
    }
    //create positionsensor and add to the finken:
    finken.positionSensor.reset(new PositionSensor (finken.baseHandle, sigma, finken.gen));
    int* proxSensorHandles = simGetObjectsInTree(finken.handle, sim_object_proximitysensor_type, 1, &foundSensorCount);
    for(int i = 0; i<foundSensorCount; i++){
        //we have sonarCount sonars:
        if(i < finken.sonarCount){
            std::unique_ptr<Sensor> ps(new Sonar (proxSensorHandles[i]));
            finken.addSonar(ps);
        }    
    }
    
    finken.heightSensor.reset(new HeightSensor(finken.baseHandle, sigma, finken.gen));
    //Grab all Rotors and add them to the finken:

    for(int i = 0; i<finken.rotorCount; i++){
        int rHandle = simGetObjectHandle(("SimFinken_rotor_respondable" + std::to_string(i+1)).c_str());
        std::unique_ptr<Rotor> vr(new Rotor(rHandle));
        finken.addRotor(vr);
    }
    simReleaseBuffer((char *) proxSensorHandles);
    simReleaseBuffer((char *) baseHandles);
    vrepLog << "[FINK] succesfully built finken " << finken.ac_id << std::endl; 
}


void Finken::updatePos(Finken& finken) {
   

    float height;
    std::vector<float> position = {0,0,0};
    std::vector<float> tempquat = {0,0,0,0};
    std::vector<float> velocity = {0,0,0};
    std::vector<float> rotVelocity = {0,0,0};
    std::vector<float> oldVel = {0,0,0};
    std::vector<float> oldRotVel ={0,0,0};

    finken.positionSensor->get_with_error(position);
    finken.pos[0] = position[0];
    finken.pos[1] = position[1];
    finken.heightSensor->get_with_error(height);
    finken.pos[2] = height;

    if(simGetObjectQuaternion(finken.baseHandle, -1, &tempquat[0]) > 0) {
        //returns quat as x,y,z,w
        finken.quat[0] = tempquat[0];
        finken.quat[1] = tempquat[1];
        finken.quat[2] = tempquat[2];
        finken.quat[3] = tempquat[3];
        //std::cout << finken.quat[0] << " | " << finken.quat[1] << " | " << finken.quat[2] << " | " << finken.quat[3] << std::endl;
    }
    else {
      simAddStatusbarMessage("error retrieveing Finken Base Orientation");
    }

    if(simGetObjectVelocity(finken.baseHandle, &velocity[0], &rotVelocity[0]) > 0) {
        finken.vel[0] = velocity[0];
        finken.vel[1] = velocity[1];
        finken.vel[2] = velocity[2];
        finken.rotVel[0] = rotVelocity[0];
        finken.rotVel[1] = rotVelocity[1];
        finken.rotVel[2] = rotVelocity[2];
        std::transform(finken.vel.begin(), finken.vel.end(), oldVel.begin(), finken.accel.begin(),
            [](double a, double b) {return (a-b)/simGetSimulationTimeStep();});
        std::transform(finken.rotVel.begin(), finken.rotVel.end(), oldRotVel.begin(), finken.rotAccel.begin(),
            [](double a, double b) {return (a-b)/simGetSimulationTimeStep();});
        oldVel = velocity;
        oldRotVel = rotVelocity;
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
    for(unsigned int i = 0; i<throttlevalues.size(); i++){
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
    std::vector<std::vector<float>> motorForces= {motorNW, motorNE, motorSE, motorSW};
    Eigen::Quaternionf rotorQuat;

    for (int i=0; i<4; i++) {
	/* for each rotor,
	   get the quaternion for each rotor, rotate the corresponding force 
           and apply to the rotor */
        simGetObjectQuaternion(this->getRotors().at(i)->handle, -1, &rotorQuat.x());
        vrepLog << "[FINK] Rotor #" << i << " Quaternion-xyzw: " << rotorQuat.x() << " | "  << rotorQuat.y() << " | " << rotorQuat.z() << " | " << rotorQuat.w() << std::endl;
        Eigen::Vector3f force(motorForces.at(i).data());
        force = rotorQuat * force;
	Eigen::Vector3f torque = (pow(-1, (i)))*0*force;

        vrepLog << "[FINK] Rotor #" << i << " force: " << force[0] << " | "  << force[1] << " | " << force[2] <<  std::endl;	
	vrepLog << "[FINK] Rotor #" << i << " torque: " << torque[0] << " | "  << torque[1] << " | " << torque[2] <<  std::endl;	

	//convert Eigen-style vectors to std	
	std::vector<float> simForce(&force[0], force.data() + force.rows() * force.cols());
        vrepLog << "[FINK] adding force to rotor " << i << ": " << simForce[0] << " | " << simForce[1] << " | " << simForce[2] << std::endl;
	std::vector<float> simTorque(&torque[0], torque.data() + torque.rows() * torque.cols());
        vrepLog << "[FINK] adding torque to rotor " << i << ": " << simTorque[0] << " | " << simTorque[1] << " | " << simTorque[2] << std::endl;		
	
	

	//std::fill(simForce.begin(), simForce.end(), 0);
		
        this->getRotors().at(i)->set(simForce, simTorque);

    }


}
