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
#include <Eigen/Dense>
#include <algorithm>
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



std::string vrepHome=std::getenv("VREP_HOME");
std::atomic<unsigned int> readyFinkenCount(0);


std::vector<bool> finkenDone; 

std::vector<std::condition_variable*> finkenCV;
std::mutex vrepMutex;
std::condition_variable notifier;
bool running = false;



Finken::Finken(int fHandle, int _ac_id, int _rotorCount, int _sonarCount, std::string _ac_name, unsigned int _syncID) : handle(fHandle), ac_id(_ac_id), rotorCount(_rotorCount), sonarCount(_sonarCount), syncID(_syncID) {
    ac_name = _ac_name;
}

void Finken::addSensor(std::unique_ptr<Sensor> &sensor){
    this->sonars.push_back(std::move(sensor));
    //vrepLog << "Adding sonar to finken" << '\n';
}
void Finken::addRotor(std::unique_ptr<Rotor> &rotor){
    //vrepLog << "Adding rotor with name" << simGetObjectName(rotor->handle) << '\n';
    this->rotors.push_back((std::move(rotor)));    
}

std::vector<std::unique_ptr<Sensor>> &Finken::getSonars(){
    return this->sonars;
}
std::vector<std::unique_ptr<Rotor>> &Finken::getRotors(){
    return this->rotors;
}

