#include <vrepplugin.h>
#include <log.h>
#include "finken.h"
#include "v_repLib.h"
#include <unistd.h>
#include <iostream>
#include <positionsensor.h>
#include <cstring>
#include <cstdlib>
#include <iostream>
#include <thread>
#include <memory>
#include <utility>
#include <boost/asio.hpp>
#include <boost/bind.hpp>
#include <boost/archive/text_oarchive.hpp>
#include <boost/archive/text_iarchive.hpp>
#include <Eigen/Dense>
#include <condition_variable>
#include <chrono>

using boost::asio::ip::tcp;

extern float execution_step_size;
static std::vector<std::unique_ptr<Finken>> allFinken;
std::unique_ptr<tcp::iostream> sPtr;


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
}server;


class Async_Server{    
    public:
    Async_Server(boost::asio::io_service& io_service) : 
      acceptor_(io_service,tcp::endpoint(tcp::v4(), 50013)){
        start_accept();    
    }
    ~Async_Server() { std::cerr <<  "Server died!" << std::endl; }
    private:
    void start_accept(){
        std::cout << "accepting new connection" << std::endl;
        sPtr.reset(new tcp::iostream());
        acceptor_.async_accept(*sPtr->rdbuf(), boost::bind(&Async_Server::handle_accept, this, boost::asio::placeholders::error));
      }
        
    void handle_accept(const boost::system::error_code& error){
        if(!error){
            std::cerr << "creating Empty Finken" << '\n';
            std::unique_ptr<Finken> finken (new Finken());  
            allFinken.push_back(std::move(finken));
            std::cerr << "creating Finken Server" << '\n';
            std::thread(std::bind(&Finken::run, allFinken.back().get(), std::placeholders::_1), std::move(sPtr)).detach();
        }
        else{
            std::cerr << "error in accept handler: " << error << std::endl;
        }
        start_accept();
    }
    tcp::acceptor acceptor_;
};






class FinkenPlugin: public VREPPlugin {
  public:
    boost::asio::io_service io_service;
    std::unique_ptr<Async_Server> async_server;
    FinkenPlugin() {}
    FinkenPlugin& operator=(const FinkenPlugin&) = delete;
    FinkenPlugin(const FinkenPlugin&) = delete;
    virtual ~FinkenPlugin() {}
    virtual unsigned char version() const { return 1; }
    virtual bool load() {
      std::cout << "starting asynchronous vrep server" << '\n' ;
      async_server.reset(new Async_Server(io_service));
      std::cout << "server done" << '\n';
      Log::name(name());
      Log::out() << "loaded v 13-10-17" << std::endl;
      return true;
    }
    virtual bool unload() {
      async_server.reset(nullptr);
      Log::out() << "unloaded" << std::endl;
      return true;
    }
    virtual const std::string name() const {
      return "Finken Paparazzi Plugin";
    }

    void* simStart(int* auxiliaryData,void* customData,int* replyData)
    {
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
	   

        
                
        for(int i = 0; i<allFinken.size(); i++){
            allFinken.at(i)->setRotorSpeeds();
        }
         
    
       
    return NULL;
    }

} plugin;
