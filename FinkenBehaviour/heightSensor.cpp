#include "heightSensor.h"
#include "simtestdummy.h"
#include <iostream>

heightSensor::heightSensor(int sensorHandle) : sensor::sensor(sensorHandle){
    std::cout << "creating height sensor with handle " << sensorHandle << '\n';
}


void heightSensor::update(float* f, int* i, float* ff){
    simHandleProximitySensor(this->getHandle(), 0, 0, 0);
}

void heightSensor::get(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface ){
    simReadProximitySensor(this->getHandle(), &detectPoint[0], &detectHandle, &detectSurface[0]);
}