void Finken::run(std::unique_ptr<tcp::iostream> sPtr){
    //auto runStart = Clock::now();
    try {
        simStartSimulation();
        std::cout << "Rotor order before sorting: ";
        for(auto&& rotor : rotors) {
            std::cout << rotor.get()->position << " | ";
        }
        std::sort(rotors.begin(),rotors.end(), [](std::unique_ptr<Rotor>& r1, std::unique_ptr<Rotor>& r2) {return *r1.get() < *r2.get();});	    
        buildFinken(*this);        
        std::cout << "Rotor order after sorting: ";
        for(auto&& rotor : rotors) {
            std::cout << rotor.get()->position << " | ";
        }
        std::cout << std::endl;
        //vrepLog << "[FINK] client connected" << std::endl;
	    //vrepLog << "[FINK] simulation state: " << simState << std::endl;	    
		

        std::this_thread::sleep_for(std::chrono::milliseconds(300));
        //first connection:
        //int connection_nb =1;
        //vrepLog << "[FINK] first connection" << std::endl;
        //read commands
        sPtr->flush();
        {               
                //vrepLog << "[FINK] creating archive" << std::endl;            
                boost::archive::binary_iarchive in(*sPtr, boost::archive::no_header);
                //vrepLog << "[FINK] recieving data" << std::endl;
                in >> inPacket;
        }
        //vrepLog << "[FINK] setting commands" << std::endl;
        this->commands[0]=inPacket.north_east;
        this->commands[1]=inPacket.south_east;
        this->commands[2]=inPacket.south_west;
        this->commands[3]=inPacket.north_west;
        /* commands to csv 
        for(int i=0;i<commands_nb;i++) {
            //vrepLog << commands[i] << ((i==commands_nb-1)?"":", ");
            csvdata << commands[i] << ((i==commands_nb-1)?",":",");
        }
        */
        std::cout << "[FINK] first connection successfully read" << std::endl;
        //vrepLog << "[FINK] updating position" << std::endl;
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
        paparazzi-vrep loop
        */
        for (;;){
            sPtr->flush();
            //std::cout << "finken " <<ac_id <<" starting loop" << std::endl;
            //auto then = Clock::now();
            //receive data:
            //vrepLog << "[FINK] connection:" << connection_nb++ << std::endl;
            {
                boost::archive::binary_iarchive in(*sPtr, boost::archive::no_header);
                in >> inPacket;
            }
            //std::cout << "finken " <<ac_id <<" read data" << std::endl;
            this->commands[0]=inPacket.north_east;
            this->commands[1]=inPacket.south_east;
            this->commands[2]=inPacket.south_west;
            this->commands[3]=inPacket.north_west;
            
            /* logstuff
            vrepLog << "[FINK] recieved: " << inPacket.north_east << " | " << inPacket.south_east << " | " << inPacket.south_west << " | " << inPacket.north_west << std::endl << std::endl;
            auto now = Clock::now();
            //vrepLog << "[FINK] time receiving data: " << std::chrono::nanoseconds(now-then).count()/1000000 << "ms" << std::endl;            
            then = Clock::now();
            */
            
            {
                std::unique_lock<std::mutex> lock(vrepMutex);
                finkenDone.at(syncID) = true;
                notifier.notify_all();
                while(finkenDone[syncID] && running) {
                    finkenCV.at(syncID)->wait(lock);     
                }
                if (!running) {
                    //just to make sure this finken gets cleaned up correctly
                    //TODO: maybe a custom exception to specifically handle intentional shutdown?
                    throw std::runtime_error("Simulation no longer running, killing finken");
                    break;
                }
                
            }
             /*logstuff
            now = Clock::now();
            //vrepLog << "[FINK] time finken is waiting for vrep: " << std::chrono::nanoseconds(now-then).count()/1000000 << "ms" << std::endl << std::endl;
            then = Clock::now();
            */

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

            /*logstuff
            //vrepLog << "[FINK] sending position/attitude data: "<< std::endl
            << "time: " << outPacket.simTime << std::endl
            << "pos: " << outPacket.pos[0] << " | "  << outPacket.pos[1] << " | " << outPacket.pos[2] << std::endl
            << "quat-xyzw: " << outPacket.quat[0] << " | "  << outPacket.quat[1] << " | " << outPacket.quat[2] << " | " << outPacket.quat[3] << std::endl
            << "vel: " << outPacket.vel[0] << " | "  << outPacket.vel[1] << " | " << outPacket.vel[2] << std::endl
            << "rotVel: " << outPacket.rotVel[0] << " | "  << outPacket.rotVel[1] << " | " << outPacket.rotVel[2] << std::endl
            << "accel: " << outPacket.accel[0] << " | "  << outPacket.accel[1] << " | " << outPacket.accel[2] << std::endl
            << "rotAccel: " << outPacket.rotAccel[0] << " | "  << outPacket.rotAccel[1] << " | " << outPacket.rotAccel[2] << std::endl << std::endl;
            

            now = Clock::now();
            //vrepLog << "[FINK] time sending data: " << std::chrono::nanoseconds(now-then).count()/1000000 << "ms" << std::endl;
            auto runEnd = Clock::now();
            //vrepLog << "[FINK] time total Finken::run() loop: " << std::chrono::nanoseconds(runEnd - runStart).count()/1000000 << "ms" << std::endl << "-------------------------------------------------------------------" << std::endl;;
            csvdata << simGetSimulationTime() << ",";
            for(int i=0;i<commands_nb;i++) {
                csvdata << commands[i] << ((i==commands_nb-1)?",":",");
            }

            csvdata << this->quat[0] << "," << this->quat[1] << "," << this->quat[2] << "," << this->quat[3] << ", " <<  this->pos[0] <<"," << this->pos[1] << "," << this->pos[2] << std::endl;
            */
        }
    }
  	catch (std::exception& e) {
	    std::cerr << "Exception in thread: " << e.what() << "\n";
	    std::cerr << "Error Message: " << sPtr->error().message() << std::endl;
        //vrepLog << "[FINK] Exception in thread: " << e.what() << "\n";
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
 *Takes a unique_ptr to a Finken and adds the random number generator
 *
 */
void buildFinken(Finken& finken){    
    //vrepLog << "[FINK] building finken" << std::endl;
    std::time_t now = std::time(0);
    finken.gen = boost::random::mt19937{static_cast<std::uint32_t>(now)};    

}


void Finken::updatePos(Finken& finken) {
    
    //std::cout << "updating accel" << '\n';
    finken.accelerometer->update();
    //std::cout << "updating pos" << '\n';
    finken.positionSensor->update();
    //std::cout << "updating height" << '\n';
    finken.heightSensor->update();
    //std::cout << "updating att" << '\n';
    finken.attitudeSensor->update();
    
    std::vector<float> position = {0,0,0};
    std::vector<float> velocities = {0,0,0,0,0,0,0,0,0,0,0,0};

    //std::cout << "grabbing sensor values" << '\n';
    //std::cout << "pos" << '\n';
    position = finken.positionSensor->get();
    finken.pos[0] = position[0];
    finken.pos[1] = position[1];    
    //std::cout << "height" << '\n';
    finken.pos[2] = finken.heightSensor->get()[0];
    //std::cout << "quat" << '\n';
    finken.quat = finken.attitudeSensor->get();

    //std::cout << "accel" << '\n';
    //Element order:  0-2: velocity, 3-5: rotVel, 6-8: accel, 9-11: rotaccel
    velocities = finken.accelerometer->get();    
    //std::cout << "vel" << '\n';
    finken.vel[0] = velocities[0];
    finken.vel[1] = velocities[1];
    finken.vel[2] = velocities[2];
    //std::cout << "rotvel" << '\n';
    finken.rotVel[0] = velocities[3];
    finken.rotVel[1] = velocities[4];
    finken.rotVel[2] = velocities[5];
    //std::cout << "accel" << '\n';
    finken.accel[0] = velocities[6];
    finken.accel[1] = velocities[7];
    finken.accel[2] = velocities[8];
    //std::cout << "rotaccel" << '\n';
    finken.rotAccel[0] = velocities[9];
    finken.rotAccel[1] = velocities[10];
    finken.rotAccel[2] = velocities[11];

  

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

    //pprz: [NE, SE, SW, NW]; V-REP: NW, NE, SE, SW
    std::vector<float> motorNW  = {0, 0, motorCommands[0]};
    std::vector<float> motorNE = {0, 0, motorCommands[1]};
    std::vector<float> motorSE   = {0, 0, motorCommands[2]};
    std::vector<float> motorSW  = {0, 0, motorCommands[3]};
    std::vector<float> vtorque = {0,0,0};
    std::vector<std::vector<float>> motorForces= {motorNW, motorNE, motorSE, motorSW};
    Eigen::Quaternionf rotorQuat;

    for (int i=0; i<4; i++) {
	    /* for each rotor,
	   get the quaternion for each rotor, rotate the corresponding force 
           and apply to the rotor */
        simGetObjectQuaternion(this->getRotors().at(i)->handle, -1, &rotorQuat.x());
        
        Eigen::Vector3f force(motorForces.at(i).data());
        force = rotorQuat * force;
	    Eigen::Vector3f torque = (pow(-1, (i)))*0*force;
        

	    
        std::vector<float> simForce(&force[0], force.data() + force.rows() * force.cols());        
        std::vector<float> simTorque(&torque[0], torque.data() + torque.rows() * torque.cols());
        /*logstuff    	
        //vrepLog << "[FINK] Rotor #" << i << " Quaternion-xyzw: " << rotorQuat.x() << " | "  << rotorQuat.y() << " | " << rotorQuat.z() << " | " << rotorQuat.w() << std::endl;
        //vrepLog << "[FINK] Rotor #" << i << " force: " << force[0] << " | "  << force[1] << " | " << force[2] <<  std::endl;	
        //vrepLog << "[FINK] Rotor #" << i << " torque: " << torque[0] << " | "  << torque[1] << " | " << torque[2] <<  std::endl;	
        //vrepLog << "[FINK] adding force to rotor " << i << ": " << simForce[0] << " | " << simForce[1] << " | " << simForce[2] << std::endl;
        //vrepLog << "[FINK] adding torque to rotor " << i << ": " << simTorque[0] << " | " << simTorque[1] << " | " << simTorque[2] << std::endl;	
        */
        //std::fill(simForce.begin(), simForce.end(), 0);
		
        this->getRotors().at(i)->set(simForce, simTorque);

    }


}

