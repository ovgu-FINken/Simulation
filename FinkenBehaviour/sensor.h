#ifndef SENSOR_H
#define SENSOR_H
#include <vector>

/**
 * Basic Sensor class from which specialized sensors are derived
 */
class Sensor
{
protected:
    /** Handle to access the sensor in vrep*/
    int handle;
public:
    /** 
     * Constructor 
     * @param sensorHandle the handle of the sensor in vrep
     * */
    Sensor(int sensorHandle);
    /**
     * calls for Vrep to update the sensor information;
     * see specific sensor documentation for parameter information
     */
    virtual void update(std::vector<float> &f, int &i, std::vector<float> &ff)=0;
    /**
     * retrieves the sensor information, including any detected object information;
     * see specific sensor documentation for paramter information
     */
    virtual int get(std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface)=0;
    /**
     * retrieves the sensor information, limited to the position of a detected object;
     * see specific sensor documentation for parameter information
     */
    virtual int get(std::vector<float> &vfloat)=0;
    
    /*
     * retrieves the sensor handle
     */
    virtual int getHandle();
};

#endif // SENSOR_H
