/** 
 * @file sonar.h 
 * \class Sonar
 * \brief implementation of a proximitysensor as sonar
 * \todo actually use this in the sim
 */

#pragma once
#include "sensor.h"
#include <string>

class Sonar: public Sensor{

public:
    /** Basic constructor
     * @param sensorHandle The handle of the sensor in V-REP
     */
    Sonar(int sensorHandle, double sigma, boost::random::mt19937& gen); 
        
    /**
     * Updates the sensor information, including any detected object information.
     * The detected point is stored in the values vector of the sensor, with values[0-2] as the x,y and z coordinates
     * and values [4] the distance to the point
     * 
     * See the <a href="http://www.coppeliarobotics.com/helpFiles/en/regularApi/simReadProximitySensor.htm">V-REP API</a> for more info. 

     */
    void update();

    /**
     * Retrieves the sensor information, including sensor noise
     * 
     * \returns a vector cointaining the position of any detected object as well as 
     * the distance to that object
     * TODO: handle the case if nothing is detected.
     */
    std::vector<float> get();

    /**
     * Retrieves the sensor information, not including sensor noise
     * 
     * \returns a vector cointaining the position of any detected object as well as 
     * the distance to that object
     * TODO: handle the case if nothing is detected.
     */
    std::vector<float> get_without_error();

};



