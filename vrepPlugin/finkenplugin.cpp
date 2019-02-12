/** 
 * @file finkenplugin.cpp 
 * \class FinkenPlugin
 * \brief Implementation of the baseline functionality for the plugin and the communication with Paparazzi.
 * \todo This could use a .h file.
 */
 

#include <vrepplugin.h>
#include <log.h>
#include "finken.h"
#include "v_repLib.h"
#include <unistd.h>
#include <iostream>
#include <positionsensor.h>
#include <accelerometer.h>
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
#include <boost/format.hpp>
#include <condition_variable>
#include <chrono>
#include <boost/asio.hpp>
#include <boost/process.hpp>
#include <boost/random.hpp>
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
namespace bp = boost::process;

bool serverLoaded = false;
bool connectionEstablished = false;
extern float execution_step_size;
extern std::vector<std::unique_ptr<Finken>> simFinken;
std::unique_ptr<tcp::iostream> sPtr;
VrepLog vrepLog;
paparazziPacket firstPacket;
bp::child pprzServer;
bp::child gcs;
std::vector<std::unique_ptr<bp::child>> paparazziClients;
std::string pprzHome=std::getenv("PAPARAZZI_HOME");
std::string start_server_cmd = pprzHome + "/sw/ground_segment/tmtc/server";
std::string start_gcs_cmd = pprzHome + "/sw/ground_segment/cockpit/gcs";
std::string start_nps_cmd = pprzHome + "/sw/simulator/pprzsim-launch";
unsigned int connectedFinkenCount = 0;
bool firstStartUp = true;
extern std::atomic<unsigned int> readyFinkenCount;
extern std::condition_variable notifier;
extern std::mutex vrepMutex;

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
        if(!sPtr){
            sPtr.reset(new tcp::iostream());
        }        
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
                    try{
                        pFinken->connect(std::move(sPtr));
                        std::cout << "started a finken" << std::endl;
                        connectionEstablished = true;
                        connectedFinkenCount++;
                    }
                    catch(std::exception e){
                        std::cout << "error connecting finken" << std::endl;
                    }
                }
            }   
            if(matchingCopterFound == false) {
                std::cerr << "no matching copter was found" <<std::endl;
            }
                        
        }
        else{
            std::cerr << "error in accept handler: " << error.category().message(error.value()) << std::endl;
        }
        sPtr.reset(new tcp::iostream());
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
    /** The io service for the server. */
    boost::asio::io_service io_service;
    /** Pointer to the server responsible for communication with Paparazzi. */
    std::unique_ptr<Async_Server> async_server;
    /** Empty constructor */
    FinkenPlugin() {}
    /** No copying the Finkenplugin. */
    FinkenPlugin& operator=(const FinkenPlugin&) = delete;
    /** No copying the Finkenplugin. */
    FinkenPlugin(const FinkenPlugin&) = delete;
    /** Destructor. */
    virtual ~FinkenPlugin() {}
    /* Version */
    virtual unsigned char version() const { return 1; }

    /** Loads the plugin into V-REP.
     * @returns true
    */
    virtual bool load() {
      Log::name(name());
      std::string date = __DATE__;
      Log::out() << "loaded v " << date << std::endl;
      return true;
    }
    /** unloads the plugin 
     * @returns true
    */
    virtual bool unload() {
      if (serverLoaded){io_service.stop();}
      Log::out() << "unloaded" << std::endl;
      return true;
    }
    /** Function returning the name of the plugin .
     * @returns Name as a string.
    */
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
            std::cout << start_server_cmd << '\n';
            pprzServer = bp::child(start_server_cmd, "-n");
            gcs = bp::child(start_gcs_cmd);
        }
        else {
            vrepLog << "[VREP] ScriptLoader not found, not starting server" << '\n';
        }
    std::cout << "sceneload done" << '\n';
	return NULL;
    }

    /** Called when the Simulation is started. */
    void* simStart(int* auxiliaryData,void* customData,int* replyData)
    {   
        
	    return NULL;
    }

    /**
     * Ends the simulation run and cleans up the server and FINken
     */
    void* simEnd(int* auxiliaryData,void* customData,int* replyData)
    {
        std::cerr << "[VREP] ending sim, resetting server" << std::endl;
	    vrepLog << "[VREP] ending sim, resetting server" << std::endl;
        std::cerr << "[VREP] clearing paparazzi clients" << std::endl;
        paparazziClients.clear();
        //stopping and resetting the ioservice cleans up the server and any connections
        io_service.stop();
        io_service.reset();
        //reset the mutex to pre-Sim status        
        std::cerr << "[VREP] clearing finken" << std::endl;
        while(simFinken.size() > 0){
             simFinken.clear();
        }
        
        
        readyFinkenCount = 0;
        connectedFinkenCount = 0;        
        firstStartUp = true;      
        //restart the ioservice to prepare for a new simulation
        boost::thread(boost::bind(&boost::asio::io_service::run, &io_service)).detach();
	    vrepLog << "[VREP] successfully reset server" << std::endl;

        //pprzServer.terminate();
        //gcs.terminate();
        
        return NULL;
    }
    /**
     * This function controls the other parts of the plugin and synchronizes the vrep copters with the paparazzi copters.
     */
    void* action(int* auxiliaryData,void* customData,int* replyData){ 
	    try {   
            if (firstStartUp) {
                firstStartUp = false;
                for(auto&& pFinken : simFinken) {            
                    std::cout << "starting sim" << '\n';
                    if(!pFinken->connected){                    
                        std::cout << "trying to pair copter #" << pFinken->ac_id << '\n';
                        paparazziClients.emplace_back(new bp::child(start_nps_cmd, "-a", pFinken->ac_name, "-t", "nps"));
                    }
                } 
            }        
		    vrepLog << "[VREP] simulated copters: " << simFinken.size() << std::endl;
        	auto actionStart = Clock::now();
            
	        // if there is no finken connected to paparazzi yet, we do nothing:
	        if(std::none_of(simFinken.begin(), simFinken.end(), 
              [](const std::unique_ptr<Finken>& f){ return f->connected;}) )
            return NULL;
	        auto then = Clock::now();
	        //we wait for paparazzi to send us some commands:
            
            std::unique_lock<std::mutex> lock(vrepMutex);
            
            while(readyFinkenCount!=connectedFinkenCount) {
                notifier.wait(lock);
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
	        readyFinkenCount = 0;
            for(auto&& pFinken : simFinken){
                pFinken->finkenMutex.unlock();
            }
            
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
