/** 
 * @file finken.h 
 * \brief header for the finken implementation
 */


#ifndef FINKEN_H
#define FINKEN_H
#include <memory>
#include <cstdlib>
#include <iostream>
#include <thread>
#include <memory>
#include <utility>
#include <boost/asio.hpp>
#include <condition_variable>
#include <chrono>
#include <atomic>
#include <boost/filesystem.hpp>
#include <boost/filesystem/fstream.hpp>
#include <boost/archive/binary_oarchive.hpp>
#include <boost/archive/binary_iarchive.hpp>
#include <mutex>
#include <vector>
#include <v_repLib.h>
#include "dataPacket.h"
#include "sensor.h"
#include "sonar.h"
#include "heightsensor.h"
#include "rotor.h"
#include "positionsensor.h"



#pragma GCC diagnostic ignored "-Wint-in-bool-context"
#include <Eigen/Dense>
#pragma GCC diagnostic pop

using boost::filesystem::ofstream;
using boost::filesystem::current_path;
using boost::asio::ip::tcp;
using Clock = std::chrono::high_resolution_clock;

extern std::timed_mutex sendSync;
extern std::timed_mutex readSync;


/**
 *  \brief Class for annotating log with time points
 *  \todo cleanup code from superfluous debug logging
 */
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

/**
 * \brief Class for creating a log file
 * \todo cleanup code from superfluous debug logging
 */
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

/**
 * Finken class for handling any data exchanges between a
 * FINken and paparazzi. Also handles the application of
 * rotor mixing commands to the FINken.
 */
class Finken
{
private:
     std::vector<std::unique_ptr<Sensor>> sensors;
     std::vector<std::unique_ptr<Rotor>> rotors;
public:
    /** Basic Empty Constructor */
    Finken();
    /**
     * Constructor for creating a uniquely identifiable finken
     * @param fHandle the handle used to identify the finken in vrep
     * @param _ac_id the Aircraft ID used to identify the copter in paparazzi
     */
    Finken(int fHandle, int _ac_id, int rotorCount, int sonarCount);
    /** Basic destructor */
    ~Finken() { runThread.join(); }
    /** Integer representing the handle of the copter object in vrep */
    int handle;
    /** Integer representing the handle of the copter base in Vrep.
     * Copter base, not the copter object is used for the calculation of the copter state.
     */
    int baseHandle;    
    /** Integer representing the Aircraft ID to match copters in vrep and paparazzi */
    const int ac_id;
    /**Integer representing the amount of rotors, used in automatic finken construction
     * @see buildFinken()
     */
    const int rotorCount;
    /**Integer representing the amount of sonars, used in automatic finken construction**
     * @see buildFinken
     * /
    **/
    const int sonarCount;
    /** current connection status of the copter **/
    bool connected = 0;
    std::thread runThread;
    /** Vector storing the commands provided by paparazzi */
    std::vector<double> commands = {0,0,0,0};
    /** 
     * @anchor copterstate
     * @name Copter state
     * Members representing the current copter state
     */
    ///@{
    /** Copter position (ENU) */
    std::vector<double> pos = {-1,-1,-1};
    /** Copter Quaternion */
    std::vector<double> quat = {-1,-1,-1,-1};
    /** Copter velocity */
    std::vector<double> vel = {-1,-1,-1};
    /** Copter rotational velocity (aka angular velocity) */
    std::vector<double> rotVel ={-1,-1,-1};
    /** Copter acceleration */
    std::vector<double> accel = {-1,-1,-1};
    /** Copter rotational acceleration (aka angular acceleration) */
    std::vector<double> rotAccel ={-1,-1,-1};
    ///@}
    
    /**@name Construction functions
     * Functions needed to construct the copter in the vrep plugin
     * @see buildFinken()
     */
    ///@{
    /** Adding sensors to the copter. */
    void addSensor(std::unique_ptr<Sensor> &sensor);
    /** Adding rotors to the copter. */
    void addRotor(std::unique_ptr<Rotor> &rotor);
    ///@}    

    /**
     * Called in the accept handler, this function passes the incoming connection 
     * to the corresponding finken in a new thread
     */
    void connect(std::unique_ptr<tcp::iostream>&& sPtr) {
      connected=1;
      auto helper=[this,&sPtr](){run(std::move(sPtr));};
      runThread=std::move(std::thread(helper));
    }

    /**
     * Main function containing the paparazzi-vrep communication loop.
     * Called whenever a new connection from paparazzi to the
     * vrep server is established, see Async_Server::handle_accept()
     * @param sPtr the iostream of the connection
     * @see Async_Server::handle_accept()
     * 
     */
    void run(std::unique_ptr<tcp::iostream> sPtr);
    /**
     * Applies the correct rotor speeds calculated by paparazzi
     * @see Finken::commands
     * @see thrustFromThrottle
     */
    void setRotorSpeeds();
    /**
     * updates the values for copter position and attitude, 
     * namely the @ref copterstate "copter state" vectors
     * @param finken reference to the finken to be updated
     */
    void updatePos(Finken& finken);
    /** returns a vector containing all sensors of the finken */
    std::vector<std::unique_ptr<Sensor>> &getSensors();
    /** returns a vector containing all rotors of the finken */
    std::vector<std::unique_ptr<Rotor>> &getRotors();
    /** @private */
    Finken(const Finken&) = delete;
    /** @private */
    Finken& operator=(const Finken&) = delete;
};
/**
 * identifies a copter in the vrep scene using its handle and constructs it.
 * Built finken are stored in #allFinken
 * @see Finken::addRotor()
 * @see Finken::addSensor()
 */
void buildFinken(Finken& finken);

/** static vector containing all built finken */
static std::vector<std::unique_ptr<Finken>> allFinken;

/**
 * Calculates thrust forces (Newton) from the rotor commands
 * @see Finken::commands
 */
double thrustFromThrottle(double throttle);

#endif // FINKEN_H
