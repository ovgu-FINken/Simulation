#include "attitudeSensor.h"
#include "simtestdummy.h"
#include <iostream>
#include <vector>

attitudeSensor::attitudeSensor(int sensorHandle) : sensor::sensor(sensorHandle){
    std::cout << "creating position sensor with handle " << sensorHandle << '\n';
}


void attitudeSensor::get(std::vector<float> &detectAngles){
    simGetObjectOrientation(this->getHandle(), -1, &detectAngles[0]);
}


void attitudeSensor::update(float* f, int* i, float* ff){}

void attitudeSensor::get(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface ){}
