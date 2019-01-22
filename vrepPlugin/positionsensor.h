#pragma once
#include "sensor.h"



class PositionSensor: public Sensor{

public:
    /** Basic constructor.
     * @param sensorHandle the handle of the sensor in V-REP 
     */
    PositionSensor(int sensorHandle, double sigma, boost::random::mt19937& gen);

    /**
     * Updates the sensor information
     */
    void update();

    /**
     * Retrieves the sensor information, including sensor noise
     * \returns a vector storing the position 
     */
    std::vector<float> get();

    /**
     * Retrieves the sensor information, not including sensor noise
     * \returns a vector storing the position 
     */
    std::vector<float>get_without_error();

};





