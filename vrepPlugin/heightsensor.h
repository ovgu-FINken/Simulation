#pragma once

#include "sensor.h"
#include <boost/random.hpp>

/**
 * Class implementing a heightsensor
 */
class HeightSensor: public Sensor{
private:
    /**
     * Vector containing the sensor values. \n
     * For this sensor, this vector only has 1 element, height.
     */    
    std::vector<float> values;  
    
    /**
     * Vector used to retrieve the position, the height is then stored
     * in HeightSensor#values
     */
    std::vector<float> positionValues;
public:
    /** Basic constructor
     * @param sensorHandle The handle of the object the acceleration is measured for
     * @param sigma The maximum error to add to any sensor values
     * @param gen Reference to the random number generator of the FINken this sensor belongs to
     */
    HeightSensor(int sensorHandle, double sigma, boost::random::mt19937& gen);
    
    /**
     * Updates the sensor information, including any detected object information.
     * See the <a href="http://www.coppeliarobotics.com/helpFiles/en/regularApi/simReadProximitySensor.htm">V-REP API</a> for more info.
     */
    void update();
    
    /**
     * Retrieves the last known sensor values, including sensor noise.
     * \returns The HeightSensor#values vector with added error values.
     */
    std::vector<float> get();
    
    /**
     * Retrieves the last known sensor values without error.
     * @returns The HeightSensor#values vector, not including error values.
     */
    std::vector<float> get_without_error();


};


