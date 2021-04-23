/** 
 * @file accelerometer.h 
 * \class Accelerometer
 * \brief Implementation of an accelerometer
 * Implements a basic accelerometer, calculating accelerations based on the last 2 known velocities of the FINken.
 */

#pragma once
#include "sensor.h"
#include <array>


class Accelerometer: public Sensor{

private:
    /**
     * Vector containing the sensor values. \n
     * Element order:  0-2: velocity, 3-5: rotVel, 6-8: accel, 9-11: rotaccel
     */
    std::vector<float> values = {0,0,0,0,0,0,0,0,0,0,0,0};

    Vec3 oldVel = {0,0,0};
    Vec3 oldRotVel = {0,0,0};
public:
    /** Basic constructor
     * @param sensorHandle The handle of the object the acceleration is measured for
     * @param sigma The maximum error to add to any sensor values
     * @param gen Reference to the random number generator of the FINken this sensor belongs to
     */
    Accelerometer(int sensorHandle, double sigma, boost::random::mt19937& gen);

    /**
     * Calculates the new acceleration and velocity based on the change in velocity since the last call 
     */
    void update();

    /**
     * Retrieves the last known sensor values.
     * @returns The Accelerometer#values vector with added error values. 
     */
    std::vector<float> get();

    /**
     * Retrieves the last known sensor values without error.
     * @returns The Accelerometer#values vector, not including error values
     */
    std::vector<float> get_without_error();
};



