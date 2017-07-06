#ifndef HEIGHTSENSOR_H
#define HEIGHTSENSOR_H

#include "sensor.h"



class HeightSensor: public Sensor{

public:
    HeightSensor(int sensorHandle);
    int get(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface);
    void update(std::vector<float> &f, int &i, std::vector<float> &ff);

};

#endif

