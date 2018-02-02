cplusplus {{
	#include "vrep802154conf.h"
	#include "mcpsData_m.h"
}};


// This packet is inserted by the V-REP plugin into the OMNeT++ message
// queue to initiate a transmission in the OMNeT++ simulation module

class noncobject macAddrDataype;
class noncobject payloadVector;
message vrepMacPacket {
	macAddrDataype destAddr;
	payloadVector payload;
}
