/** 
 * @file finkenplugin.cpp 
 * \class FinkenPlugin
 * \brief implementation of the baseline functionality for the plugin and the communication, including the server class
 *
 * 
 * 
 */
 

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
#include <condition_variable>
#include <chrono>
#include <boost/asio.hpp>

#pragma GCC diagnostic ignored "-Wint-in-bool-context"
#include <Eigen/Dense>
#pragma GCC diagnostic pop

using std::endl;
using std::ostream;
using boost::filesystem::ofstream;
using boost::filesystem::current_path;
using boost::asio::ip::tcp;
using Clock = std::chrono::high_resolution_clock;

using boost::asio::ip::tcp;

bool serverLoaded = false;
bool connectionEstablished = false;
extern float execution_step_size;
extern std::vector<std::unique_ptr<Finken>> simFinken;
std::unique_ptr<tcp::iostream> sPtr;
VrepLog vrepLog;
paparazziPacket firstPacket;


/**
 * \class Async_Server
 * \brief Asynchronous (boost::Asio) Server class to accept new paparazzi connections and pair them with a vrep copter.
 * @see Finken::run()
 * \todo move to separate.cpp file
 */
class Async_Server{
    public:
    /** Server constructor */	    
    Async_Server(boost::asio::io_service& io_service) :
      acceptor_(io_service,tcp::endpoint(tcp::v4(), 50013)){
        simAddStatusbarMessage("Asynchronous server successfully established");
        start_accept();
    }
    /** Basic destructor */
    ~Async_Server() { std::cerr <<  "Server died!" << std::endl; }
    private:
    /** Function waiting for new connections to accept*/
    void start_accept(){
        if(!sPtr)
          sPtr.reset(new tcp::iostream());
        acceptor_.async_accept(*sPtr->rdbuf(), boost::bind(&Async_Server::handle_accept, this, boost::asio::placeholders::error));
        simAddStatusbarMessage("Server ready to accept new connection");
    }
    /** 
     * Function handling any new connection.
     * If a free copter with matching aricraft ID to the connecting paparazzi copter is found,
     * this calls the connect function on the corresponding copter
     * @see Finken::connect() 
     */
    void handle_accept(const boost::system::error_code& error){
        if(!error){
            simAddStatusbarMessage("New connection established");
            int ac_id=0;
            bool matchingCopterFound = false;
            {
                boost::archive::binary_iarchive in(*sPtr, boost::archive::no_header);
                in >> firstPacket;
                ac_id=firstPacket.ac_id;
            }
            
            simAddStatusbarMessage("reveived ac_id");
            std::cout << ac_id << std::endl;
            std::cout << "simFinken: " << simFinken.size() << std::endl;
            for(auto&& pFinken : simFinken) {
                if (pFinken->ac_id == ac_id) {
                    if (pFinken->connected) {
                        std::cerr << "finken with ac_id " << ac_id << "already connected" << std::endl;
                        break;
                    }
                    matchingCopterFound = true;
                    pFinken->connect(std::move(sPtr));
                    std::cout << "started a finken" << std::endl;
                    connectionEstablished = true;
                }
            } 
            if(matchingCopterFound == false) {std::cerr << "no matching copter was found" <<std::endl;}
                        
        }
        else{
            std::cerr << "error in accept handler: " << error.category().message(error.value()) << std::endl;
        }
        start_accept();
    }
    tcp::acceptor acceptor_;
};


/**
 * The actual finken plugin. This class handles the main communication with vrep and calls for
 * copter actions each timestep. It is also responsible for starting the server to communicate with paparazzi.
 *
 */
