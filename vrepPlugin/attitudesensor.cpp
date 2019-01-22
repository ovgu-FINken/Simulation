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


void AttitudeSensor::update(std::vector<float> &f, int &i, std::vector<float> &ff){}

int AttitudeSensor::get(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface ){
    return 0;
}
