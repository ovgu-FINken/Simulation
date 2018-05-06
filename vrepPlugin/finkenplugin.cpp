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


/**
* Deletes a Finken object and stores the corresponding handle
*
* @param finken
*/
void deleteFinken(std::unique_ptr<Finken>& finken){
    vrepLog << "attempting to erase finken " <<finken->handle << std::endl;
    simCopters.emplace_back(std::make_pair(finken->ac_id, finken->handle));
    allFinken.erase(std::remove(allFinken.begin(), allFinken.end(), finken),allFinken.end());
}
/**
 * Asynchronous (boost::Asio) Server class to accept new paparazzi connections and pair them with a vrep copter.
 * @see Finken::run()
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
        simAddStatusbarMessage("Server ready to accept new connection");
        sPtr.reset(new tcp::iostream());
        acceptor_.async_accept(*sPtr->rdbuf(), boost::bind(&Async_Server::handle_accept, this, boost::asio::placeholders::error));
        simAddStatusbarMessage("Server ready to accept new connection");
    }
    /** 
     * Function handling any new connection.
     * This then runs Finken::run() in a new separate thread.
     * @see Finken::run() 
     */
    void handle_accept(const boost::system::error_code& error){
        if(!error){
            simAddStatusbarMessage("New connection established");
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
      return true;
    }
    /** unloads the plugin */
    virtual bool unload() {
      async_server.reset(nullptr);
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
        vrepLog << "ScriptLoader check" << '\n' ;
        std::string dummyName = "ScriptLoader";
        int handle = simGetObjectHandle(dummyName.c_str());
        std::cout << handle << '\n';
        if (handle > 0){
            vrepLog << "ScriptLoader found, starting asynchronous vrep server" << '\n' ;
            async_server.reset(new Async_Server(io_service));
            boost::thread(boost::bind(&boost::asio::io_service::run, &io_service)).detach();
            vrepLog << "server done" << '\n';
        }
        else {
            vrepLog << "ScriptLoader not found, not starting server" << '\n';
        }
    std::cout << "sceneload done" << '\n';
	return NULL;
    }

    void* simStart(int* auxiliaryData,void* customData,int* replyData)
    {	
	return NULL;
    }

    void* simEnd(int* auxiliaryData,void* customData,int* replyData)
    {
        allFinken.clear();
        simCopters.clear();
	vrepLog << "[VREP] ending sim, resetting server" << std::endl;
        io_service.stop();
        io_service.reset();
        boost::thread(boost::bind(&boost::asio::io_service::run, &io_service)).detach();
	vrepLog << "[VREP] successfully resetted server" << std::endl;
        return NULL;
    }
    /**
     * This function controls the other parts of the plugin and synchronizes the vrep copters with the paparazzi copters.
     */
    void* action(int* auxiliaryData,void* customData,int* replyData)
    {   
	vrepLog << "[VREP] connected copters: " << allFinken.size() << " still available copters: " <<  simCopters.size() << std::endl;
        auto actionStart = Clock::now();
        // if there is no finken connected to paparazzi yet, we do nothing:
        while(allFinken.size() == 0){
            vrepLog << "[VREP] waiting for finken creation. Available copters for pairing: " << simCopters.size() << '\n';
	    	std::this_thread::sleep_for(std::chrono::milliseconds(2000));
		    //doNothing;
	    }
    	//vrepLog << "vrep pass done, copter count:" << allFinken.size() <<  '\n';
        auto then = Clock::now();
        //we wait for paparazzi to send us some commands:
        while (!readSync.load()){
       		std::this_thread::sleep_for(std::chrono::milliseconds(1));
   	    }
        auto now = Clock::now();
        vrepLog << "[VREP] time vrep is waiting for finken: " << std::chrono::nanoseconds(now-then).count()/1000000 << "ms" << std::endl;
        then =Clock::now();

        //we apply those commands
        for(int i = 0; i<allFinken.size(); i++){
            allFinken.at(i)->setRotorSpeeds();
        }
        //position data can be sent now
        sendSync=true;
        //command data is outdated now
        readSync = false;
        now = Clock::now();
        vrepLog << "[VREP] time setting rotor forces: " << std::chrono::nanoseconds(now-then).count()/1000000 << "ms" << 
        std::endl;
        vrepLog << "[VREP] time total finkenplugin action(): " << std::chrono::nanoseconds(now - actionStart).count()/1000000 << "ms" << std::endl;

        return NULL;
    }

} plugin;
