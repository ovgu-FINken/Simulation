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


PositionSensor::PositionSensor(int sensorHandle, double sigma, boost::random::mt19937& gen) : Sensor::Sensor(sensorHandle, sigma, gen){
    sensorType = SensorTypes::Position;
    std::cout << "creating position sensor with handle " << sensorHandle << '\n';
}



void PositionSensor::update(){
    int retVal = simGetObjectPosition(this->getHandle(), -1, &values[0]);
    if (retVal == -1) {
        throw std::runtime_error("Error retrieving position Sensor data");
    }
}

std::vector<float> PositionSensor::get_without_error(){
    return values;
}        


std::vector<float> PositionSensor::get(){
    std::vector<float> errorValues = {0,0,0};
    for(auto&& error : errorValues){
        error = this->dist(this->gen);
    }
    std::transform (errorValues.begin(), errorValues.end(), values.begin(), errorValues.begin(), std::plus<float>());
    return errorValues;
}