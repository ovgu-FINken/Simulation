/** 
 * @file positionsensor.h 
 * \class PositionSensor
 * \brief Implementation of a postion sensor (gps)
 * Implements a basic position sensor.
 */

#pragma once
#include "sensor.h"



class PositionSensor: public Sensor{

private:
    /**
     * Vector containing the sensor values. \n
     * Elements represent the x and y coordinates of the copter.
     */    
    std::vector<float> values;  
        
    /**
     * Vector used to retrieve the position, the xand y values are then stored
     * in PositionSensor#values
     */
    std::vector<float> positionValues;

public:
    /** Basic constructor
     * @param sensorHandle The handle of the object the acceleration is measured for
     * @param sigma The maximum error to add to any sensor values
     * @param gen Reference to the random number generator of the FINken this sensor belongs to
     */
    PositionSensor(int sensorHandle, double sigma, boost::random::mt19937& gen);

    /**
     * Calls V-REP to update the sensor information and sotres it in the AttitudeSensor#values vector.
     * See the <a href="http://www.coppeliarobotics.com/helpFiles/en/regularApi/simGetObjectPosition.htm">V-REP API</a> for more info. 
     */
    void update();

    /**
     * Retrieves the sensor information, including sensor noise
     * \returns The PositionSensor#values vector, including error values for each element 
     */
    std::vector<float> get();

    /**
     * Retrieves the sensor information, not including sensor noise
     * \returns The PositionSensor#values vector not including error values
     */
    std::vector<float>get_without_error();

};





