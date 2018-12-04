/** 
 * @file accelerometer.h 
 * \class Accelerometer
 * \brief implementation of an accelerometer
 * \todo actually use this in the sim
 */

#pragma once
#include "sensor.h"


class Accelerometer: public Sensor{

public:
    /** Basic constructor
     * @param sensorHandle The handle of the object the acceleration is measured for
     */
    Accelerometer(int sensorHandle); 

    /**
     * function wrapper calling actual update function
     */
    void update(std::vector<float> &velocities, std::vector<float> &accelerations);

    /** 
     * Vector storing last velocity for acceleration calculation 
     */
    std::vector<float> lastVelocities = {0,0,0,0,0,0};

    /**
     * Calculates the new acceleration and velocity based on the change in velocity since the last call 
     * @param velocities vector to store velocity[0-2] and rotational velocity[3-5]
     * @param i unused parameter to conform to base class
     * @param accelerations ector to store acceleration[0-2] and rotational acceleration[3-5]
     */
    void update(std::vector<float> &velocities, int &i, std::vector<float> &accelerations);
    int get(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface );
};



