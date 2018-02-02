#pragma once

#include <vector>
#include <omnetpp.h>

#include <INETDefs.h>
#include <ILifecycle.h>
#include <MACAddressExt.h>

#include "MPDU_m.h"
#include "mcpsData_m.h"

#define trafficEV (ev.isDisabled()||!trafficDebug) ? EV : EV << "[802154_TRAFFIC]: " // switchable debug output
//namespace FinkenComm {
class FinkenTrafGen : public cSimpleModule {
	protected:
        /** @brief Debug output switch for the traffic generator module */
        bool trafficDebug = false;
		enum Kinds {START = 100, NEXT};
		//deprecated begin
		enum status { INIT, UP, DOWN};
		status nodeStatus; 
		int protocol;
		bool isOperational;
		cPar *oppInstacePar;	
		simtime_t startTime;
		simtime_t stopTime;
		//deprecated end
		
		cMessage *timer;

		int numSent;
		int numReceived;
				
		std::vector<MACAddressExt> destAddresses;
		//deprecated?
		cPar *sendIntervalPar;
		cPar *packetLengthPar;
		static simsignal_t sentPkSignal;
		static simsignal_t rcvdPkSignal;
	private:
		//internal 8-bit messageHandle (msdu, MAC DSN)
		unsigned char msgHandle;

	public:
		FinkenTrafGen();
		virtual ~FinkenTrafGen();
		virtual void sendPacket(const MACAddressExt destAddr, const std::vector<unsigned char> payloadData);

	protected:
		virtual int numInitStages() const { return 4; };
		virtual void initialize(int stage);
		virtual void handleMessage(cMessage *msg);
		virtual void scheduleNextPacket(simtime_t previous);
		virtual void processPacket(cPacket *msg);
		
		
		virtual void cancelNextPacket();
		virtual bool isNodeUp();
		virtual void printPacket(cPacket *msg);
	

		

};
//}
