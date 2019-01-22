#include "accelerometer.h"
#include "v_repLib.h"
#include <iostream>
#include <vector>
#include <cstdlib>
#include <algorithm>
/** 
 * @file accelerometer.cpp 
 * \class AttitudeSensor
 * \brief Implementation of an accelerometer
 * 
 * \todo implement and use this.
 */




Accelerometer::Accelerometer(int sensorHandle, double sigma, boost::random::mt19937& gen) : Sensor::Sensor(sensorHandle, sigma, gen){
    sensorType = SensorTypes::Acceleration;
}

void Accelerometer::update(std::vector<float> &velocities, std::vector<float> &accelerations){
            int i = 0;
            this->update(velocities, i, accelerations);
}

void Accelerometer::update(std::vector<float> &velocities, int &i, std::vector<float> &accelerations){
    if(simGetObjectVelocity(this->handle, &velocities[0], &velocities[3]) > 0) {
        std::transform(velocities.begin(), velocities.end(), this->lastVelocities.begin(), accelerations.begin(),
            [](double a, double b) {return (a-b)/simGetSimulationTimeStep();});
        this->lastVelocities = velocities;
    }
    else {
        simAddStatusbarMessage("error retrieving finken velocity");
    }
}

int Accelerometer::get(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface ){
    return 0;
}