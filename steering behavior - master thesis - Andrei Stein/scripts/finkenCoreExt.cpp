
#include "finkenCoreExt.h"
#include <string>
#include <cstring>
#include <cmath>
#include <stdlib.h>
#include <array>
#include <iostream>
#include <unistd.h>

#ifdef __APPLE__
#define _stricmp strcmp
#endif

#define CONCAT(x,y,z) x y z
#define strConCat(x,y,z)    CONCAT(x,y,z)

#define PLUGIN_VERSION 4 // 2 since version 3.2.1, 3 since V3.3.1, 4 since V3.4.0




#define _USE_MATH_DEFINES
#define PLUGIN_NAME "FinkenCoreExt"

int thisIDsuffix = 0;
float sensorDistances[FINKEN_SENSOR_COUNT]  = {7.5,7.5,7.5,7.5};

float execution_last_time = 0;
float execution_step_size = 0;
float defaultStepSize = 0.050;

float pPthrottle = 2;
float iPthrottle = 0;
float dPthrottle = 0;
float vPthrottle = -2;
float cumulThrottle = 0;
float prevEThrottle = 0;

float particlesTargetVelocities[4] = {-1,-1,-1,-1};

struct sFinken
{
    int handle_FinkenBase;
    int handle_finken;
    std::array<int, FINKEN_SENSOR_COUNT> sensorHandles;
    finkenPID pitchController;
    finkenPID rollController;
    finkenPID yawController;
    finkenPID targetXcontroller;
    finkenPID targetYcontroller;
    finkenPID targetZcontroller;
    sFinken() {
      handle_FinkenBase = -1;
      handle_finken = -1;
      sensorHandles.fill(-1);

    };
};
struct sFinken finken;
LIBRARY vrepLib;

float tuneThrottle(float throttle, float curveParamNeg, float curveParamPos) {
	float throttleTarget = throttle - 50;
	if (throttleTarget <0){
		throttleTarget = -(curveParamNeg*abs(throttleTarget))/(curveParamNeg-abs(throttleTarget)+50) + 50;
	}
	else{
		throttleTarget = (curveParamPos*throttleTarget)/(curveParamPos-throttleTarget+50) + 50;
	}
	return throttleTarget;
}

//TODO: fix for multiple finken IDs
char* fixSignalName(std::string signalName) {
  if (thisIDsuffix != -1) {
    std::string nameFixed = signalName + std::to_string(thisIDsuffix);
    char* cNameFixed = new char[nameFixed.length()+1];
    std::strcpy(cNameFixed, nameFixed.c_str());
    return (cNameFixed);
  }
  else {
    char* cNameFixed = new char[signalName.length()+1];
    std::strcpy(cNameFixed, signalName.c_str());
    return cNameFixed;
  }
}

/*

function finkenCore.fixName(name)
	if (thisIDsuffix ~= -1) then
		return (name..'#'..thisIDsuffix)
	else
		return name
	end
end
*/

#define LUA_INIT_COMMAND "simExtFinken_init"

const int inArgs_INIT[]={
    1,
    sim_script_arg_int32,0,
};

