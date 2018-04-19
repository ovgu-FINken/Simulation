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
#include <boost/thread.hpp>
#include <boost/archive/text_oarchive.hpp>
#include <boost/archive/text_iarchive.hpp>
#include <Eigen/Dense>
#include <condition_variable>
#include <chrono>
#include <boost/asio.hpp>


using std::endl;
using std::ostream;
using boost::filesystem::ofstream;
using boost::filesystem::current_path;
using boost::asio::ip::tcp;
using Clock = std::chrono::high_resolution_clock;

using boost::asio::ip::tcp;

extern float execution_step_size;
extern std::vector<std::unique_ptr<Finken>> allFinken;
std::unique_ptr<tcp::iostream> sPtr;
VrepLog vrepLog;


void deleteFinken(std::unique_ptr<Finken>& finken){
    //TODO: this stuff definitely isnt thread safe
    vrepLog << "attempting to erase finken " <<finken->handle << std::endl;
    simCopters.emplace_back(std::make_pair(finken->ac_id, finken->handle));
    allFinken.erase(std::remove(allFinken.begin(), allFinken.end(), finken),allFinken.end());
}

class Async_Server{
    public:
    Async_Server(boost::asio::io_service& io_service) :
      acceptor_(io_service,tcp::endpoint(tcp::v4(), 50013)){
        simAddStatusbarMessage("Asynchronous server successfully established");
        start_accept();
    }
    ~Async_Server() { std::cerr <<  "Server died!" << std::endl; }
    private:
    void start_accept(){
        simAddStatusbarMessage("Server ready to accept new connection");
        sPtr.reset(new tcp::iostream());
        acceptor_.async_accept(*sPtr->rdbuf(), boost::bind(&Async_Server::handle_accept, this, boost::asio::placeholders::error));
        simAddStatusbarMessage("Server ready to accept new connection");

    }

    void handle_accept(const boost::system::error_code& error){
        if(!error){
            simAddStatusbarMessage("New copnnection established");
            std::cerr << "creating Empty Finken" << '\n';
            allFinken.emplace_back(new Finken());
            std::cerr << "creating Finken Server" << '\n';
            auto run=[](){auto& finken = allFinken.back(); finken->run(std::move(sPtr)); deleteFinken(finken);};
            std::thread(run).detach();
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
      Log::name(name());
      std::string date = __DATE__;
      Log::out() << "loaded v " << date << std::endl;
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
    
    void* sceneLoad(int* auxiliaryData, void* customData, int* replyData)
    {   
        
        std::cout << "checking sceneload" << '\n';
        vrepLog << "ScriptLoader check" << '\n' ;
        std::string dummyName = "ScriptLoader";
        int handle = simGetObjectHandle(dummyName.c_str());
        std::cout << handle << '\n';
        if (handle > 0){
            std::cout << "1" << '\n';
            vrepLog << "ScriptLoader found, starting asynchronous vrep server" << '\n' ;
            std::cout << "2" << '\n';
            async_server.reset(new Async_Server(io_service));
            boost::thread(boost::bind(&boost::asio::io_service::run, &io_service)).detach();
            std::cout << "3" << '\n';
            vrepLog << "server done" << '\n';
        }
        else {
            std::cout << "4" << '\n';
            vrepLog << "ScriptLoader not found, not starting server" << '\n';
        }


    }

    void* simStart(int* auxiliaryData,void* customData,int* replyData)
    {
        return NULL;
    }

    void* simEnd(int* auxiliaryData,void* customData,int* replyData)
    {
        /*allFinken.clear();
        allFinken.shrink_to_fit();
        simCopters.clear();
        simCopters.shrink_to_fit();*/
        io_service.stop();
        io_service.reset();
        boost::thread(boost::bind(&boost::asio::io_service::run, &io_service)).detach();
        return NULL;
    }

    void* action(int* auxiliaryData,void* customData,int* replyData)
    {
        auto actionStart = Clock::now();
        while(allFinken.size() == 0){
            vrepLog << "[VREP] waiting for finken creation. Available copters for pairing: " << simCopters.size() << '\n';
	    	std::this_thread::sleep_for(std::chrono::milliseconds(2000));
		    //doNothing;
	    }
    	//vrepLog << "vrep pass done, copter count:" << allFinken.size() <<  '\n';
        auto then = Clock::now();
        while (!readSync.load()){
       		std::this_thread::sleep_for(std::chrono::milliseconds(1));
   	    }
        auto now = Clock::now();
        vrepLog << "[VREP] time vrep is waiting for finken: " << std::chrono::nanoseconds(now-then).count()/1000000 << "ms" << std::endl;
        then =Clock::now();
        for(int i = 0; i<allFinken.size(); i++){
            allFinken.at(i)->setRotorSpeeds();
        }
        //position data can be sent now
        sendSync=true;
        readSync = false;
        now = Clock::now();
        vrepLog << "[VREP] time setting rotor forces: " << std::chrono::nanoseconds(now-then).count()/1000000 << "ms" << 
        std::endl;
        vrepLog << "[VREP] time total finkenplugin action(): " << std::chrono::nanoseconds(now - actionStart).count()/1000000 << "ms" << std::endl;

        return NULL;
    }

} plugin;
