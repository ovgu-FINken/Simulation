/** 
 * @file attitudesensor.cpp 
 * \class AttitudeSensor
 * \brief Implementation of an attitudesensor
 * 
 * \todo implement and use this for attitude calculation.
 */


#include "attitudesensor.h"
#include "v_repLib.h"
#include <iostream>
#include <vector>


AttitudeSensor::AttitudeSensor(int sensorHandle, double sigma, boost::random::mt19937& gen) : Sensor::Sensor(sensorHandle, sigma, gen){
    sensorType = SensorTypes::Attitude;
    std::cout << "creating attitude sensor with handle " << sensorHandle << '\n';
}


void AttitudeSensor::update(){
        simGetObjectQuaternion(handle, -1, &values[0]);
}

std::vector<float> AttitudeSensor::get(){
    std::vector<float> errorValues = {0,0,0,0};
    for(int i = 0; i<values.size(); i++) {
        errorValues.at(i) = this->dist(this->gen) + values.at(i);
    }
    return errorValues;
}
std::vector<float> AttitudeSensor::get_without_error(){
    return values;
}