void LUA_INIT_CALLBACK(SScriptCallBack* cb)
{
    CScriptFunctionData D;
    if (D.readDataFromStack(cb->stackID,inArgs_INIT,inArgs_INIT[0],LUA_INIT_COMMAND))
    {
        std::vector<CScriptFunctionDataItem>* inData=D.getInDataPtr();

				int foundSensorCount = 0;
        int foundDummyCount = 0;
        finken.handle_finken=inData->at(0).int32Data[0];
				char chandle_finken[63];
				sprintf(chandle_finken, "%d", finken.handle_finken);
        int thisIDsuffix = (simGetNameSuffix(chandle_finken));

        /* Das folgende müsste doch irgendwie eleganter gehen.
        Ich habe aber keine gute möglichkeit gefunden den erhaltenen int* pointer
        in ein array oder nen vektor zu packen. dabei sollten int* und int[] doch
        relativ austauschbar sein in c++?
        */
        //grab all attached sensors and save them in an array:
        int* buffer = simGetObjectsInTree(finken.handle_finken, sim_object_proximitysensor_type, 1, &foundSensorCount);
        for (int i=0; i<FINKEN_SENSOR_COUNT; i++){
          finken.sensorHandles[i] = buffer[i];
        }

        buffer = simGetObjectsInTree(finken.handle_finken, sim_object_dummy_type, 1, &foundDummyCount);
        finken.handle_FinkenBase = buffer[0];

        finken.pitchController.initPID(0.2, 0.1, 1.5);
      	finken.rollController.initPID(0.2, 0.1, 1.5);
      	finken.yawController.initPID(0.04, 0.001, 1.1);
      	finken.targetXcontroller.initPID(2, 0, 4);
      	finken.targetYcontroller.initPID(2, 0, 4);
      	finken.targetZcontroller.initPID(10, 0, 8);
        simSetFloatSignal(fixSignalName("throttle"),50);
      	simSetFloatSignal(fixSignalName("pitch"),0);
      	simSetFloatSignal(fixSignalName("roll"),0);
      	simSetFloatSignal(fixSignalName("yaw"),0);
      	simSetFloatSignal(fixSignalName("height"),1);
        for (int i=0; i<FINKEN_SENSOR_COUNT; i++ ) {
          char* thisSignalName = fixSignalName("sensor_dist" + SENSOR_ORIENTATION[i]);
          simSetFloatSignal(thisSignalName,sensorDistances[i]);
        }
    }
    D.pushOutData(CScriptFunctionDataItem(finken.handle_finken));
    D.writeDataToStack(cb->stackID);
}

/* old lua code for INIT

function finkenCore.init()
	thisIDsuffix = simGetNameSuffix(nil)
	simAddStatusbarMessage(thisIDsuffix)
	handle_FinkenBase = simGetObjectHandle(finkenCore.fixName('SimFinken_base'))
	handle_finken = simGetObjectAssociatedWithScript(sim_handle_self)
	execution_step_size = simGetSimulationTimeStep()
	local _, apiInfo = simExtRemoteApiStatus(19999) or simExtRemoteApiStart(19999)
	pitchController.init(0.2, 0.1, 1.5)
	rollController.init(0.2, 0.1, 1.5)
	yawController.init(0.04, 0.001, 1.1) --(0.1, , )
	targetXcontroller.init(2, 0, 4)
	targetYcontroller.init(2, 0, 4)
	targetZcontroller.init(10, 0, 8)
	simSetFloatSignal(finkenCore.fixSignalName('throttle'),50)
	simSetFloatSignal(finkenCore.fixSignalName('pitch'),0)
	simSetFloatSignal(finkenCore.fixSignalName('roll'),0)
	simSetFloatSignal(finkenCore.fixSignalName('yaw'),0)
	simSetFloatSignal(finkenCore.fixSignalName('height'),1)
	sensorHandles.distFront = simGetObjectHandle(finkenCore.fixName('SimFinken_sensor_front'))
	sensorHandles.distLeft = simGetObjectHandle(finkenCore.fixName('SimFinken_sensor_left'))
	sensorHandles.distBack = simGetObjectHandle(finkenCore.fixName('SimFinken_sensor_back'))
	sensorHandles.distRight = simGetObjectHandle(finkenCore.fixName('SimFinken_sensor_right'))
  simSetStringSignal(finkenCore.fixSignalName('sensor_dist'),simPackFloats(sensorDistances))
end
*/
/*
void finkenCoreExt::printControlValues() {
	simAddStatusbarMessage('throttle: '..throttleTarget)
	simAddStatusbarMessage('pitch: '..pitchTarget)
	simAddStatusbarMessage('roll: '..rollTarget)
	simAddStatusbarMessage('yaw: '..yawTarget)
	simAddStatusbarMessage('height: '..heightTarget)
}

void finkenCoreExt::printSensorData()
	simAddStatusbarMessage('dist_front: ' ..sensorDistances[1])
	simAddStatusbarMessage('dist_left: ' ..sensorDistances[2])
	simAddStatusbarMessage('dist_back: ' ..sensorDistances[3])
	simAddStatusbarMessage('dist_right: ' ..sensorDistances[4])
end
*/

