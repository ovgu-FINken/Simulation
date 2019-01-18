#pragma once

#include "sensor.h"
#include <boost/random.hpp>

/**
 * Class implementing a heightsensor
 */
class HeightSensor: public Sensor{

public:
    /** Basic constructor.
     * @param sensorHandle the handle of the sensor in V-REP 
     */
    HeightSensor(int sensorHandle, double sigma, boost::random::mt19937& gen);

    double sigma;
    boost::random::uniform_real_distribution<> dist;
    boost::random::mt19937& gen;


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

    /** TODO: doc, possibly remove inheritance architecture for sensors 
     */
    void get(float &height);
    void get_with_error(float& height);
    /**
     * Updates the sensor information, including any detected object information.
     * @param detectPoint Coordinates of the closest detected point.
     * @param detectHandle The handle of the detected object. 
     * @param detectSurface Normal vector of the detected surface.
     * 
     * See the <a href="http://www.coppeliarobotics.com/helpFiles/en/regularApi/simReadProximitySensor.htm">V-REP API</a> for more info. 

     */
    void update(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface);
};


