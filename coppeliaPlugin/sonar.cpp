/** 
 * @file sonar.cpp
 * \class Sonar
*/

#include "sonar.h"
#include "stubs.h"
#include <iostream>

Sonar::Sonar(int sensorHandle, double sigma, boost::random::mt19937& gen) : Sensor::Sensor(sensorHandle, sigma, gen){
    values = {0,0,0,0};
    sensorType = SensorTypes::Sonar;
    std::cout << "creating sonar with handle " << sensorHandle << '\n';
}

void Sonar::update(){
    int detectedHandle = 0;
    std::vector<float> detectedSurfaceNormalVector = {0,0,0};

    int retVal = simHandleProximitySensor(this->getHandle(), &values[0], &detectedHandle, &detectedSurfaceNormalVector[0]);
    if (retVal == -1) {
        throw std::runtime_error("Error retrieving position Sensor data");
        return;
    }
    else if (retVal == 0){
        //TODO: what do we do if nothing was detected?
    }
}

std::vector<float> Sonar::get_without_error(){
    return values;
}

std::vector<float> Sonar::get(){
    std::vector<float> errorValues = {0,0,0,0};

    for(auto&& error : errorValues)
        error = this->dist(this->gen);

    std::transform (errorValues.begin(), errorValues.end(), values.begin(), errorValues.begin(), std::plus<float>());

    return errorValues;
}
