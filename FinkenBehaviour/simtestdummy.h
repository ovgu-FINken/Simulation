#ifndef SIMTESTDUMMY_H
#define SIMTESTDUMMY_H

void simReadProximitySensor(int sHandle, float* dVect, int* dHandle, float* dSurface);

void simHandleProximitySensor(int sHandle, float* dVect, int* dHandle, float* dSurface);

void simGetObjectPosition(int sHandle, int relPos, float* dPosition);

void simGetObjectOrientation(int sHandle, int relPos, float* dPosition);
#endif // SIMTESTDUMMY_H
