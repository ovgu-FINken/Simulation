#include "accelerometer.h"
#include "v_repLib.h"
#include <iostream>
#include <vector>
#include <cstdlib>
#include <algorithm>
/** 
 * @file accelerometer.cpp 
 * \class AttitudeSensor
 */




Accelerometer::Accelerometer(int sensorHandle, double sigma, boost::random::mt19937& gen) : Sensor::Sensor(sensorHandle, sigma, gen){
    sensorType = SensorTypes::Acceleration;
    //not so great implementation: 0-2: velocity, 3-5: rotVel, 6-8: accel, 9-11: rotaccel 
    values = {0,0,0,0,0,0,0,0,0,0,0,0};
    std::cout << "creating accel sensor with handle " << sensorHandle << '\n';
}


void Accelerometer::update(){
    if(simGetObjectVelocity(this->handle, &values[0], &values[3]) > 0) {
        std::transform(values.begin(), values.begin()+6, this->lastVelocities.begin(), values.begin()+6,
            [](double a, double b) {return (a-b)/simGetSimulationTimeStep();});
        this->lastVelocities = values;
    }
    else {
        simAddStatusbarMessage("error retrieving finken velocity");
    }
}

std::vector<float> Accelerometer::get(){
    std::vector<float> errorValues = {0,0,0,0,0,0,0,0,0,0,0,0};
    for(unsigned int i = 0; i<values.size(); i++) {
        errorValues.at(i) = this->dist(this->gen) + values.at(i);
    }
    return errorValues;
}
std::vector<float> Accelerometer::get_without_error(){
    return values;
}