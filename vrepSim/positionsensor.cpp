#include "positionsensor.h"
#include "v_repLib.h"
#include <iostream>
#include <vector>


PositionSensor::PositionSensor(int sensorHandle) : Sensor::Sensor(sensorHandle){
    std::cout << "creating position sensor with handle " << sensorHandle << '\n';
}


int PositionSensor::get(std::vector<float> &detectPosition){
    std::vector<float> dummyVector;
    int dummyInt;
    return PositionSensor::get(detectPosition, dummyInt, dummyVector);
}


void PositionSensor::update(std::vector<float> &f, int &i, std::vector<float> &ff){}

int PositionSensor::get(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface ){
    return simGetObjectPosition(this->getHandle(), -1, &detectPoint[0]);
}