/*
--step() is called for each simulation step and controls the model. First, all target values are read,
--then, the pid-controller are updated and the target speed for each rotor is computed
--@return(float velocity, float velocity, float velocity, float velocity)
*/
float* step() {
  /*local execution_current_time = simGetSimulationTime()
  simAddStatusbarMessage(execution_last_time + execution_step_size)
  simAddStatusbarMessage(execution_current_time)
  if (execution_last_time + execution_step_size <= execution_current_time) then
	   execution_last_time = execution_current_time*/

  float throttleTarget = -1;
  float pitchTarget = -1;
  float rollTarget = -1;
  float yawTarget = -1;
  float heightTarget =-1;

  if (simGetFloatSignal(fixSignalName("throttle"), &throttleTarget) == 1){

  }
  else {
    simAddStatusbarMessage("error retrieving throttle Signal");
  }
  if (simGetFloatSignal(fixSignalName("pitch"), &pitchTarget) == 1){

  }
  else {
    simAddStatusbarMessage("error retrieving pitch Signal");
  }
  if (simGetFloatSignal(fixSignalName("roll"), &rollTarget) == 1){

  }
  else {
    simAddStatusbarMessage("error retrieving roll Signal");
  }
  if (simGetFloatSignal(fixSignalName("yaw"), &yawTarget) == 1){

  }
  else {
    simAddStatusbarMessage("error retrieving yaw Signal");
  }
  if (simGetFloatSignal(fixSignalName("height"), &heightTarget) == 1){

  }
  else {
    simAddStatusbarMessage("error retrieving height Signal");
  }

	//invert roll and yaw axis to match real finken
	rollTarget = -rollTarget;
	yawTarget = -yawTarget;
	//logit-like function to fine tune throttle response
	throttleTarget =  tuneThrottle(throttleTarget, 1, 1);
	//hovers at approx. 50% throttle

  float basePosition[3] = {0};
  float linearVelocity[3] = {0};
  float angularVelocity[3] = {0};
  float eulerAngles[3] = {0};
  float trans_Matrix[12] = {0};
  float* ptrtrans_Matrix = trans_Matrix;

  if(simGetObjectPosition(finken.handle_FinkenBase, -1, basePosition) >0) {

  }
  else {
    simAddStatusbarMessage("Error retrieveing Finken Base Position");
  }
  float errorHeight = heightTarget - basePosition[3];
	cumulThrottle = cumulThrottle + errorHeight;

  if(simGetVelocity(finken.handle_finken, linearVelocity, angularVelocity) > 0) {

  }
  else {
    simAddStatusbarMessage("Error retrieving Finken velocity");
  }


	float throttle=5.843*throttleTarget/100; // + pPthrottle * errorHeight + iPthrottle * cumulThrottle + dPthrottle * (errorHeight - prevEThrottle) + l[3] * (-2)
	prevEThrottle = errorHeight;
  if(simGetObjectOrientation(finken.handle_FinkenBase, -1, eulerAngles) > 0) {

  }
  else {
    simAddStatusbarMessage("error retrieveing Finken Base Orientation");
  }

  if(simGetObjectMatrix(finken.handle_FinkenBase, -1, ptrtrans_Matrix) > 0){

  }
  else{
    simAddStatusbarMessage("Error retrieving Finken Base Transformation Matrix");
  }
	float vx[3] = {1,0,0};
  float vy[3] = {0,1,0};
  if (simTransformVector(trans_Matrix, vx) > 0){

  }
  else {
    simAddStatusbarMessage("Error transforming x vector");
  }
  if (simTransformVector(trans_Matrix, vy) > 0){

  }
  else {
    simAddStatusbarMessage("Error transforming y vector");
  }

  float rollAngleError = vy[2] - trans_Matrix[11];
  float pitchAngleError = vx[2] - trans_Matrix[11];
	//local rollAngleError=vy[3]-ins_matrix[12]
	//local pitchAngleError=-(vx[3]-ins_matrix[12])

	//pitch control:
  float errorPitch = pitchAngleError-(pitchTarget*(M_PI/180));
  float pitchCorr = finken.pitchController.step(errorPitch, execution_step_size /defaultStepSize);

	//roll control:
  float errorRoll = rollAngleError-(rollTarget*(M_PI/180));
  float rollCorr = finken.rollController.step(errorRoll, execution_step_size /defaultStepSize);

	// yaw control:
  float errorYaw = eulerAngles[2] - yawTarget*(M_PI/180);

  if (errorYaw < M_PI){
    errorYaw = 2*M_PI+errorYaw;
  }
	else{
    errorYaw = errorYaw - 2*M_PI;
  }


  float yawCorr = finken.yawController.step(errorYaw, execution_step_size / defaultStepSize);


	//Decide of the motor velocities:

	particlesTargetVelocities[1]=throttle * ( 1 + yawCorr - rollCorr + pitchCorr);
	particlesTargetVelocities[2]=throttle * (1 - yawCorr - rollCorr - pitchCorr);
	particlesTargetVelocities[3]=throttle * ( 1 + yawCorr + rollCorr - pitchCorr);
	particlesTargetVelocities[4]=throttle * ( 1 - yawCorr + rollCorr + pitchCorr);

  return particlesTargetVelocities;
}

