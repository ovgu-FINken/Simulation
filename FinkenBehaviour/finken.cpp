#include "finken.h"
#include <iostream>
#include "v_repLib.h"
#include <memory>
#include <cstring>
#include "vrepplugin.h"
#include "dataPacket.h"
#include "finkencontrol.h"


using boost::asio::ip::tcp;

static int kFinkenSonarCount = 4;
static int kFinkenHeightSensorCount = 1;
std::atomic<bool> sendSync(false);

std::condition_variable cv;
std::mutex cv_m, syncMutex;
vrepPacket outPacket;
paparazziPacket inPacket;

MultiSync readSync;

Finken::Finken(){}
Finken::Finken(int fHandle) : handle(fHandle){}

void Finken::addSensor(std::unique_ptr<Sensor> &sensor){
    this->sensors.push_back(std::move(sensor));
    std::cout << "Adding sensor to finken" << '\n';
}

void Finken::addRotor(std::unique_ptr<Rotor> &rotor){
    std::cout << "Adding rotor with name" << simGetObjectName(rotor->handle) << '\n';
    this->rotors.push_back((std::move(rotor)));
}



std::vector<std::unique_ptr<Sensor>> &Finken::getSensors(){
    return this->sensors;
}


std::vector<std::unique_ptr<Rotor>> &Finken::getRotors(){
    return this->rotors;
}


void Finken::run(std::unique_ptr<tcp::iostream> sPtr){
	std::unique_lock<std::mutex> server_lock(cv_m);
        try {
            std::cout << "client connected" << std::endl;
        	
	        //first connection: 
	    int copter_id;	
            size_t id;
            int commands_nb = 0;
	    std::cout << "first connection" << std::endl;
	    {	
                boost::archive::text_iarchive in(*sPtr);
                in >> inPacket;
		this->commands[0]=inPacket.nw;
		this->commands[1]=inPacket.ne;	
		this->commands[2]=inPacket.se;	
		this->commands[3]=inPacket.sw;	
            }                      
    	    // check for existence of a free(not associated with a paparazzi client yet) copter
            if(simCopters.size() > 0) {
                id = readSync.extend();
		buildFinken(*this, simCopters.back());
		std::cout << "building finken with id " << simCopters.back() << std::endl;
                simCopters.erase(simCopters.end()-1);
                std::cout << "recieved: " << inPacket.nw << " | " << inPacket.ne << " | " << inPacket.se << " | " << inPacket.sw << std::endl;
            }

            else {
                std::cout << "no finken available, terminating connection" << std::endl;
                sPtr.get()->close();
            }
            {
		boost::archive::text_oarchive out(*sPtr);
   	    	this->pos = step(this);
		outPacket.x = this->pos[0];
		outPacket.y = this->pos[1];
		outPacket.z = this->pos[2];
   	    	out << outPacket;
            }
        		
	        for (;;)    {
            	int commands_nb = 0;
                std::cout << "second connection" << std::endl;
                boost::archive::text_iarchive in(*sPtr);
                in >> inPacket;
                this->commands[0]=inPacket.nw;
		this->commands[1]=inPacket.ne;	
	        this->commands[2]=inPacket.se;	
		this->commands[3]=inPacket.sw;	
	        std::cout << "recieved: " << inPacket.nw << " | " << inPacket.ne << " | " << inPacket.se << " | " << inPacket.sw << std::endl;

                readSync.set(id);
		sendSync = false;
                cv.notify_all();
		std::cout << "Finken " << copter_id << " Received commands " << '\n';
               	if(cv.wait_for(server_lock, std::chrono::milliseconds(10000), [](){return readSync;})) 
               	else {
               	    std::cout << "Finken "<< copter_id << " timed out. id == " << id << '\n';
		}
			 	
		readSync.unSet(id);
		std::cout << "Finken " << copter_id << " waiting" << '\n';
	 	while ( !sendSync.load() ){             // (3)
		    std::this_thread::sleep_for(std::chrono::milliseconds(5));
   		}	 
		std::cout << "Finken " << copter_id << " finished waiting, replying" << '\n';
		//boost::archive::text_oarchive out(*sPtr);
       		commands_nb = 1;
        	boost::archive::text_oarchive out(*sPtr);
                this->pos = step(this);
		outPacket.x = this->pos[0];
		outPacket.y = this->pos[1];
		outPacket.z = this->pos[2];
                out << outPacket;
        	
            }
        }   
  	    catch (std::exception& e) {
	        std::cerr << "Exception in thread: " << e.what() << "\n";
	        std::cerr << "Error Message: " << sPtr->error().message() << std::endl;
	    }
}


void Finken::setRotorSpeeds(const Eigen::Matrix<float, 4, 4>& mixingMatrix) {
    Eigen::Vector4f motorCommands(this->commands[0], this->commands[1], this->commands[2], this->commands[3]);
    std::cout << "motorcommands before multiplcation: " << motorCommands[0] << "   " << motorCommands[1] << "   " << motorCommands[2] << "    " << motorCommands[3] << std::endl;
    motorCommands = mixingMatrix * motorCommands;
    std::cout << "motorcommands after multiplication: " << motorCommands[0] << "   " << motorCommands[1] << "   " << motorCommands[2] << "    " << motorCommands[3] << std::endl;
    std::vector<float> motorFrontLeft  = {0, 0, motorCommands[0]};
    std::vector<float> motorFrontRight = {0, 0, motorCommands[1]};
    std::vector<float> motorBackLeft   = {0, 0, motorCommands[2]};
    std::vector<float> motorBackRight  = {0, 0, motorCommands[3]};
    std::vector<float> vtorque = {0,0,0};
    std::vector<std::vector<float>> motorForces= {motorFrontLeft, motorFrontRight, motorBackLeft, motorBackRight};
    
    for(auto it=motorForces.begin(); it != motorForces.end(); it++) {
    	for (auto it2 = it->begin(); it2 != it->end(); it2++) {
	    std::cout << (*it2) << " | ";
	}			
	std::cout << std::endl;
    }

    for (int i = 0; i<4; i++) {
        this->getRotors().at(i)->set(motorForces[i], vtorque);
    }
}


/*
 *Takes a unique_ptr to a Finken and adds
 *the correct handles for the sensors & rotors
 *
 */
void buildFinken(Finken& finken, int fHandle){
    std::cout << "building finken" << std::endl;

    finken.handle = fHandle;
    int foundSensorCount = 0;

    //create positionsensor and add to the finken:
    std::unique_ptr<Sensor> posSensor(new PositionSensor (fHandle));
    finken.addSensor(posSensor);

    //Grab all Proximity sensors and add them to the finken:
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
}

