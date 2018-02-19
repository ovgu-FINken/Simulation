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
#include <condition_variable>
#include <chrono>
#include <Eigen/Dense>
#include <atomic>
#include <boost/filesystem.hpp>
#include <boost/filesystem/fstream.hpp>

using boost::filesystem::ofstream;
using boost::filesystem::current_path;
using boost::asio::ip::tcp;
using Clock = std::chrono::high_resolution_clock;

extern std::atomic<bool> sendSync;
extern std::atomic<bool> readSync;

class LogLine {
  private:
    std::ostream& o;

  public:
    LogLine(std::ostream& o) : o(o) {}
    ~LogLine(){
      o <<  ";";
    }
    LogLine& operator<<(std::ostream&(*pf)(std::ostream&)) {
      o << pf;
      return *this;
    }
    template<typename T>
    LogLine& operator<<(T t) {
      o << t;
      return *this;
    }
  friend class VrepLog;
};

class VrepLog {
  private:
    std::ofstream log;
  public:
    VrepLog() {
      log.open((current_path() / "vrep.log").c_str());
    }
    template<typename T>
    LogLine operator<<(T& t) {
      return log << Clock::now().time_since_epoch().count() << ", " << t;
    }
};
extern VrepLog  vrepLog;

class Finken
{
private:
     std::vector<std::unique_ptr<Sensor>> sensors;
     std::vector<std::unique_ptr<Rotor>> rotors;
public:
    Finken();
    Finken(int fHandle, int _ac_id);
    ~Finken();
    int handle, baseHandle;
    int ac_id;
    std::vector<double> commands = {0,0,0,0};
    std::vector<double> pos = {-1,-1,-1};
    std::vector<double> quat = {-1,-1,-1,-1};
    std::vector<double> vel = {-1,-1,-1};
    std::vector<double> rotVel ={-1,-1,-1};
    std::vector<double> accel = {-1,-1,-1};
    std::vector<double> rotAccel ={-1,-1,-1};
    void addSensor(std::unique_ptr<Sensor> &sensor);
    void addRotor(std::unique_ptr<Rotor> &rotor);
    void run(std::unique_ptr<tcp::iostream> sPtr);
    void setRotorSpeeds();
    void updatePos(Finken& finken);
    std::vector<std::unique_ptr<Sensor>> &getSensors();
    std::vector<std::unique_ptr<Rotor>> &getRotors();
    Finken(const Finken&) = delete;
    Finken& operator=(const Finken&) = delete;
};

void buildFinken(Finken& finken, int handle);
static std::vector<std::unique_ptr<Finken>> allFinken;
double thrustFromThrottle(double throttle);

#endif // FINKEN_H
