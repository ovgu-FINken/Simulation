/** 
 * @file sonar.h 
 * \class Sonar
 * \brief implementation of a proximitysensor as sonar
 * \todo implement paparazzi counterpart to accept sonar data
 */

#pragma once

#include "sensor.h"
#include <string>

class Sonar: public Sensor{

  private:
    /**
     * Vector containing the sensor values. \n
     * Elements represent the position of (0-2) and distance to (3) any detected object. \n
     * These can be null if no object is detected.
     */
    std::vector<float> values;

  public:
    /** Basic constructor
     * @param sensorHandle The handle of the object the acceleration is measured for
     * @param sigma The maximum error to add to any sensor values
     * @param gen Reference to the random number generator of the FINken this sensor belongs to
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
