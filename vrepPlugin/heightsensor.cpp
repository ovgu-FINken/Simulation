/** 
 * @file heightsensor.cpp 
 * \class HeightSensor
 * \brief Implementation of a proximitysensor as height sensor
 */


#include "heightsensor.h"
#include "v_repLib.h"
#include <iostream>

HeightSensor::HeightSensor(int sensorHandle, double sigma, boost::random::mt19937& gen) : Sensor::Sensor(sensorHandle, sigma, gen){
    sensorType = SensorTypes::Height;
    std::cout << "creating height sensor with handle " << sensorHandle << '\n';
}


void HeightSensor::update() {
    int detectedHandle = 0;
    std::vector<float> detectedPoint = {0,0,0,0};
    std::vector<float> detectedSurfaceNormalVector = {0,0,0};
    int retVal = simHandleProximitySensor(this->getHandle(), &detectedPoint[0], &detectedHandle, &detectedSurfaceNormalVector[0]);
    if (retVal == -1) {
        throw std::runtime_error("Error retrieving position Sensor data");
        return;
    }
    else if (retVal == 0){
        //TODO: what do we do if nothing was detected?
    }
    values[0] = detectedPoint[3];
}


std::vector<float> HeightSensor::get(){
    std::vector<float> errorValues = {0};
    float error = this->dist(this->gen);
    errorValues[0] = error + values[0];
    return errorValues;
}


std::vector<float> HeightSensor::get_without_error(){
    return values;    
}

