#include <vrepplugin.h>
#include <log.h>
#include "finken.h"
#include "v_repLib.h"
#include <unistd.h>
#include <iostream>
#include <positionsensor.h>
#include "finkencontrol.h"
#include <cstring>
#include <cstdlib>
#include <iostream>
#include <thread>
#include <memory>
#include <utility>
#include <boost/asio.hpp>
#include <boost/archive/text_oarchive.hpp>
#include <boost/archive/text_iarchive.hpp>
#include <Eigen/Dense>
#include <condition_variable>
#include <chrono>

using boost::asio::ip::tcp;

extern float execution_step_size;
static std::vector<std::unique_ptr<Finken>> allFinken;

class Server{    
public:
void server(boost::asio::io_service& io_service, unsigned short port){
  tcp::acceptor a(io_service, tcp::endpoint(tcp::v4(), port));
  for (;;)  {
    std::unique_ptr<tcp::iostream> sPtr;
    sPtr.reset(new tcp::iostream());
    a.accept(*sPtr->rdbuf());
    std::cout << "creating Empty Finken" << '\n';
    std::unique_ptr<Finken> finken (new Finken());  
    allFinken.push_back(std::move(finken));
    std::cout << "creating Finken Server" << '\n';
    std::thread(std::bind(&Finken::run, allFinken.back().get(), std::placeholders::_1), std::move(sPtr)).detach();
    std::cout << "finken Server creation finished" << '\n';
  }
}
};


Server server;
boost::asio::io_service io_service;





class FinkenPlugin: public VREPPlugin {
  public:
    boost::asio::io_service io_service;
    FinkenPlugin() {}
    FinkenPlugin& operator=(const FinkenPlugin&) = delete;
    FinkenPlugin(const FinkenPlugin&) = delete;
    virtual ~FinkenPlugin() {}
    virtual unsigned char version() const { return 1; }
    virtual bool load() {
      Log::name(name());
      Log::out() << "loaded v 02-10-17" << std::endl;
      return true;
    }
    virtual bool unload() {

      Log::out() << "unloaded" << std::endl;
      return true;
    }
    virtual const std::string name() const {
      return "Finken Paparazzi Plugin";
    }

    void* simStart(int* auxiliaryData,void* customData,int* replyData)
    {
	std::cout << "starting server" << '\n' ;
        std::thread t1(std::bind(&Server::server, server, std::placeholders::_1, std::placeholders::_2),std::ref(io_service), 50013);
	t1.detach();
	std::cout << "server done" << '\n';
	return NULL;
    }


    void* action(int* auxiliaryData,void* customData,int* replyData)
    {   
        sendSync = true;
        while(allFinken.size() == 0){
            std::cout << "waiting for finken creation. Available copters for pairing: " << simCopters.size() << '\n';
	    	std::this_thread::sleep_for(std::chrono::milliseconds(2000));
		
		//doNothing;
	    }

    	//std::cout << "vrep pass done, copter count:" << allFinken.size() <<  '\n';
    
	while ( sendSync.load() ){
       		std::this_thread::sleep_for(std::chrono::milliseconds(5));
   	}
	   
    	Eigen::Vector4f motorCommands(0.0,0.0,0.0,0.0);

        Eigen::Matrix<float, 4, 4> mixingMatrix;
        
        /*taken from fink3.xml, paparazzi generated xml says something different 
        *check with https://wiki.paparazziuav.org/wiki/Rotorcraft_Configuration#Motor_Mixing
        */    
        mixingMatrix << -256, -256,  256, 256,
                         256, -256, -256, 256,
                        -256,  256, -256, 256,
                         256,  256,  256, 256;
        
        for(int i = 0; i<allFinken.size(); i++){
            allFinken.at(i)->setRotorSpeeds(mixingMatrix);
        }
        /* 
        motorCommands = mixingMatrix * motorCommands;
    
        execution_step_size = simGetSimulationTimeStep();
        
        // this will probably need some scaling 
        std::vector<float> motorFrontLeft  = {0, 0, motorCommands[0]};
        std::vector<float> motorFrontRight = {0, 0, motorCommands[1]};
        std::vector<float> motorBackLeft   = {0, 0, motorCommands[2]};
        std::vector<float> motorBackRight  = {0, 0, motorCommands[3]};
    
        std::vector<float> vtorque = {0,0,0};
        std::vector<std::vector<float>> motorForces= {motorFrontLeft, motorFrontRight, motorBackLeft, motorBackRight};
        Eigen::Matrix<float,3,2> coords = step(allFinken.at(0).get());
        for (int i = 0; i<4; i++) {
            allFinken.at(0)->getRotors().at(i)->set(motorForces[i], vtorque);
        }
        */
    return NULL;
    }

} plugin;
