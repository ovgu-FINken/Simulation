/** 
 * @file heightsensor.cpp 
 * \class HeightSensor
 * \brief Implementation of a proximitysensor as height sensor
 */


#include "heightsensor.h"
#include "v_repLib.h"
#include <iostream>

HeightSensor::HeightSensor(int sensorHandle, double sigma, boost::random::mt19937& gen) : Sensor::Sensor(sensorHandle), sigma(sigma), dist(boost::random::uniform_real_distribution<> {-sigma, sigma}), gen(gen){
    std::cout << "creating height sensor with handle " << sensorHandle << '\n';
}


void HeightSensor::update(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface) {
    simHandleProximitySensor(this->getHandle(), &detectPoint[0], &detectHandle, &detectSurface[0]);
}


int HeightSensor::get(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface ){
    return simReadProximitySensor(this->getHandle(), &detectPoint[0], &detectHandle, &detectSurface[0]);
}

void HeightSensor::get(float& test){
    test += this->dist(this->gen);
    std::cout << test << "/n";
}