#include "sensor.h"
#include <string>

class Sonar: public Sensor{

public:
    Sonar(int sensorHandle);
    int get(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface);
    void update(std::vector<float> &f, int &i, std::vector<float> &ff);

};



