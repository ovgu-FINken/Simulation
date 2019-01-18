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


PositionSensor::PositionSensor(int sensorHandle, double sigma, boost::random::mt19937& gen) : Sensor::Sensor(sensorHandle), sigma(sigma), dist(boost::random::uniform_real_distribution<> {-sigma, sigma}), gen(gen){
    std::cout << "creating position sensor with handle " << sensorHandle << '\n';
}


void PositionSensor::update(std::vector<float> &f, int &i, std::vector<float> &ff){}

int PositionSensor::get(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface ){
    return simGetObjectPosition(this->getHandle(), -1, &detectPoint[0]);
}

void PositionSensor::get_with_error(std::vector<float>& position){
    this->get(position);
    for(auto pos : position){
        double error = this->dist(this->gen);
        pos += error;
    }        

}

void PositionSensor::get(std::vector<float>& position){
    simGetObjectPosition(this->getHandle(), -1, &position[0]); 
}