/** 
 * @file positionsensor.cpp 
 * \class PositionSensor
 * \brief wrapper to disguise vrep API calls as a position sensor
 * \todo implement noise
 */
#include "positionsensor.h"
#include "v_repLib.h"
#include <iostream>
#include <vector>


PositionSensor::PositionSensor(int sensorHandle) : Sensor::Sensor(sensorHandle){
    std::cout << "creating position sensor with handle " << sensorHandle << '\n';
}

void PositionSensor::update(std::vector<float> &f, int &i, std::vector<float> &ff){}

int PositionSensor::get(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface ){
    return simGetObjectPosition(this->getHandle(), -1, &detectPoint[0]);
}
