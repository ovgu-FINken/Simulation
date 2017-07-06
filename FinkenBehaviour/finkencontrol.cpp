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

float particlesTargetVelocities[4] = {-1,-1,-1,-1};

float execution_step_size = 0;
float execution_last_time = 0;
float defaultStepSize = 0.050;





const char* fixSignalName(std::string signalName) {
    return signalName.c_str();
}

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

//old step function, non-functional
float* step(Finken* finken) {
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

    std::cout << "targets: " << throttleTarget << " " << pitchTarget << " " << heightTarget << '\n';


    //invert roll and yaw axis to match real finken
    rollTarget = -rollTarget;
    yawTarget = -yawTarget;
    //logit-like function to fine tune throttle response
    //throttleTarget =  tuneThrottle(throttleTarget, 1, 1);
    //hovers at approx. 50% throttle



  std::vector<float> basePosition = {0,0,0};
  float linearVelocity[3] = {0};
  float angularVelocity[3] = {0};
  float eulerAngles[3] = {0};
  float trans_Matrix[12] = {0};
  float* ptrtrans_Matrix = trans_Matrix;

  if(finken->getSensors().at(0)->get(basePosition) >0) {

  }
  else {
    simAddStatusbarMessage("Error retrieveing Finken Base Position");
  }
  float errorHeight = heightTarget - basePosition[2];
  cumulThrottle = cumulThrottle + errorHeight;


  if(simGetVelocity(finken->handle, linearVelocity, angularVelocity) > 0) {

  }
  else {
    simAddStatusbarMessage("Error retrieving Finken velocity");
  }


  float throttle=5.843*throttleTarget/100; // + pPthrottle * errorHeight + iPthrottle * cumulThrottle + dPthrottle * (errorHeight - prevEThrottle) + l[3] * (-2)  

  prevEThrottle = errorHeight;
  if(simGetObjectOrientation(finken->handle, -1, eulerAngles) > 0) {

  }
  else {
    simAddStatusbarMessage("error retrieveing Finken Base Orientation");
  }

  if(simGetObjectMatrix(finken->handle, -1, ptrtrans_Matrix) > 0){

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

  //pitch control:
  float errorPitch = pitchAngleError-(pitchTarget*(M_PI/180));
  float pitchCorr = finken->pitchController.step(errorPitch, (execution_step_size/defaultStepSize));

  //roll control:
  float errorRoll = rollAngleError-(rollTarget*(M_PI/180));
  float rollCorr = finken->rollController.step(errorRoll, (execution_step_size/defaultStepSize));

  // yaw control:
  float errorYaw = eulerAngles[2] - yawTarget*(M_PI/180);


  std::cout << "errors:  " << errorRoll << " " << errorPitch << " " << errorYaw << " " << errorHeight << '\n';
  std::cout << "corrs1:  " << rollCorr << " " << pitchCorr << " " << throttleTarget << '\n';


  if (errorYaw < M_PI){
    errorYaw = 2*M_PI+errorYaw;
  }
    else{
    errorYaw = errorYaw - 2*M_PI;
  }


  float yawCorr = finken->yawController.step(errorYaw, execution_step_size / defaultStepSize);


    //Decide of the motor velocities:

    particlesTargetVelocities[0]=throttle + ( + yawCorr - rollCorr + pitchCorr);
    particlesTargetVelocities[1]=throttle + (- yawCorr - rollCorr - pitchCorr);
    particlesTargetVelocities[2]=throttle + (  + yawCorr + rollCorr - pitchCorr);
    particlesTargetVelocities[3]=throttle + (  - yawCorr + rollCorr + pitchCorr);
    std::cout << particlesTargetVelocities[0] << '\n';
    std::cout << particlesTargetVelocities[1] << '\n';
    std::cout << particlesTargetVelocities[2] << '\n';
    std::cout << particlesTargetVelocities[3] << '\n';
  return particlesTargetVelocities;
}


//new step function - WIP
float* steps(Finken* finken) {
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
      errorYaw = errorYaw - 2*M_PI;
    }


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
    particlesTargetVelocities[0]=throttle + heightCorr;
    particlesTargetVelocities[1]=throttle + heightCorr;
    particlesTargetVelocities[2]=throttle + heightCorr;
    particlesTargetVelocities[3]=throttle + heightCorr;

    return particlesTargetVelocities;

}

