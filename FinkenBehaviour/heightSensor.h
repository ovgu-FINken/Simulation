#include "sensor.h"



class heightSensor: public sensor{
protected:
    int handle;
public:
    heightSensor(int sensorHandle);
    void get(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface);
    void update(float* f, int* i, float* ff);

};



