#include "finkencontrol.h"
#include <string>
#include <iostream>
#include <cmath>
#include <Eigen/Dense>
#include <chrono>
#include <thread>

#define _USE_MATH_DEFINES

float pPthrottle = 2;
float iPthrottle = 0;
float dPthrottle = 0;
float vPthrottle = -2;
float cumulThrottle = 0;
float prevEThrottle = 0;

float throttles[4] = {-1,-1,-1,-1};

float execution_step_size = 0;
float execution_last_time = 0;
float defaultStepSize = 0.050;



struct ecef_coords {
    float x = 3862.7;
    float y = 750.8;
    float z = 5002.8;
};
struct lla_coords {
    float lat = 52;
    float lon = 11;
    float height = 50;
};

ecef_coords ecef;
lla_coords lla;

const char* fixSignalName(std::string signalName) {
    return signalName.c_str();
}

void ecef_from_enu(Eigen::Vector3f& ecef_coord, Eigen::Vector3f& enu_coord) {
    Eigen::Matrix<float, 3, 3> cMatrix;

    cMatrix << -sin(lla.lon), -sin(lla.lat)*cos(lla.lon), cos(lla.lat)*cos(lla.lon),
                cos(lla.lon), -sin(lla.lat)*sin(lla.lon), cos(lla.lat)*sin(lla.lon),
                -1,             cos(lla.lat),              sin(lla.lat);

    Eigen::Vector3f ecef_base(ecef.x, ecef.y, ecef.z);
    
    ecef_coord = cMatrix * enu_coord + ecef_base;
}



/*
the step function now simply returns the coordinates
of the copter (ENU->ECEF)
*/
std::vector<double> step(Finken* finken) {
    std::cout << "2" << std::endl;
    std::vector<float> finkenPos = {0,0,0};
    float eulerAngles[3] = {0};
    if(finken->getSensors().at(0)->get(finkenPos) >0) {

    }
    else {
      simAddStatusbarMessage("Error retrieveing Finken Base Position");
      std::cout << "Error retrieveing Finken Base Position. Handle:" << finken->handle << std::endl;
    }

    if(simGetObjectOrientation(finken->handle, -1, eulerAngles) > 0) {

    }
    else {
      simAddStatusbarMessage("error retrieveing Finken Base Orientation");
    }
    float errorYaw = eulerAngles[2];

    if (errorYaw < M_PI){
      errorYaw = 2*M_PI+errorYaw;
    }
    else{
      errorYaw = errorYaw - 2*M_PI;
    } 
    
    std::cout << "3" << std::endl;
    Eigen::Vector3f ecef_copter(0,0,0);
    Eigen::Vector3f enu_copter(finkenPos[0], finkenPos[1], finkenPos[2]);
    std::cout << "4" << std::endl;
    ecef_from_enu(ecef_copter, enu_copter);
    std::cout << "5" << std::endl;
    std::vector<double> dFinkenPos = {0,0,0};
    std::cout << "6" << std::endl;
    dFinkenPos[0] = ecef_copter[0];
    dFinkenPos[1] = ecef_copter[1];
    dFinkenPos[2] = ecef_copter[2];
    std::cout << "7" << std::endl;
    std::this_thread::sleep_for(std::chrono::milliseconds(10000));
    std::cout << "3" << std::endl;
    return dFinkenPos;
}



