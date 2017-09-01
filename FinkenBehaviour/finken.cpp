#include "finken.h"
#include <iostream>
#include "v_repLib.h"
#include <memory>
#include <cstring>



using boost::asio::ip::tcp;

static int kFinkenSonarCount = 4;
static int kFinkenHeightSensorCount = 1;
static std::string kFinkenName = "FINken2";
std::atomic<bool> sendSync(false);

std::condition_variable cv;
std::mutex cv_m, syncMutex;

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
        try  {
        	std::cout << "client connected" << std::endl;
        	//todo get finken id
        	//check for existence
        	//reply to paparazzi
        	
		//first connection:
		int copter_id;
		size_t id = readSync.extend();
		{	
			std::cout << "first connection" << std::endl;
			boost::archive::text_iarchive in(*sPtr);
                	in >> copter_id;
			std::cout << "1" << std::endl;

			//TODO: check for existence of a free(not associated with a paparazzi client yet) copter
			buildFinken(*this);
			std::cout << "2" << std::endl;

			//TODO: Add error if no copter is found and reset Sync to correct size
			boost::archive::text_oarchive out(*sPtr);
            		int response = 1;
            		out << response;
			std::cout << "3" << std::endl;

        	}	
		for (;;)    {
            		int commands_nb = 0;
            		{	std::cout << "second connection" << std::endl;

                		boost::archive::text_iarchive in(*sPtr);
                		in >> commands_nb;
                		double commands[commands_nb]={};
                		for(int i = 0; i< commands_nb; i++) {
                		    in >> commands[i];    
                		}
                		readSync.set(id);
				sendSync = false;
                		cv.notify_all();
				std::cerr << "Finken " << copter_id << " Received commands" << '\n';
                		if(cv.wait_for(server_lock, std::chrono::milliseconds(10000), [](){return readSync;})) 
                		    std::cerr << "Every Finken Received commands" << '\n';
                		else
                		    std::cerr << "Finken "<< copter_id << " timed out. id == " << id << '\n';
				
				
		                std::cout << " commands received: [";
		                for(int i=0;i<commands_nb;i++){
		                    std::cout << commands[i] << ((i==commands_nb-1)?"":", ");
		                }
		                std:: cout << "]" << std::endl;
			 	
				std::cerr << "test" << '\n';
				readSync.unSet(id);
			 	std::cerr << "Finken " << copter_id << " waiting" << '\n';
		 	 	while ( !sendSync.load() ){             // (3)
       					std::this_thread::sleep_for(std::chrono::milliseconds(5));
   				}	 
		         	std::cerr << "Finken " << copter_id << " finished waiting, replying" << '\n';
		         	boost::archive::text_oarchive out(*sPtr);
       			        commands_nb++;
        		 	out << commands_nb;
        		 }
        	}
    	}
  	catch (std::exception& e) {
		std::cerr << "Exception in thread: " << e.what() << "\n";
		std::cerr << "Error Message: " << sPtr->error().message() << std::endl;
	}
}

/*
 *Takes a unique_ptr to a Finken and adds
 *the correct handles for the sensors & rotors
 *
 * TODO:Multiple copter support via vrep-register  call(replacing the identification by const string)
 */
void buildFinken(Finken& finken){
    std::cout << "building finken" << std::endl;

    int fHandle = simGetObjectHandle(kFinkenName.c_str());
    std::cout << "1 " << fHandle << std::endl;
    finken.handle = fHandle;
    int foundSensorCount = 0;
    std::cout << "2" << std::endl;



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
    int rHandle = simGetObjectHandle(kFinkenName.c_str());

    for(int i = 1; i<5; i++){
        int rHandle = simGetObjectHandle(("SimFinken_rotor_respondable" + std::to_string(i)).c_str());
        std::unique_ptr<Rotor> vr(new Rotor(rHandle));
        finken.addRotor(vr);
    }
    simReleaseBuffer((char *) proxSensorHandles);
}

