#include "attitudesensor.h"
#include "v_repLib.h"
#include <iostream>
#include <vector>

AttitudeSensor::AttitudeSensor(int sensorHandle) : Sensor::Sensor(sensorHandle){
    std::cout << "creating attitude sensor with handle " << sensorHandle << '\n';
}


void AttitudeSensor::get(std::vector<float> &detectAngles){
    simGetObjectOrientation(this->getHandle(), -1, &detectAngles[0]);
}


void AttitudeSensor::update(std::vector<float> &f, int &i, std::vector<float> &ff){}

void AttitudeSensor::get(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface ){
    AttitudeSensor::get(detectPoint);
}
