/** 
 * @file heightsensor.cpp 
 * \class HeightSensor
 * \brief Implementation of a proximitysensor as height sensor
 */


#include "heightsensor.h"
#include "v_repLib.h"
#include <iostream>

HeightSensor::HeightSensor(int sensorHandle) : Sensor::Sensor(sensorHandle){
    std::cout << "creating height sensor with handle " << sensorHandle << '\n';
}


void HeightSensor::update(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface) {
    simHandleProximitySensor(this->getHandle(), &detectPoint[0], &detectHandle, &detectSurface[0]);
}


int HeightSensor::get(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface ){
    return simReadProximitySensor(this->getHandle(), &detectPoint[0], &detectHandle, &detectSurface[0]);
}



