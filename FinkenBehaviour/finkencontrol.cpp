#include "finkencontrol.h"
#include <string>
#include <iostream>
#include <cmath>
#include <Eigen/Dense>

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


float* step(Finken* finken) {
    float xtarget = -1;
    float ytarget = -1;
    float ztarget = 1;
    float throttle = 0.7;
    float eulerAngles[3] = {0};

    std::vector<float> finkenPos = {0,0,0};

    simGetFloatSignal("TARGETX", &xtarget);
    simGetFloatSignal("TARGETY", &ytarget);
    simGetFloatSignal("TARGETZ", &ztarget);

    if(finken->getSensors().at(0)->get(finkenPos) >0) {

    }
    else {
      simAddStatusbarMessage("Error retrieveing Finken Base Position");
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
      errorYaw = errorYaw - 2*M_PI;    }


    float errorX = finkenPos.at(0) - xtarget;
    float errorY = finkenPos.at(1) - ytarget;
    float errorZ = finkenPos.at(2) - ztarget;

    Eigen::Vector2f coord(errorX, errorY);

    Eigen::Matrix<float, 2, 2> transMatrix;
    transMatrix(0,0) = cos(errorYaw);
    transMatrix(0,1) = sin(errorYaw);
    transMatrix(1,0) = -sin(errorYaw);
    transMatrix(1,1) = cos(errorYaw);

    coord = transMatrix*coord;
    errorX = coord(0);
    errorY = coord(1);

    float pitchCorr = finken->pitchController.step(-errorX, execution_step_size/defaultStepSize);
    float rollCorr =  finken ->rollController.step(-errorY, execution_step_size/defaultStepSize);

    float heightCorr = finken->yawController.step(-errorZ, execution_step_size/defaultStepSize);

    std::cout << "pitchCorr: " << pitchCorr << '\n';
    std::cout << "rollCorr: " << rollCorr << '\n';
    std::cout << "heightCorr: " << heightCorr << '\n';


    // simply holds a heigth of 1m
    throttles[0]=throttle + heightCorr;
    throttles[1]=throttle + heightCorr;
    throttles[2]=throttle + heightCorr;
    throttles[3]=throttle + heightCorr;

    return throttles;

}

void ecef_from_enu(Eigen::Vector3f& ecef_coord, Eigen::Vector3f& enu_coord) {
    Eigen::Matrix<float, 3, 3> cMatrix;

    cMatrix << -sin(lla.lon), -sin(lla.lat)*cos(lla.lon), cos(lla.lat)*cos(lla.lon),
                cos(lla.lon), -sin(lla.lat)*sin(lla.lon), cos(lla.lat)*sin(lla.lon),
                0,             cos(lla.lat),              sin(lla.lat);

    Eigen::Vector3f ecef_base(ecef.x, ecef.y, ecef.z);
    
    ecef_coord = cMatrix * enu_coord + ecef_base;

}

