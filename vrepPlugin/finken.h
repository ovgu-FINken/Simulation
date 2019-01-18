/** 
 * @file finken.h 
 * \brief header for the finken implementation
 */


#pragma once
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
#include <boost/random.hpp>
#include <mutex>
#include <vector>
#include <v_repLib.h>
#include "dataPacket.h"
#include "sensor.h"
#include "sonar.h"
#include "heightsensor.h"
#include "rotor.h"
#include "positionsensor.h"
#include "accelerometer.h"



#pragma GCC diagnostic ignored "-Wint-in-bool-context"
#include <Eigen/Dense>
#pragma GCC diagnostic pop

using boost::filesystem::ofstream;
using boost::filesystem::current_path;
using boost::asio::ip::tcp;
using Clock = std::chrono::high_resolution_clock;



extern std::mutex readMutex, sendMutex, syncMutex;
extern std::condition_variable cv_read, cv_send;
extern bool readyToSend;

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
    void unset() {
        mData.setZero();
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
extern struct Sync readSync;



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
      log.open((current_path() / "V-REP.log").c_str());
    }
    template<typename T>
    LogLine operator<<(T& t) {
      return log << Clock::now().time_since_epoch().count() << ", " << t;
    }
};
extern VrepLog  vrepLog;

/**
 * Finken class for handling any data exchanges between a
 * FINken and Paparazzi. Also handles the application of
 * rotor mixing commands to the FINken.
 */
class Finken
{
private:
     std::vector<std::unique_ptr<Sensor>> sonars;
     std::vector<std::unique_ptr<Rotor>> rotors;
     

public:
    /** Basic Empty Constructor */
    Finken();
    /**
     * Constructor for creating a uniquely identifiable FINken.
     * @param fHandle the handle used to identify the FINken in V-REP.
     * @param _ac_id the Aircraft ID used to identify the copter in Paparazzi.
     * @param rotorCount the amount of rotors the copter has.
     * @param sonarCount the amount of sonars the copter has.
     */
    Finken(int fHandle, int _ac_id, int rotorCount, int sonarCount, std::string ac_name);
    /** Basic destructor */
    ~Finken() { 
        readSync.set(this->syncID);
        runThread.join();         
    }
    /** Integer representing the handle of the copter object in V-REP */
    int handle;

    /** Integer representing the handle of the copter base in V-REP.
     *  Copter base, not the copter object is used for the calculation of the copter state.
     */
    int baseHandle;    

    /** Integer representing the Aircraft ID to match copters in V-REP and Paparazzi. */
    const int ac_id;

    /** The number of rotors the copter has */
    int rotorCount;

    /** The number of sonars the copter has */
    int sonarCount;

    /** The name of the aircraft */
    std::string ac_name;

    /** Current connection status of the copter. **/
    bool connected = 0;

    /** the ID used for the thread syncrhonization **/
    size_t syncID;

    /** pointer to heightSensor **/
    std::unique_ptr<HeightSensor> heightSensor;

    /** pointer to accelerometer **/
    std::unique_ptr<Accelerometer> accelerometer;

    /** pointer to positionSensor **/
    std::unique_ptr<PositionSensor> positionSensor;

    /** The thread object for running the copter loop. */
    std::thread runThread;

    /** Random number generator */
    boost::random::mt19937 gen;

    /** Vector storing the commands provided by Paparazzi */
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
     * Functions needed to construct the copter in the V-REP plugin
     * @see buildFinken()
     */
    ///@{
    /** Adding sensors to the copter. */
    void addSonar(std::unique_ptr<Sensor> &sensor);
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
     * Main function containing the Paparazzi-V-REP communication loop.
     * Called whenever a new connection from Paparazzi to the
     * V-REP server is established, see Async_Server::handle_accept()
     * @param sPtr the iostream of the connection
     * @see Async_Server::handle_accept()
     * 
     */
    void run(std::unique_ptr<tcp::iostream> sPtr);

    /**
     * Applies the correct rotor speeds calculated by Paparazzi
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
    std::vector<std::unique_ptr<Sensor>> &getSonars();

    /** returns a vector containing all rotors of the finken */
    std::vector<std::unique_ptr<Rotor>> &getRotors();

    /** Deleted copy constructor (FINken objects need to be unique)*/
    Finken(const Finken&) = delete;
    /** Deleted copy assignment operator (FINken objects need to be unique)*/
    Finken& operator=(const Finken&) = delete;
};
/** Constructs a complete FINken from an empty FINken object using its handle.
 *  Takes a unique_ptr to a Finken and adds the correct handles for the sensors & rotors from the V-REP object tree.
 *  @param finken the FINken object to be populated.
 */
void buildFinken(Finken& finken);


/**
 * Calculates thrust forces (Newton) from the rotor commands
 * @see Finken::commands
 */
double thrustFromThrottle(double throttle);


