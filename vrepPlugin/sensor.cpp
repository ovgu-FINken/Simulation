/** 
 * @file sensor.cpp 
 * \class Sensor
 * \brief base Sensor class, all sensors should inherit from this
 */


#include "sensor.h"
#include <iostream>

Sensor::Sensor(int sensorHandle) : handle(sensorHandle){}

int Sensor::getHandle(){return handle;}


