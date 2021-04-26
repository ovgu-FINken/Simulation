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
#include <boost/archive/archive_exception.hpp>
#include <boost/random.hpp>
#include <mutex>
#include <vector>
#include <stubs.h>
#include "dataPacket.h"
#include "sensor.h"
#include "sonar.h"
#include "heightsensor.h"
#include "rotor.h"
#include "positionsensor.h"
#include "accelerometer.h"
#include "attitudesensor.h"

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wint-in-bool-context"

using boost::filesystem::ofstream;
using boost::filesystem::current_path;
using boost::asio::ip::tcp;
using Clock = std::chrono::high_resolution_clock;

/**
 *  \brief Class for annotating log with time points
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
 */
class FinkenLog {

  private:
    std::ofstream log;

  public:
    FinkenLog(int ac_id) {
      log.open( ( current_path() / ( std::string("finken_") + std::to_string(ac_id) + ".log" ) ).c_str() );
    }
    template<typename T>
    LogLine operator<<(T& t) {
      return log << Clock::now().time_since_epoch().count() << ", " << t;
    }
};

/**
 * Finken class for handling any data exchanges between a
 * FINken and Paparazzi. Also handles the application of
 * rotor mixing commands to the FINken.
 */
class Finken {

  protected:
     std::vector<std::unique_ptr<Sensor>> sonars;
     std::vector<std::unique_ptr<Rotor>> rotors;

    /** Current connection status of the copter. **/
    bool _connected = false;

    /** Datapacket used to send information to paparazzi 
     * See datapacket.h
     */
    vrepPacket outPacket;
    /** Datapacket used to receive information from paparazzi 
     * See datapacket.h
     */
    paparazziPacket inPacket;
    /** Integer representing the handle of the copter object in V-REP */
    int handle;

    /** Integer representing the handle of the copter base in V-REP.
     *  Copter base, not the copter object is used for the calculation of the copter state.
     */
    int baseHandle;

    FinkenLog log;


    /** pointer to heightSensor **/
    std::unique_ptr<HeightSensor> heightSensor;

    /** pointer to accelerometer **/
    std::unique_ptr<Accelerometer> accelerometer;

    /** pointer to positionSensor **/
    std::unique_ptr<PositionSensor> positionSensor;

    /** pointer to positionSensor **/
    std::unique_ptr<AttitudeSensor> attitudeSensor;

    /** The thread object for running the copter loop. */
    std::thread runThread;

    /** Random number generator */
    boost::random::mt19937 gen;

    /** Vector storing the commands provided by Paparazzi */
    std::vector<double> commands = {0,0,0,0};

    enum class CurrentActivity {
      SIM,
      CONTROL,
      NONE
    };

    /** Mutex for the copter synchronization */
    std::mutex mutex;
    std::atomic<CurrentActivity> currentActivity = CurrentActivity::SIM;
    std::condition_variable notifier;
    std::condition_variable& simNotifier;

    /** 
     * @anchor copterstate
     * @name Copter state
     * Members representing the current copter state
     */
    ///@{
    /** Copter position (ENU) */
    std::vector<float> pos = {-1,-1,-1};
    /** Copter Quaternion */
    std::vector<float> quat = {-1,-1,-1,-1};
    /** Copter velocity */
    std::vector<float> vel = {-1,-1,-1};
    /** Copter rotational velocity (aka angular velocity) */
    std::vector<float> rotVel ={-1,-1,-1};
    /** Copter acceleration */
    std::vector<float> accel = {-1,-1,-1};
    /** Copter rotational acceleration (aka angular acceleration) */
    std::vector<float> rotAccel ={-1,-1,-1};
    ///@}

public:
    /** Integer representing the Aircraft ID to match copters in V-REP and Paparazzi. */
    const int ac_id;

    /** The name of the aircraft */
    const std::string ac_name;

    /** Basic Empty Constructor */
    Finken();
    /**
     * Constructor for creating a uniquely identifiable FINken.
     * @param fHandle the handle used to identify the FINken in V-REP.
     * @param _ac_id the Aircraft ID used to identify the copter in Paparazzi.
     * @param ac_name the name of the aircraft in the vrep scene
     */
    Finken(int fHandle, int _ac_id, const std::string& ac_name, std::condition_variable& simNotifier);
    /** Basic destructor */
    ~Finken() {
        //make sure future loops wont block because of a nonexisting copter
        currentActivity = CurrentActivity::SIM;
        _connected = false;
        runThread.join();
    }

    /** Throttlevalues for the motors built into the FINken */
    static constexpr std::array<double,6> throttlevalues = {0, 0.5, 0.65, 0.75, 0.85, 1};
    /** Thrust values in Newton coressponding to the trottle values */
    static constexpr std::array<double,6> thrustvalues = {0, 0.92,1.13,1.44,1.77,2.03};

    void control() {
      currentActivity = CurrentActivity::CONTROL;
      notifier.notify_all();
    }

    bool connected() const {
      return _connected;
    }

    bool ready() const{
      return currentActivity.load() == CurrentActivity::SIM;
    }

    /**@name Construction functions
     * Functions needed to construct the copter in the V-REP plugin
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
      _connected=true;
      currentActivity = CurrentActivity::SIM;
      auto helper=[this,&sPtr](){run(std::move(sPtr));};
      runThread=std::thread(helper);
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

    /**
     * Calculates thrust forces (Newton) from the rotor commands
     * @see Finken::commands
     */
    static double thrustFromThrottle(double throttle);
    friend void buildFinken(Finken&);
};
/** Constructs a complete FINken from an empty FINken object using its handle.
 *  Takes a unique_ptr to a Finken and adds the correct handles for the sensors & rotors from the V-REP object tree.
 *  @param finken the FINken object to be populated.
 */
void buildFinken(Finken& finken);




