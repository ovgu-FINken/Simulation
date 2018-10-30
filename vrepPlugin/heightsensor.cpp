/** 
 * @file heightsensor.cpp 
 * \class HeightSensor
 * \brief Implementation of a proximitysensor as height sensor
 */


#include "heightsensor.h"
#include "v_repLib.h"
#include <iostream>

HeightSensor::HeightSensor(int sensorHandle) : Sensor::Sensor(sensorHandle){
    std::cout << "creating height sensor with handle " << sensorHandle << '\n';
}

/**
 * calls for vrep to update the sensor information
 * @param &detectPoint vector reference to store the coordinates of the closest point
 * @param &detectHandle integer reference to store the handle of the found object
 * @param &detectSurface vector reference to store the normal vector of the detected surface 
 */
void HeightSensor::update(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface) {
    simHandleProximitySensor(this->getHandle(), &detectPoint[0], &detectHandle, &detectSurface[0]);
}

/**
 * simply reads the sensor information with no additional call to handle the sensor in vrep
 * @param &detectPoint vector reference to store the coordinates of the closest point
 * @param &detectHandle integer reference to store the handle of the found object
 * @param &detectSurface vector reference to store the normal vector of the detected surface 
 */
int HeightSensor::get(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface ){
    return simReadProximitySensor(this->getHandle(), &detectPoint[0], &detectHandle, &detectSurface[0]);
}

/**
 * same as the previous get, but all parameters except the coordinates of a detected point are omitted
 */
int HeightSensor::get(std::vector<float> &detectPoint) {
    return simReadProximitySensor(this->getHandle(), &detectPoint[0], 0, 0);
}