void setTarget(int targetObject) {
	float targetPosition[3] = {0};
  float basePosition[3] = {0};
  if(simGetObjectPosition(targetObject, -1, targetPosition) >0) {

  }
  else {
    simAddStatusbarMessage("Error retrieveing Target Position");
  }
  if(simGetObjectPosition(finken.handle_FinkenBase, -1, basePosition) >0) {

  }
  else {
    simAddStatusbarMessage("Error retrieveing Finken Base Position");
  }

	float errorX = targetPosition[0] - basePosition[0];
	float errorY = targetPosition[1] - basePosition[1];
	float errorZ =  targetPosition[2]-basePosition[2];
	float corrX = finken.targetXcontroller.step(errorX, execution_step_size / defaultStepSize);
	float corrY = finken.targetYcontroller.step(errorY, execution_step_size / defaultStepSize);
	float corrZ = finken.targetZcontroller.step(errorZ, execution_step_size / defaultStepSize);
	simSetFloatSignal(fixSignalName("pitch"), corrX);
	simSetFloatSignal(fixSignalName("roll"), corrY);
	simSetFloatSignal(fixSignalName("throttle"), 50+corrZ);
	//simSetFloatSignal(finkenCore.fixSignalName('height'),targetPosition[3])
}
/*TODO : does this ever get called?
function finkenCore.getSensorHandles()
	return sensorHandles
end
*/

/*
--sense() reads all sensors of the finken, and updates the signals
--@return {float dist_front, float dist_left, float dist_back, float dist_right}
*/
int getSensorData(int handle, std::vector<float> &detectPoint, int &detectHandle, std::vector<float> &detectSurface ){
    return simHandleProximitySensor(handle, &detectPoint[0], &detectHandle, &detectSurface[0]);
}

 float* sense() {
   std::vector<float> detect_vector;
   int detect_handle;
   std::vector<float> detect_surface;
   int status =0;
   for (int i = 0; i<FINKEN_SENSOR_COUNT; i++) {
     //check sensor status
     status = getSensorData(finken.sensorHandles[i], detect_vector, detect_handle, detect_surface);
     if  (status <0){
       simAddStatusbarMessage("Error handling Proximity Sensors");
     }
     else if (status == 0){
        //nothing detected, reset sensorDistance
       sensorDistances[i] = 7.5;
     }
     else {
       //update sensorDistacnes and set signal
       sensorDistances[i] = detect_vector[3];
       char* thisSignalName = fixSignalName("sensor_dist" + SENSOR_ORIENTATION[i]);
       simSetFloatSignal(thisSignalName, sensorDistances[i]);
     }
   }
	return sensorDistances;
}

