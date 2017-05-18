#include "finken.h"
#include <iostream>
#include "v_repLib.h"


static int kFinkenSonarCount = 4;
static int kFinkenHeightSensorCount = 1;
static std::string kFinkenName = "FINken2";

Finken::Finken() {}

void Finken::addSensor(std::unique_ptr<Sensor> &sensor){
    this->sensors.push_back(std::move(sensor));
    std::cout << "Adding sensor to finken" << '\n';
}

std::vector<std::unique_ptr<Sensor>> &Finken::getSensors(){
    return this->sensors;
}

void buildFinken(Finken &finken){
    int fHandle = simGetObjectHandle(kFinkenName.c_str());
    finken.handle = fHandle;
    int foundSensorCount = 0;

    //Grab all Proximity sensors and add them to the finken:
    int* proxSensorHandles = simGetObjectsInTree(fHandle, sim_object_proximitysensor_type, 1, &foundSensorCount);
    for(int i = 0; i<foundSensorCount; i++){
        //we have kFinkenSonarCount sonars:
        if(i < kFinkenSonarCount){
            std::unique_ptr<Sensor> ps(new Sonar (proxSensorHandles[i]));
            finken.addSensor(ps);
        }
        //the rest are HeightSensors:
        else {
            std::unique_ptr<Sensor> hs(new HeightSensor(proxSensorHandles[i]));
            finken.addSensor(hs);
        }

    }
    //apparently this is necessary according to vrep API(shoudnt it go out of scope anyways?)
    simReleaseBuffer((char *) proxSensorHandles);
}
