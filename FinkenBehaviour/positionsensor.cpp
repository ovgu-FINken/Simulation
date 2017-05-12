#include "positionsensor.h"
#include "simtestdummy.h"
#include <iostream>
#include <vector>

positionSensor::positionSensor(int sensorHandle) : sensor::sensor(sensorHandle){
    std::cout << "creating position sensor with handle " << sensorHandle << '\n';
}


void positionSensor::get(std::vector<float> &detectPosition){
    simGetObjectPosition(this->getHandle(), -1, &detectPosition[0]);
}


void positionSensor::update(float* f, int* i, float* ff){}

void positionSensor::get(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface ){}
