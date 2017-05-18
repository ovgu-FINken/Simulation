#include "sonar.h"
#include "v_repLib.h"
#include <iostream>

Sonar::Sonar(int sensorHandle) : Sensor::Sensor(sensorHandle){
    std::cout << "creating sonar with name " << simGetObjectName(this->getHandle()) << '\n';
}


void Sonar::update(std::vector<float> &f, int &i, std::vector<float> &ff){
    simHandleProximitySensor(this->getHandle(), &f[0], &i, &ff[0]);
    std::cout << "Handling Sonar " << simGetObjectName(this->getHandle()) << '\n';
}

void Sonar::get(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface ){
    simReadProximitySensor(this->getHandle(), &detectPoint[0], &detectHandle, &detectSurface[0]);
    std::cout << "retrieving Sonar" << '\n';
}


