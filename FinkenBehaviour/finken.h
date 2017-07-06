#ifndef FINKEN_H
#define FINKEN_H
#include "sensor.h"
#include <memory>
#include "sonar.h"
#include "heightsensor.h"
#include <rotor.h>
#include "finkenPID.h"
#include "positionsensor.h"


class Finken
{
private:
     std::vector<std::unique_ptr<Sensor>> sensors;
     std::vector<std::unique_ptr<Rotor>> rotors;
public:
    Finken(int fHandle);
    int handle;
    void addSensor(std::unique_ptr<Sensor> &sensor);
    void addRotor(std::unique_ptr<Rotor> &rotor);
    std::vector<std::unique_ptr<Sensor>> &getSensors();
    std::vector<std::unique_ptr<Rotor>> &getRotors();
    Finken(const Finken&) = delete;
    Finken& operator=(const Finken&) = delete;

    finkenPID pitchController;
    finkenPID rollController;
    finkenPID yawController;
    finkenPID targetXcontroller;
    finkenPID targetYcontroller;
    finkenPID targetZcontroller;
};

std::unique_ptr<Finken> buildFinken();
#endif // FINKEN_H
