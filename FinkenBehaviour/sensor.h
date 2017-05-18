#ifndef SENSOR_H
#define SENSOR_H
#include <vector>

class Sensor
{
protected:
    int handle;
public:
    Sensor(int sensorHandle);
    virtual void update(std::vector<float> &f, int &i, std::vector<float> &ff)=0;
    virtual void get(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface)=0;
    virtual void get(std::vector<float> &vfloat);
    virtual int getHandle();
};

#endif // SENSOR_H
