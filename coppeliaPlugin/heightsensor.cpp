/** 
 * @file heightsensor.cpp 
 * \class HeightSensor
 * \brief Implementation of a height sensor
 * Actually Implemented as a positionSensor only reading height instead of a proximitysensor 
 * because of performance reasons.
 * 
 */

#include "heightsensor.h"
#include "stubs.h"
#include <iostream>

HeightSensor::HeightSensor(int sensorHandle, double sigma, boost::random::mt19937& gen) : Sensor::Sensor(sensorHandle, sigma, gen){
    values = {0};
    positionValues = {0,0,0};
    sensorType = SensorTypes::Height;
    std::cout << "creating height sensor with handle " << sensorHandle << '\n';
}

void HeightSensor::update() {
    auto pos = sim::getObjectPosition(this->getHandle(), -1);
    values[0] = pos[2];
}

std::vector<float> HeightSensor::get(){
    std::vector<float> errorValues = {0};
    float error = this->dist(this->gen);
    errorValues[0] = error + values[0];
    return errorValues;
}

std::vector<float> HeightSensor::get_without_error(){
    return values;
}
