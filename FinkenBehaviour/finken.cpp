#include "finken.h"
#include <iostream>
#include "v_repLib.h"
#include <memory>

static int kFinkenSonarCount = 4;
static int kFinkenHeightSensorCount = 1;
static std::string kFinkenName = "FINken2";

Finken::Finken(int fHandle) : handle(fHandle){}

void Finken::addSensor(std::unique_ptr<Sensor> &sensor){
    this->sensors.push_back(std::move(sensor));
    std::cout << "Adding sensor to finken" << '\n';
}

void Finken::addRotor(std::unique_ptr<Rotor> &rotor){
    this->rotors.push_back((std::move(rotor)));
    std::cout << "Adding rotor to finken" << '\n';
}



std::vector<std::unique_ptr<Sensor>> &Finken::getSensors(){
    return this->sensors;
}


std::vector<std::unique_ptr<Rotor>> &Finken::getRotors(){
    return this->rotors;
}

std::unique_ptr<Finken> buildFinken(){
    int fHandle = simGetObjectHandle(kFinkenName.c_str());
    std::unique_ptr<Finken> finken (new Finken(fHandle));
    int foundSensorCount = 0;

    //Grab all Proximity sensors and add them to the finken:
    int* proxSensorHandles = simGetObjectsInTree(fHandle, sim_object_proximitysensor_type, 1, &foundSensorCount);
    for(int i = 0; i<foundSensorCount; i++){
        //we have kFinkenSonarCount sonars:
        if(i < kFinkenSonarCount){
            std::unique_ptr<Sensor> ps(new Sonar (proxSensorHandles[i]));
            finken->addSensor(ps);
        }
        //the rest are HeightSensors:
        else {
            std::unique_ptr<Sensor> hs(new HeightSensor(proxSensorHandles[i]));
            finken->addSensor(hs);
        }

    }

    //Grab all Rotors and add them to the finken:
    int rHandle = simGetObjectHandle(kFinkenName.c_str());

    for(int i = 1; i<5; i++){
        int rHandle = simGetObjectHandle(("SimFinken_rotor_respondable" + std::to_string(i)).c_str());
        std::unique_ptr<Rotor> vr(new Rotor(rHandle));
        finken->addRotor(vr);
    }




    return finken;
    //apparently this is necessary according to vrep API(shoudnt it go out of scope anyways?)
    simReleaseBuffer((char *) proxSensorHandles);
}
