#pragma once

#include "FinkenTrafGen.h"


#include <vector>
#include <boost/bimap.hpp>
#include <v_repLib.h>
#include <omnetpp.h>
#include <Coord.h>

namespace FinkenComm{

class FinkenOmnetSim {
	public:
		typedef struct {
			float x;
			float y;
			float z;
		} coordinates_t;
		typedef struct {
			std::string sourceAddress;
			simtime_t timeStamp;
			std::vector<unsigned char> payload;
		} oppPacket_t;
		
		FinkenOmnetSim(int argc, char *argv[]);
		virtual ~FinkenOmnetSim();
		static FinkenOmnetSim* getInstanceById(unsigned int instanceId);
	
		std::vector<simInt>getVrepCommNodeHandles();
		int resolveMAC2SimHandle(std::string);

		void launchSim(std::vector<std::string>& simFolders, std::string simName, std::string iniFile, std::string confSection);
		void simulate( simtime_t limit);
		void updatePositions(std::map<simInt,coordinates_t> vrepObjectsPositions, simtime_t timeStamp);
		void endSim();
		
		void addVrepCommNode(std::string macAddress, int vrepHandle);
		void sendData(simInt sourceHandle, simInt targetHandle, simtime_t timeStamp,  const std::vector<unsigned char> payload,  int flags);
		void sendData(simInt sourceHandle, simInt targetHandle, simtime_t timeStamp,  const unsigned char* payload, int payloadLength, int flags);
		void writeReceivedData( std::string targetAddress, oppPacket_t oppPacket,  int flags);
		std::vector<oppPacket_t> removeReceivedData(int vrepHandle);
	private:
		static std::vector<std::unique_ptr<FinkenOmnetSim>> finkenOmnetSimInstances;
		cStaticFlag dummy;
		boost::bimap<std::string, int> mapMacVrephandle;
		boost::bimap<std::string, cModule*> mapMacOppHost;
		std::map<int, std::vector<oppPacket_t>> receivedPackets;
		cSimulation* sim;
		
		void initSim(const char *networkName, std::string iniFile, std::string confSection);
		const std::string resolveSimHandle2Mac(simInt targetHandle);
		void sendNextPosition(cModule *module, simtime_t timeStamp, Coord nextPosition);
};
}
