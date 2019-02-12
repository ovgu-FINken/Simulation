#pragma once 
#include <vector>
#include <iostream>
#include <boost/random.hpp>
#include <dataPacket.h>

/** 
 * @file sensor.h 
 * \class Sensor
 * \brief base Sensor class, all sensors should inherit from this
 */

class Sensor
{
protected:
    int handle;  ///< Handle to access the sensor in vrep
    std::vector<float> values; ///< Vector cointaining the sensor values, not all fields used by all sensors!  
    double sigma;
    boost::random::uniform_real_distribution<> dist;
    boost::random::mt19937& gen;
public:
    /** 
     * Constructor. 
     * @param sensorHandle the handle of the sensor in vrep
     * */
    Sensor(int sensorHandle, double sigma, boost::random::mt19937& gen) : handle(sensorHandle), sigma(sigma), dist(boost::random::uniform_real_distribution<> {-sigma, sigma}), gen(gen) {
        values = {0,0,0,0};
    }
    //the sensorType of the specific sensor
    SensorTypes sensorType;

    virtual void update()=0;
    /**
     * retrieves the sensor information, without applying the sensor noise
     * see specific sensor documentation for more information
     */
    virtual std::vector<float> get_without_error()=0;
    /**
     * retrieves the sensor information including noise;
     * see specific sensor documentation for more  information
     */
    virtual std::vector<float> get()=0;
    
    /** Retrieves the sensor handle. */
    virtual int getHandle(){
        return handle;
    }

};
