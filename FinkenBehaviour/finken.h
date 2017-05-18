#ifndef FINKEN_H
#define FINKEN_H
#include "sensor.h"
#include <memory>
#include "sonar.h"
#include "heightsensor.h"
class Finken
{
private:
     std::vector<std::unique_ptr<Sensor>> sensors;
public:
    Finken();
    int handle;
    void addSensor(std::unique_ptr<Sensor> &sensor);
    std::vector<std::unique_ptr<Sensor> > &getSensors();
    Finken(const Finken&) = delete;
    Finken& operator=(const Finken&) = delete;
};

void buildFinken(Finken &finken);
#endif // FINKEN_H
