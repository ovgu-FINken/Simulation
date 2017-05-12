#include "sensor.h"
#include <iostream>

sensor::sensor(int sensorHandle) : handle(sensorHandle){}

int sensor::getHandle(){return handle;}
