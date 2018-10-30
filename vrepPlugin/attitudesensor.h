/** 
 * @file attitudesensor.h
 * \class AttitudeSensor
 * \brief Implementation of an attitudesensor
 * 
 * \todo actually use this for attitude calculation.
 */

#ifndef ATTITUDESENSOR_H
#define ATTITUDESENSOR_H

#include "sensor.h"


/**
 * currently unused class for an attitude sensor.
 * currently the attitude is grabbed directly from the copter base object in vrep
 * (which is the same as would be done in this class with more overhead)
 * may be extended for use later for extending sensor functionality, e.g. implementing inaccuacies and noise
 */
class AttitudeSensor: public Sensor{

public:
    AttitudeSensor(int sensorHandle);
    int get(std::vector<float> &detectAngles);
    void update(std::vector<float> &f, int &i, std::vector<float> &ff);
    int get(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface);
};





#endif // attitudeSensor_H
