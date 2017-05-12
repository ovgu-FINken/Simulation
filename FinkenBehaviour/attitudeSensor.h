#ifndef ATTITUDESENSOR_H
#define ATTITUDESENSOR_H

#include "sensor.h"



class attitudeSensor: public sensor{
protected:
    int handle;
public:
    attitudeSensor(int sensorHandle);
    void get(std::vector<float> &detectAngles);

    void update(float* f, int* i, float* ff);
    void get(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface);
};





#endif // attitudeSensor_H
