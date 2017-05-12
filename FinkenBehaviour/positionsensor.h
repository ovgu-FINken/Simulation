#ifndef POSITIONSENSOR_H
#define POSITIONSENSOR_H

#include "sensor.h"



class positionSensor: public sensor{
protected:
    int handle;
public:
    positionSensor(int sensorHandle);
    void get(std::vector<float> &detectPosition);
    void update(float* f, int* i, float* ff);
    void get(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface);
};





#endif // POSITIONSENSOR_H