class FinkenPlugin: public VREPPlugin {
  public:
    /** The io service for the server */
    boost::asio::io_service io_service;
    std::unique_ptr<Async_Server> async_server;
    FinkenPlugin() {}
    FinkenPlugin& operator=(const FinkenPlugin&) = delete;
    FinkenPlugin(const FinkenPlugin&) = delete;
    virtual ~FinkenPlugin() {}
    virtual unsigned char version() const { return 1; }
    /** loads the plugin into vrep */
    virtual bool load() {
      Log::name(name());
      std::string date = __DATE__;
      Log::out() << "loaded v " << date << std::endl;
      sendSync.lock();
      readSync.lock();
      return true;
    }
    /** unloads the plugin */
    virtual bool unload() {
      if (serverLoaded){io_service.stop();}
      Log::out() << "unloaded" << std::endl;
      return true;
    }
    virtual const std::string name() const {
      return "Finken Paparazzi Plugin";
    }
    /**
     * Called once on the loading of any scene, it checks for the presence of a Dummy object "ScriptLoader" in the scene.
     * Only if that object is found, the server is startet and full functionality established.
     */
    void* sceneLoad(int* auxiliaryData, void* customData, int* replyData)
    {   
        
        std::cout << "checking sceneload" << '\n';
        vrepLog << "[VREP] ScriptLoader check" << '\n' ;
        std::string dummyName = "ScriptLoader";
        int handle = simGetObjectHandle(dummyName.c_str());
        std::cout << handle << '\n';
        if (handle > 0){
            vrepLog << "[VREP] ScriptLoader found, starting asynchronous vrep server" << '\n';
            async_server.reset(new Async_Server(io_service));
            boost::thread(boost::bind(&boost::asio::io_service::run, &io_service)).detach();
            serverLoaded = true;
            vrepLog << "[VREP] server done" << '\n';
        }
        else {
            vrepLog << "[VREP] ScriptLoader not found, not starting server" << '\n';
        }
    std::cout << "sceneload done" << '\n';
	return NULL;
    }

    void* simStart(int* auxiliaryData,void* customData,int* replyData)
    {	
	return NULL;
    }
    /**
     * Ends the simulation run and cleans up the server and Finken
     */
    void* simEnd(int* auxiliaryData,void* customData,int* replyData)
    {
        std::cerr << "[VREP] ending sim, resetting server" << std::endl;
	    vrepLog << "[VREP] ending sim, resetting server" << std::endl;
        //stopping and resetting the ioservice cleans up the server and any connections
        io_service.stop();
        io_service.reset();
        //reset the mutex to pre-Sim status
        sendSync.unlock();
        simFinken.clear();
        //restart the ioservice to prepare for a new simulation
        boost::thread(boost::bind(&boost::asio::io_service::run, &io_service)).detach();
	    vrepLog << "[VREP] successfully reset server" << std::endl;
        return NULL;
    }
    /**
     * This function controls the other parts of the plugin and synchronizes the vrep copters with the paparazzi copters.
     */
    void* action(int* auxiliaryData,void* customData,int* replyData)
    {   
	try {
	
		vrepLog << "[VREP] simulated copters: " << simFinken.size() << std::endl;
        	auto actionStart = Clock::now();
	        // if there is no finken connected to paparazzi yet, we do nothing:
	        if( std::none_of(simFinken.begin(), simFinken.end(), 
              [](const std::unique_ptr<Finken>& f){ return f->connected;}) )
            return NULL;
	        auto then = Clock::now();
	        //we wait for paparazzi to send us some commands:
	        if(!readSync.try_lock_for(std::chrono::seconds(2))) {
              if(!(simGetSimulationState()&sim_simulation_advancing)) {
                  vrepLog << "sim was already stopped, ending vrep main loop" << std::endl;
                  return NULL;
              }
              else {               
	            throw std::runtime_error("Vrep waiting for more than 2 seconds");
              }
	        }
	        auto now = Clock::now();
	        vrepLog << "[VREP] time vrep is waiting for finken: " << std::chrono::nanoseconds(now-then).count()/1000000 << "ms" << std::endl;
	        then =Clock::now();
	
	        //we apply those commands
	        for(auto&& pFinken : simFinken) {
                if (pFinken->connected) {
                    pFinken->setRotorSpeeds();
                }
            }
	        //position data can be sent now
	        sendSync.unlock();
	        now = Clock::now();
	        vrepLog << "[VREP] time setting rotor forces: " << std::chrono::nanoseconds(now-then).count()/1000000 << "ms" << 
	        std::endl;
	        vrepLog << "[VREP] time total finkenplugin action(): " << std::chrono::nanoseconds(now - actionStart).count()/1000000 << "ms" << std::endl;
	
        	return NULL;
	}
	catch (std::exception& e) {
	    std::cerr << "[VREP] Exception in thread: " << e.what() << "\n";
	    return NULL;
	}
    }

} plugin;
