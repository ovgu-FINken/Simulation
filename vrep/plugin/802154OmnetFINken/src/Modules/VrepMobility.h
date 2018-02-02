#pragma once

#ifndef VREPMOBILITY_H
#define VREPMOBILITY_H

#include <INETDefs.h>
#include <MovingMobilityBase.h>

class VrepMobility : public MovingMobilityBase{
	protected:
		Coord newPosition;
		virtual void handleSelfMessage(cMessage *msg);
		virtual void move();
	public:
		VrepMobility(); 
};
#endif /* ifndef VREPMOBILITY_H */
