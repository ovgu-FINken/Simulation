#pragma once 
#include <vector>
#include <iostream>
#include <boost/random.hpp>
#include <dataPacket.h>
#include <Eigen/Core>

/** 
 * @file sensor.h 
 * \class Sensor
 * \brief base Sensor class, all sensors should inherit from this
 */

class Sensor
{
private: 
    std::vector<float> values; ///< Vector cointaining the sensor values, not all fields used by all sensors!
protected:
    using Vec3 = Eigen::Matrix<float, 1, 3>;
    int handle;  ///< Handle to access the sensor in vrep    
    double sigma; ///< Maximum error value [-sigma, sigma] to add to any sensor data
    boost::random::uniform_real_distribution<> dist; ///< The random distribution used to calculate sensor errors
    boost::random::mt19937& gen; ///< reference to the random number generator of the FINken this sensor belongs to
public:
    /** Basic constructor
     * @param sensorHandle The handle of the object the acceleration is measured for
     * @param sigma The maximum error to add to any sensor values
     * @param gen Reference to the random number generator of the FINken this sensor belongs to
     */
    Sensor(int sensorHandle, double sigma, boost::random::mt19937& gen) : handle(sensorHandle), sigma(sigma), dist(boost::random::uniform_real_distribution<> {-sigma, sigma}), gen(gen) {};
    
    SensorTypes sensorType; ///<< The sensorType of the specific sensor

    /**
     * Calls for V-REP tp update the sensor information. \n 
     * see specific sensor documentation for more information
     */
    virtual void update()=0;
    
    /**
     * Retrieves the sensor information, without applying the sensor noise.
     * See specific sensor documentation for more information.
     */
    virtual std::vector<float> get_without_error()=0;
    
    /**
     * Retrieves the sensor information including noise. \n 
     * See specific sensor documentation for more  information.
     */
    virtual std::vector<float> get()=0;
    
    /** Retrieves the sensor handle. */
    virtual int getHandle(){
        return handle;
    }

};
