#include "attitudesensor.h"
#include "v_repLib.h"
#include <iostream>
#include <vector>

AttitudeSensor::AttitudeSensor(int sensorHandle) : Sensor::Sensor(sensorHandle){
    std::cout << "creating attitude sensor with handle " << sensorHandle << '\n';
}


int AttitudeSensor::get(std::vector<float> &detectAngles){
    return simGetObjectOrientation(this->getHandle(), -1, &detectAngles[0]);
}


void AttitudeSensor::update(std::vector<float> &f, int &i, std::vector<float> &ff){}

int AttitudeSensor::get(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface ){
    return AttitudeSensor::get(detectPoint);
}
