
#pragma once

#ifdef _WIN32
    #define VREP_DLLEXPORT extern "C" __declspec(dllexport)
#endif /* _WIN32 */
#if defined (__linux) || defined (__APPLE__)
    #define VREP_DLLEXPORT extern "C"
#endif /* __linux || __APPLE__ */


#include "v_repLib.h"
#include "scriptFunctionData.h"
#include "finkenPID.h"




static const int FINKEN_SENSOR_COUNT = 4;
static const std::string SENSOR_ORIENTATION[FINKEN_SENSOR_COUNT]  = {"FRONT", "LEFT", "BACK", "RIGHT"};

VREP_DLLEXPORT unsigned char v_repStart(void* reservedPointer,int reservedInt);
VREP_DLLEXPORT void v_repEnd();
VREP_DLLEXPORT void* v_repMessage(int message,int* auxiliaryData,void* customData,int* replyData);
