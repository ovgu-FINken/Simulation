#include "heightsensor.h"
#include "v_repLib.h"
#include <iostream>

HeightSensor::HeightSensor(int sensorHandle) : Sensor::Sensor(sensorHandle){
    std::cout << "creating height sensor with handle " << sensorHandle << '\n';
}


void HeightSensor::update(std::vector<float> &f, int &i, std::vector<float> &ff){
    simHandleProximitySensor(this->getHandle(), 0, 0, 0);
}

void HeightSensor::get(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface ){
    simReadProximitySensor(this->getHandle(), &detectPoint[0], &detectHandle, &detectSurface[0]);
}


