#include "VrepMobility.h"
#include "vrepCoords_m.h"

Define_Module(VrepMobility);

VrepMobility::VrepMobility(){
	newPosition = Coord::ZERO;
}

void VrepMobility::handleSelfMessage(cMessage *msg){
	vrepCoords *newVrepCoords = dynamic_cast<vrepCoords*>(msg);
	if (newVrepCoords){
		newPosition = newVrepCoords->getPosition();
	}
	moveAndUpdate();
	scheduleUpdate();
}

void VrepMobility::move() {
	lastSpeed = (newPosition - lastPosition) / (simTime() - lastUpdate).dbl(); 
	lastPosition = newPosition;
	lastUpdate = simTime();
	nextChange = -1;
}
