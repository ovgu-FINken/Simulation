/** 
 * @file attitudesensor.h
 * \class AttitudeSensor
 * \brief Implementation of an attitudesensor
 * 
 */

#pragma once

#include "sensor.h"



class AttitudeSensor: public Sensor{

private:
    /**
     * Vector containing the sensor values. \n
     * Elements represent the quaternion of the FINken (x,y,z,w).
     */
    std::vector<float> values;

public:
    /** Basic constructor
     * @param sensorHandle The handle of the object the acceleration is measured for
     * @param sigma The maximum error to add to any sensor values
     * @param gen Reference to the random number generator of the FINken this sensor belongs to
     */
    AttitudeSensor(int sensorHandle, double sigma, boost::random::mt19937& gen);

    /**
     * Calls V-REP to update the sensor information and sotres it in the AttitudeSensor#values vector.
     * See the <a href="http://www.coppeliarobotics.com/helpFiles/en/regularApi/simGetObjectQuaternion.htm">V-REP API</a> for more info. 
     */
    void update();

    /**
     * Retrieves the last known sensor values and returns them.
     * @returns The AttitudeSensor#values vector, including error values for each element 
     */
    std::vector<float> get();

    /**
     * Retrieves the last known sensor values without error.
     * @returns The AttitudeSensor#values vector, not including error values
     */
    std::vector<float> get_without_error();
};
