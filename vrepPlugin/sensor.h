#pragma once 
#include <vector>

/** 
 * @file sensor.cpp 
 * \class Sensor
 * \brief base Sensor class, all sensors should inherit from this
 */

class Sensor
{
protected:
    int handle;  ///< Handle to access the sensor in vrep
public:
    /** 
     * Constructor. 
     * @param sensorHandle the handle of the sensor in vrep
     * */
    Sensor(int sensorHandle);
    /**
     * Calls for Vrep to update the sensor information.
     * See specific sensor documentation for parameter information.
     */
    virtual void update(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface)=0;
    /**
     * retrieves the sensor information, including any detected object information;
     * see specific sensor documentation for parameter information
     */
    virtual int get(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface)=0;
    
    /** Retrieves the sensor handle. */
    virtual int getHandle();
    virtual int get(double &d);
};
