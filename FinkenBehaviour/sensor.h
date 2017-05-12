#ifndef SENSOR_H
#define SENSOR_H
#include <vector>

class sensor
{
private:
    int handle;
public:
    sensor(int sensorHandle);
    virtual void update(float* f, int* i, float* ff)=0;
    virtual void get(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface)=0;
    virtual int getHandle();
};

#endif // SENSOR_H
