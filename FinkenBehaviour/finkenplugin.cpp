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
std::condition_variable cv;
std::mutex cv_m, syncMutex;

struct Sync {
  private:
    Eigen::Matrix<bool, Eigen::Dynamic, 1> mData;

  public:
    size_t extend() { 
      std::unique_lock<std::mutex> lk(syncMutex); 
      size_t i = mData.rows(); 
      mData.resize(i+1, 1); 
      mData(i) = false; 
      return i;
    }
    void set(size_t i) { 
      std::unique_lock<std::mutex> lk(syncMutex);
      mData(i)=true;
    }
    operator bool() const { 
      std::unique_lock<std::mutex> lk(syncMutex);
      return mData.prod();
    }
    void clear() {
      std::unique_lock<std::mutex> lk(syncMutex);
      mData.resize(0,1);
    }
  friend std::ostream& operator<<(std::ostream& o, const Sync s);
};
Sync read; 
Sync sent;



class Server{
    void session(std::unique_ptr<tcp::iostream> sPtr){
         std::unique_lock<std::mutex> server_lock(cv_m);
        try  {
        std::cout << "client connected" << std::endl;
        for (;;)    {
            int commands_nb = 0;
            {
                boost::archive::text_iarchive in(*sPtr);
                in >> commands_nb;
                size_t id = read.extend();
                double commands[commands_nb]={};
                for(int i = 0; i< commands_nb; i++) {
                    in >> commands[i];    
                }
                read.set(id);
                cv.notify_all();
                if(cv.wait_for(server_lock, std::chrono::milliseconds(10000), [](){return sent;})) 
                    std::cerr << "Server Sending" << '\n';
                else
                    std::cerr << "Server timed out. id == " << id << '\n';

                std::cout << " commands received: [";
                for(int i=0;i<commands_nb;i++){
                    std::cout << commands[i] << ((i==commands_nb-1)?"":", ");
                }
                std:: cout << "]" << std::endl;
                sent(i) = false;
            //std::unique_lock<std::mutex> lk(cv_m);
            //cv.wait_for(lk, std::chrono::milliseconds(5000));
            //std::cerr << "Server finished waiting, replying" << '\n';

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
public:
void server(boost::asio::io_service& io_service, unsigned short port){
  tcp::acceptor a(io_service, tcp::endpoint(tcp::v4(), port));
  for (;;)  {
    std::unique_ptr<tcp::iostream> sPtr;
    sPtr.reset(new tcp::iostream());
    a.accept(*sPtr->rdbuf());
    std::thread(std::bind(&Server::session, this, std::placeholders::_1), std::move(sPtr)).detach();
  }
}
};


Server server;
boost::asio::io_service io_service;





class FinkenPlugin: public VREPPlugin {
  public:
    std::unique_lock<std::mutex> vrep_lock(cv_m);    
    boost::asio::io_service io_service;
    FinkenPlugin() {}
    FinkenPlugin& operator=(const FinkenPlugin&) = delete;
    FinkenPlugin(const FinkenPlugin&) = delete;
    virtual ~FinkenPlugin() {}
    virtual unsigned char version() const { return 1; }
    virtual bool load() {
      Log::name(name());
      Log::out() << "loadeda" << std::endl;
      return true;
    }
    virtual bool unload() {

      Log::out() << "unloaded" << std::endl;
      return true;
    }
    virtual const std::string name() const {
      return "Finken Plugin";
    }

    void* simStart(int* auxiliaryData,void* customData,int* replyData)
    {

        simAddStatusbarMessage("finken in creation");
        allFinken.push_back(std::move(buildFinken()));
        simAddStatusbarMessage("finken finished");
        std::thread t1(std::bind(&Server::server, server, std::placeholders::_1, std::placeholders::_2),std::ref(io_service), 50013);
        t1.detach();
        //server.server(io_service,50013);
        std::cout << "we never get this";
        return NULL;
    }


    void* action(int* auxiliaryData,void* customData,int* replyData)
    {   /*
        simple test code, ignore for now
        std::vector<float> f = {1,2,3,4};
        std::vector<float> ff = {1,2,3};
        std::vector<float> vforce = {0,0,1.5};

        int i =0;
        PositionSensor ps = PositionSensor(allFinken.at(0)->handle);
        ps.get(f);
        std::cout << f.at(0) << "   " << f.at(1) << f.at(2) << '\n';

        allFinken.at(0)->getSensors().at(0)->get(f, i, ff);
        allFinken.at(0)->getSensors().at(1)->get(f, i, ff);
        allFinken.at(0)->getSensors().at(2)->get(f, i, ff);
        allFinken.at(0)->getSensors().at(3)->get(f, i, ff);

        std::cout << f.at(0) << "   " << f.at(1) << f.at(2) << f.at(3) << '\n';
        std::cout << i << '\n';
        std::cout << simGetObjectName(i) <<'\n';
        std::cout << '\n';

        for(int i=0; i<4; i++){
            allFinken.at(0)->getRotors().at(i)->set(vforce, vtorque);
        }
        */
        
        sent.resize(allFinken.size(), 1);
        sent(0) = true;
        read(0) = false;
        cv.notify_all();
        simPauseSimulation;
        if(cv.wait_for(vrep_lock, std::chrono::milliseconds(10000), [](){return read;})) {
            std::cerr << "Server Receiving" <<'\n';
            simStartSimulation;
        }
        else {
            std::cerr << "Server timed out. (Receiveing)"'\n';
            simStopSimulation;
        }
        //do: send position to vrep, get commands
        
        Eigen::Vector4f motorCommands(0.0,0.0,0.0,0.0);

        Eigen::Matrix<float, 4, 4> mixingMatrix;
        /*
        taken from fink3.xml, paparazzi generated xml says something different 
        check with https://wiki.paparazziuav.org/wiki/Rotorcraft_Configuration#Motor_Mixing
        */
        mixingMatrix << -256, -256,  256, 256,
                         256, -256, -256, 256,
                        -256,  256, -256, 256,
                         256,  256,  256, 256;
        
        motorCommands = mixingMatrix * motorCommands;

        execution_step_size = simGetSimulationTimeStep();
        
        /* this will probably need some scaling */
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
        return NULL;
    }

} plugin;
