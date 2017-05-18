#ifndef ATTITUDESENSOR_H
#define ATTITUDESENSOR_H

#include "sensor.h"



class AttitudeSensor: public Sensor{

public:
    AttitudeSensor(int sensorHandle);
    void get(std::vector<float> &detectAngles);
    void update(std::vector<float> &f, int &i, std::vector<float> &ff);
    void get(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface);
};





#endif // attitudeSensor_H
