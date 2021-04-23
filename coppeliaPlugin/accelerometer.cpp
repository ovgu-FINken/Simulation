#include "accelerometer.h"
#include "stubs.h"
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
    std::cout << "creating accel sensor with handle " << sensorHandle << '\n';
}


void Accelerometer::update(){
    auto result = sim::getObjectVelocity(this->handle);
    auto dt = simGetSimulationTimeStep();
    Vec3 vel, rotVel;
    std::copy(result.first.data(), result.first.data()+3, vel.data());
    std::copy(result.second.data(), result.second.data()+3, rotVel.data());
    Vec3 acc = (vel-oldVel)/dt;
    Vec3 rotAcc = (rotVel - oldRotVel)/dt;
    oldVel = vel;
    oldRotVel = rotVel;
    for(auto i : {0,1,2}) {
      values[6+i] = acc[0+i];
      values[9+i] = rotAcc[0+i];
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
