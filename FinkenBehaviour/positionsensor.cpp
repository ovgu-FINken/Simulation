#include "positionsensor.h"
#include "v_repLib.h"
#include <iostream>
#include <vector>


PositionSensor::PositionSensor(int sensorHandle) : Sensor::Sensor(sensorHandle){
    std::cout << "creating position sensor with handle " << sensorHandle << '\n';
}


void PositionSensor::get(std::vector<float> &detectPosition){
    std::vector<float> dummyVector;
    int dummyInt;
    PositionSensor::get(detectPosition, dummyInt, dummyVector);
}


void PositionSensor::update(std::vector<float> &f, int &i, std::vector<float> &ff){}

void PositionSensor::get(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface ){
    simGetObjectPosition(this->getHandle(), -1, &detectPoint[0]);
}
