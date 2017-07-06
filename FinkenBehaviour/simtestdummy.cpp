#include <iostream>
#include "simtestdummy.h"



void simReadProximitySensor(int sHandle, float* dVect, int* dHandle, float* dSurface) {
   std::cout << "grabbing data from proximity sensor: " <<  sHandle << '\n';
    dVect[0] = 1;
    dVect[1] = 1;
    dVect[2] = 1;
    *dHandle = 1;
    dSurface[0] = 1;
    dSurface[1] = 1;
    dSurface[2] = 1;
}


void simHandleProximitySensor(int sHandle, float* dVect, int* dHandle, float* dSurface) {
    std::cout << "grabbing data from proximity sensor: " <<  sHandle << '\n';
    dVect[0] = 1;
    dVect[1] = 1;
    dVect[2] = 1;
    *dHandle = 1;
    dSurface[0] = 1;
    dSurface[1] = 1;
    dSurface[2] = 1;
}

void simGetObjectPosition(int sHandle, int relPos, float* position){
    std::cout << "grabbing data from position sensor: " << sHandle << '\n';
    if (relPos == -1) {
        position[0] = 1;
        position[1] = 1;
        position[2] = 1;
    }
}

void simGetObjectOrientation(int sHandle, int relPos, float* position){
    std::cout << "grabbing data from attitude sensor: " << sHandle << '\n';
    if (relPos == -1) {
        position[0] = 1;
        position[1] = 1;
        position[2] = 1;
    }
}
