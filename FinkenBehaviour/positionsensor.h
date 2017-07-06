#ifndef POSITIONSENSOR_H
#define POSITIONSENSOR_H

#include "sensor.h"



class PositionSensor: public Sensor{

public:
    PositionSensor(int sensorHandle);
    int get(std::vector<float> &detectPosition);
    void update(std::vector<float> &f, int &i, std::vector<float> &ff);
    int get(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface);
};





#endif // POSITIONSENSOR_H
