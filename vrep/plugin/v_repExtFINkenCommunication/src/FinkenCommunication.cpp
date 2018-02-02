#include "FinkenCommunication.h"

//#include <Log.h>
#include <iostream>

#include "FinkenCommLuaFunctions.h"

#define CONCAT(x,y,z) x y z
#define strConCat(x,y,z)	CONCAT(x,y,z)

#define PATH_TO_802154 "communication/802154OmnetFINken"
#define PATH_TO_INETSRC "communication/inet/src"
#define SCENARIO_NAME "FINken_eval00"
namespace FinkenComm {
FinkenCommunication plugin;
	

unsigned char FinkenCommunication::version() const
{
  return 1;
}

const std::string FinkenCommunication::name() const
{
  return "FINken_Communication";
}


bool FinkenCommunication::load() {
	FinkenCommunication::oppSimulation = NULL;
	FinkenCommLuaFunctions::register_FINKENREGISTERMAC();
	FinkenCommLuaFunctions::register_FINKENSENDDATA();
	FinkenCommLuaFunctions::register_FINKENRECEIVEDATA();
	std::cout << "loaded" << FinkenCommunication::name() << std::endl;
  	return true;
}

bool FinkenCommunication::unload() {
  	oppSimulation->endSim();
  	delete oppSimulation;
	std::cout << "unloaded" << FinkenCommunication::name() << std::endl;
  	return true;
}

void* FinkenCommunication::simStart(int *auxiliaryData, void *customData, int *replyData) {
	FinkenCommunication::oppSimulation = new FinkenOmnetSim(0, nullptr);
	std::vector<std::string> finkenOmnetNEDfolders;
	std::string omnetSimPath = std::string(PATH_TO_802154);
	finkenOmnetNEDfolders.push_back(omnetSimPath);
	finkenOmnetNEDfolders.push_back(PATH_TO_INETSRC);
	std::string omnetSimName = "ieee802154.simulations.net";
	std::string omnetIniFile = omnetSimPath + "/simulations/omnetpp.ini";
	std::string omnetConfSection = SCENARIO_NAME;
	oppSimulation->launchSim(finkenOmnetNEDfolders, omnetSimName, omnetIniFile, omnetConfSection);
	return nullptr;
}

void* FinkenCommunication::action(int *auxiliaryData, void *customData, int *replyData) {
	std::map<simInt, FinkenOmnetSim::coordinates_t> finkensPositions;
	std::vector<simInt> finkenHandles = oppSimulation->getVrepCommNodeHandles();
	for(simInt finkenHandle : finkenHandles){
		simFloat position[3];
		simGetObjectPosition(finkenHandle, -1, position);
		FinkenOmnetSim::coordinates_t finkenPosition;	
		finkenPosition.x = position[0];
		finkenPosition.y = position[1];
		finkenPosition.z = position[2];
		finkensPositions.emplace(finkenHandle, finkenPosition);
	}

	oppSimulation->updatePositions(finkensPositions, simGetSimulationTime());
	float vrepNextStepSimTime =simGetSimulationTime() +	simGetSimulationTimeStep();
	oppSimulation->simulate(vrepNextStepSimTime);	
	
	return nullptr;
}

void* FinkenCommunication::simEnd(int *auxiliaryData, void *customData, int *replyData) {
	oppSimulation->endSim();
	return nullptr;
}
}
