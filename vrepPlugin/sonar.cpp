/** 
 * @file sonar.cpp 
 * \class Sonar
 * \brief implementation of a proximitysensor as sonar
 * \todo actually use this in the sim
 */


#include "sonar.h"
#include "v_repLib.h"
#include <iostream>

Sonar::Sonar(int sensorHandle) : Sensor::Sensor(sensorHandle){
    std::cout << "creating sonar with name " << simGetObjectName(this->getHandle()) << '\n';
}

/**
 * calls for vrep to update the sensor information
 * @param &detectPoint vector reference to store the coordinates of the closest point
 * @param &detectHandle integer reference to store the handle of the found object
 * @param &detectSurface vector reference to store the normal vector of the detected surface 
 */
void Sonar::update(std::vector<float> &f, int &i, std::vector<float> &ff){
    simHandleProximitySensor(this->getHandle(), &f[0], &i, &ff[0]);
    std::cout << "Handling Sonar " << simGetObjectName(this->getHandle()) << '\n';
}

/**
 * simply reads the sensor information with no additional call to handle the sensor in vrep
 * @param &detectPoint vector reference to store the coordinates of the closest point
 * @param &detectHandle integer reference to store the handle of the found object
 * @param &detectSurface vector reference to store the normal vector of the detected surface 
 */
int Sonar::get(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface ){
    std::cout << "retrieving Sonar" << '\n';
    return simReadProximitySensor(this->getHandle(), &detectPoint[0], &detectHandle, &detectSurface[0]);
}

/**
 * same as the previous get, but all parameters except the coordinates of a detected point are omitted
 */
int Sonar::get(std::vector<float> &detectPoint) {
    return simReadProximitySensor(this->getHandle(), &detectPoint[0], 0, 0);
}