/*TODO: ist this necessary?
local finkenCoreExt::getPosition()
	return simGetObjectPosition(handle_FinkenBase, -1)
end

function finkenCore.getObjectHandle()
	return handle_finken
end
*/


VREP_DLLEXPORT unsigned char v_repStart(void* reservedPointer,int reservedInt)
{ // This is called just once, at the start of V-REP.
    // Dynamically load and bind V-REP functions:
    std::cout << "Starting FinkenCore";
    char curDirAndFile[1024];
#ifdef _WIN32
    #ifdef QT_COMPIL
        _getcwd(curDirAndFile, sizeof(curDirAndFile));
    #else
        GetModuleFileName(NULL,curDirAndFile,1023);
        PathRemoveFileSpec(curDirAndFile);
    #endif
#elif defined (__linux) || defined (__APPLE__)
    getcwd(curDirAndFile, sizeof(curDirAndFile));
#endif

    std::string currentDirAndPath(curDirAndFile);
    std::string temp(currentDirAndPath);

#ifdef _WIN32
    temp+="\\v_rep.dll";
#elif defined (__linux)
    temp+="/libv_rep.so";
#elif defined (__APPLE__)
    temp+="/libv_rep.dylib";
#endif /* __linux || __APPLE__ */

    vrepLib=loadVrepLibrary(temp.c_str());
    if (vrepLib==NULL)
    {
        std::cout << "Error, could not find or correctly load v_rep.dll. Cannot start 'FinkenCore' plugin.\n";
        return(0); // Means error, V-REP will unload this plugin
    }
    if (getVrepProcAddresses(vrepLib)==0)
    {
        std::cout << "Error, could not find all required functions in v_rep.dll. Cannot start 'FinkenCore' plugin.\n";
        unloadVrepLibrary(vrepLib);
        return(0); // Means error, V-REP will unload this plugin
    }

    // Check the V-REP version:
    int vrepVer;
    simGetIntegerParameter(sim_intparam_program_version,&vrepVer);
    if (vrepVer<30200) // if V-REP version is smaller than 3.02.00
    {
        std::cout << "Sorry, your V-REP copy is somewhat old, V-REP 3.2.0 or higher is required. Cannot start 'FinkenCore' plugin.\n";
        unloadVrepLibrary(vrepLib);
        return(0); // Means error, V-REP will unload this plugin
    }

    // Register 4 new Lua commands:
    simRegisterScriptCallbackFunction(strConCat(LUA_INIT_COMMAND,"@",PLUGIN_NAME),strConCat("number finkenHandle=",LUA_INIT_COMMAND,"(number finkenhandle,)"),LUA_INIT_CALLBACK);


    return(8); // initialization went fine, we return the version number of this plugin (can be queried with simGetModuleName)
    // version 1 was for V-REP versions before V-REP 2.5.12
    // version 2 was for V-REP versions before V-REP 2.6.0
    // version 5 was for V-REP versions before V-REP 3.1.0
    // version 6 is for V-REP versions after V-REP 3.1.3
    // version 7 is for V-REP versions after V-REP 3.2.0 (completely rewritten)
    // version 8 is for V-REP versions after V-REP 3.3.0 (using stacks for data exchange with scripts)
}

VREP_DLLEXPORT void v_repEnd()
{ // This is called just once, at the end of V-REP
  unloadVrepLibrary(vrepLib); // release the library
}

VREP_DLLEXPORT void* v_repMessage(int message,int* auxiliaryData,void* customData,int* replyData)
{ // This is called quite often. Just watch out for messages/events you want to handle
  // This function should not generate any error messages:
  int errorModeSaved;
  simGetIntegerParameter(sim_intparam_error_report_mode,&errorModeSaved);
  simSetIntegerParameter(sim_intparam_error_report_mode,sim_api_errormessage_ignore);

  void* retVal=NULL;



  if (message==sim_message_eventcallback_simulationended)
  { // simulation ended. Destroy all BubbleRob instances:

  }
}
