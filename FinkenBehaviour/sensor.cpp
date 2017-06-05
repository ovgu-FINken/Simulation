#include "sensor.h"
#include <iostream>

Sensor::Sensor(int sensorHandle) : handle(sensorHandle){}

int Sensor::getHandle(){return handle;}

int Sensor::get(std::vector<float> &vfloat) {

}
