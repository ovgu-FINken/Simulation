/** 
 * @file attitudesensor.h
 * \class AttitudeSensor
 * \brief Implementation of an attitudesensor
 * 
 * \todo actually use this for attitude calculation, implement noise.
 */

#pragma once

#include "sensor.h"


/**
 * Currently unused class for an attitude sensor. 
 */
class AttitudeSensor: public Sensor{

public:
    /** Basic constructor.
     * @param sensorHandle The handle of the sensor in V-REP
     */
    AttitudeSensor(int sensorHandle, double sigma, boost::random::mt19937& gen);
    
    /**
     * Updates the sensor information, including any detected object information.
     * @param detectPoint Coordinates of the closest detected point.
     * @param detectHandle The handle of the detected object. 
     * @param detectSurface Normal vector of the detected surface.
     * 
     * See the <a href="http://www.coppeliarobotics.com/helpFiles/en/regularApi/simReadProximitySensor.htm">V-REP API</a> for more info. 

     */
    void update(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface);

    /**
     * Retrieves the sensor information, including any detected object information.
     * @param detectPoint Coordinates of the closest detected point.
     * @param detectHandle The handle of the detected object. 
     * @param detectSurface Normal vector of the detected surface.
     * 
     * \returns 0 or 1, depending on the detection state of the sensor and -1 in case of any error.
     * See the <a href="http://www.coppeliarobotics.com/helpFiles/en/regularApi/simHandleProximitySensor.htm">V-REP API</a> for more info. 

     */
    int get(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface);
};






