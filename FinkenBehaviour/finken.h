#ifndef FINKEN_H
#define FINKEN_H
#include "sensor.h"
#include <memory>
#include "sonar.h"
#include "heightsensor.h"
#include <rotor.h>
#include "finkenPID.h"
#include "positionsensor.h"
#include <v_repLib.h>
#include <cstdlib>
#include <iostream>
#include <thread>
#include <memory>
#include <utility>
#include <boost/asio.hpp>
#include <boost/archive/text_oarchive.hpp>
#include <boost/archive/text_iarchive.hpp>
#include <condition_variable>
#include <chrono>
#include <Eigen/Dense>
#include <atomic>

using boost::asio::ip::tcp;

extern std::condition_variable cv;
extern std::mutex cv_m, syncMutex;
extern std::atomic<bool> sendSync;
    
struct MultiSync {
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
    void unSet(size_t i) {
      std::unique_lock<std::mutex> lk(syncMutex);
      mData(i)=false;
    }
    operator bool() const { 
      std::unique_lock<std::mutex> lk(syncMutex);
      return mData.prod();
    }
    void clear() {
      std::unique_lock<std::mutex> lk(syncMutex);
      mData.resize(0,1);
    }
  friend std::ostream& operator<<(std::ostream& o, const MultiSync s);
};
extern MultiSync readSync;


void ecef_from_enu(Eigen::Vector3f& ecef_coord, Eigen::Vector3f& enu_coord);



class Finken
{
private:
     std::vector<std::unique_ptr<Sensor>> sensors;
     std::vector<std::unique_ptr<Rotor>> rotors;
public:
    Finken(); 
    Finken(int fHandle, int _ac_id);
    ~Finken();
    int handle;
    int ac_id;
    std::array<double,4> commands = {};
    std::array<double,6> pos = {};
    void addSensor(std::unique_ptr<Sensor> &sensor);
    void addRotor(std::unique_ptr<Rotor> &rotor);
    void run(std::unique_ptr<tcp::iostream> sPtr);
    void setRotorSpeeds();
    void updatePos(Finken& finken);
    std::vector<std::unique_ptr<Sensor>> &getSensors();
    std::vector<std::unique_ptr<Rotor>> &getRotors();
    Finken(const Finken&) = delete;
    Finken& operator=(const Finken&) = delete;
    	
    finkenPID pitchController;
    finkenPID rollController;
    finkenPID yawController;
    finkenPID targetXcontroller;
    finkenPID targetYcontroller;
    finkenPID targetZcontroller;
};

void buildFinken(Finken& finken, int handle);
static std::vector<std::unique_ptr<Finken>> allFinken;


#endif // FINKEN_H
