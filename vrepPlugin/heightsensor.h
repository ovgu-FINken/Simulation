#pragma once

#include "sensor.h"
#include <boost/random.hpp>

/**
 * Class implementing a heightsensor
 */
class HeightSensor: public Sensor{

public:
    /** Basic constructor.
     * @param sensorHandle the handle of the sensor in V-REP 
     */
    HeightSensor(int sensorHandle, double sigma, boost::random::mt19937& gen);


    /**
     * Retrieves the sensor information, including sensor noise.
     * 
     * \returns a vector with the first field containing the height of the copter
     */
    std::vector<float> get();

    /**
     * Retrieves the sensor information, not including sensor noise.
     * 
     * \returns a vector with the first field containing the height of the copter
     */
    std::vector<float> get_without_error();

    /**
     * Updates the sensor information, including any detected object information.
     * See the <a href="http://www.coppeliarobotics.com/helpFiles/en/regularApi/simReadProximitySensor.htm">V-REP API</a> for more info. 

     */
    void update();
};


