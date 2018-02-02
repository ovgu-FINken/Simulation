#include "FinkenTrafGen.h"
#include "vrepPacket_m.h"
#include "FinkenOmnetSim.h"
#include <NodeOperations.h>

//#include <IPv4ControlInfo.h>
//#include <IPv6ControlInfo.h>

//namespace FinkenComm {
Define_Module(FinkenTrafGen);

//register signals in Omnet
simsignal_t FinkenTrafGen::sentPkSignal = registerSignal("sentPk");
simsignal_t FinkenTrafGen::rcvdPkSignal = registerSignal("rcvdPk");

FinkenTrafGen::FinkenTrafGen() {
	nodeStatus = DOWN;
	packetLengthPar = NULL;
	sendIntervalPar = NULL;
	oppInstacePar = NULL;
	msgHandle = intrand(255);
}

FinkenTrafGen::~FinkenTrafGen() {
	cancelAndDelete(timer);
}

//originally differs between stage 0 and stage 3
//in stage 0:setup Protocol, simulation
//in stage 3:init IPSocket, start timer, startApp()
//@TODO stage 0 connect to vrep, read config from Vrep?
//stage 3
void FinkenTrafGen::initialize(int stage) {
	cSimpleModule::initialize(stage);
	if (stage == 0) {
        // initialize the debug output bool from NED parameter value
        trafficDebug = (hasPar("trafficDebug") ? (par("trafficDebug").boolValue()) : (false));
		//protocol = par("protocol");
        packetLengthPar = &par("packetLength");
        oppInstacePar = &par("oppInstace");
        ASSERT((packetLengthPar->longValue() <= 102) && (packetLengthPar->longValue() > 0)); // max 802.15.4 frame size is 127 octets, min header size is 23, FCS is 2
        nodeStatus = INIT;
		numSent = 0;
		numReceived = 0;
		WATCH(numSent);
		WATCH(numReceived);

	}
	else if (stage == 3) {
		nodeStatus = UP;
		//@TODO replace initial "timer" message
		timer = new cMessage("sendTimer");
	}

}




// sets the cMessage "timer" which gets handled by handleMessage
// which then sends the "real" message via sendPacket() (?) or, if
// the packet was received from an other client, processes and prints it via
// processPacket(PK(msg))
// remove and substitute by something that gets called by luaSendMessage()
void FinkenTrafGen::scheduleNextPacket(simtime_t previous) {
	simtime_t next;
	if (previous == -1) {
		next = simTime() <= startTime ? startTime : simTime();
		timer->setKind(START);
	}
	else {
		next = previous + sendIntervalPar->doubleValue();
		timer->setKind(NEXT);
	}
	if (stopTime < SIMTIME_ZERO || next < stopTime)
		scheduleAt(next, timer);
}


void FinkenTrafGen::cancelNextPacket() {
	cancelEvent(timer);
}
void FinkenTrafGen::handleMessage(cMessage *msg)
{
    // packets arrived from  application layer (V-REP simulation)
    vrepMacPacket *vrepPacket = dynamic_cast<vrepMacPacket*>(msg);
    if (vrepPacket){
		sendPacket(vrepPacket->getDestAddr(), vrepPacket->getPayload());
    }
    //packets arrived from lower layer of OMNeT++ simulation
    else {
    	processPacket(check_and_cast<cPacket *>(msg));
	}
    if (ev.isGUI())
    {
        char buf[40];
        sprintf(buf, "rcvd: %d pks\nsent: %d pks", numReceived, numSent);
        getDisplayString().setTagArg("t", 0, buf);
    }
}
bool FinkenTrafGen::isNodeUp() {
	//return false;
	return nodeStatus == UP;
}
//@TODO add payload parameter (const char *payload?)
void FinkenTrafGen::sendPacket(const MACAddressExt destAddr, const std::vector<unsigned char> payloadData) {
	std::vector<unsigned char> payloadDataFitted = payloadData;

	if (payloadDataFitted.size() > packetLengthPar->longValue()){
			payloadDataFitted.resize(packetLengthPar->longValue());
	}
	//sprintf(reinterpret_cast<char*>(payloadDataFitted.data()), "appData-%d", numSent);
    char msduName[20];
    sprintf(msduName, "msdu-%d-%d", msgHandle, numSent);

	msduPayload *payloadPacket = new msduPayload(msduName);
	payloadPacket->setByteLength(payloadDataFitted.size());
    payloadPacket->setPayload(payloadDataFitted);

    mcpsDataReq* dataReq = new mcpsDataReq("MCPS-DATA.request");
    dataReq->encapsulate(payloadPacket );

    ASSERT(msgHandle <= 255);   // sequence number in MPDU is 8-bit / unsigned char
    dataReq->setMsduHandle(msgHandle);
    (msgHandle < 255) ? msgHandle++ : msgHandle = 0;    // check if 8-bit sequence number needs to roll over
    dataReq->setMsduLength(payloadPacket ->getByteLength());
    ASSERT(getModuleByPath("^.Network.stdLLC") != NULL);    // getModuleByPath shall return the MAC module
    //fullPath = 'net.IEEE802154Nodes[0].Network.stdLLC.TXoption' (string)
    dataReq->setTxOptions(getModuleByPath("^.Network.stdLLC")->par("TXoption").longValue());
	dataReq->setDstAddr(destAddr);

    trafficEV << "Packet generated: " << payloadPacket  << endl;
    trafficEV << "Destination Address is: " << (dataReq->getDstAddr().str()) << " | MSDU Handle: " << (int) (dataReq->getMsduHandle()) << endl;
    trafficEV << "MSDU Length: " << (int) (dataReq->getMsduLength()) << " bytes" << endl;
    if (trafficDebug) {
    	unsigned char* dataRaw = payloadPacket->getPayload().data();
        float pos[3];
        pos[0] = ((float*)dataRaw)[0];
        pos[1] = ((float*)dataRaw)[1];
        pos[2] = ((float*)dataRaw)[2];
        //trafficEV << "Received payload: " << payloadPacket->getPayload().data() << endl;
        trafficEV << "sent payload: " << payloadPacket << "length: " << payloadPacket->getByteLength() <<" fit: " <<pos[0] << " x: " << pos[1] << " y: " << pos[2] << endl;
	}
	emit(sentPkSignal, payloadPacket);
	send(dataReq, "trafficOut");
	numSent++;

}



void FinkenTrafGen::printPacket(cPacket *msg) {
	//we don't have IP adresses on MAC layer
	/*	IPvXAddress src, dest;
	int protocol = -1;
	if (dynamic_cast<IPv4ControlInfo *>(msg->getControlInfo()) != NULL) {
		IPv4ControlInfo *ctrl = (IPv4ControlInfo *) msg->getControlInfo();
		src = ctrl->getSrcAddr();
		dest = ctrl->getSrcAddr();
		protocol = ctrl->getProtocol();
	}
	else if (dynamic_cast<IPv6ControlInfo *>(msg->getControlInfo()) != NULL) {
		IPv6ControlInfo *ctrl = (IPv6ControlInfo *) msg->getControlInfo();
		src = ctrl->getSrcAddr();
		dest = ctrl->getSrcAddr();
		protocol = ctrl->getProtocol();
	}*/
	EV << msg << endl;
	trafficEV << "Payload length: " << msg->getByteLength() << " bytes" << endl;
	//if (protocol != -1) {
	//	EV << "src: " << src << " dest: " << dest << " protocol: " << protocol << endl;
	//}

}

//processes a received packet
void FinkenTrafGen::processPacket(cPacket *msg) {
    emit(rcvdPkSignal, msg);
	printPacket(msg);

    if (dynamic_cast<mcpsDataInd*>(msg))
    {
        mcpsDataInd* ind = check_and_cast<mcpsDataInd*>(msg);
        msduPayload* payloadPacket = dynamic_cast<msduPayload*>(ind->decapsulate());
        if (payloadPacket){
        trafficEV << "Got MCPS-Data.indication for Message #" << (int) (ind->getDSN()) << " from " << (ind->getSrcAddr().str()) << endl;
        //test code begin
        unsigned char* dataRaw = payloadPacket->getPayload().data();
        float pos[3];
        pos[0] = ((float*)dataRaw)[0];
        pos[1] = ((float*)dataRaw)[1];
        pos[2] = ((float*)dataRaw)[2];
        //trafficEV << "Received payload: " << payloadPacket->getPayload().data() << endl;
        trafficEV << "Received payload: " << payloadPacket << " fit: " <<pos[0] << " x: " << pos[1] << " y: " << pos[2] << endl;
		//test code end
		FinkenComm::FinkenOmnetSim* simInstance =  FinkenComm::FinkenOmnetSim::getInstanceById(oppInstacePar->longValue());
		float arrivalTime = ind->getArrivalTime().dbl();
		float packetTimeStamp = ind->getTimestamp().dbl();
		trafficEV << "arrivalTime: " << arrivalTime << " timeStamp: " << packetTimeStamp << endl;
		FinkenComm::FinkenOmnetSim::oppPacket_t simPacket;
		simPacket.sourceAddress = ind->getSrcAddr().str();
		simPacket.timeStamp = ind->getArrivalTime();
		simPacket.payload = payloadPacket->getPayload();
		std::string myMacAddress = this->getParentModule()->getModuleByPath(".NIC.MAC.IEEE802154Mac")->par("macAddr");
		//simInstance->writeReceivedData(ind->getDstAddr().str(), simPacket, 0);
		simInstance->writeReceivedData(myMacAddress, simPacket, 0);
        }
        else {
        cPacket* payloadPacket = ind->decapsulate();
        trafficEV << "Got MCPS-Data.indication for Message #" << (int) (ind->getDSN()) << " from " << (ind->getSrcAddr().str()) << endl;
        trafficEV << "Received payload: " << payloadPacket << endl;

        }
    } // (dynamic_cast<mcpsDataInd*>(msg))
    else if (dynamic_cast<mcpsDataConf*>(msg))
    {
        mcpsDataConf* conf = check_and_cast<mcpsDataConf*>(msg);

        trafficEV << "Got MCPS-Data.confirm for Message #" << (int) (conf->getMsduHandle()) << " with status: " << MCPSStatusToString(MCPSStatus(conf->getStatus())) << endl;

        if (ev.isGUI())
        {
            char buf[22];
            if (conf->getStatus() == SUCCESS)
            {
                this->setDisplayString("i=block/join,#80FF00,45;i2=status/green");
                sprintf(buf, "status/green");
            }
            else if (conf->getStatus() == NO_ACK)
            {
                this->setDisplayString("i=block/join,##FF0000,45;i2=status/red");
                sprintf(buf, "status/red");
            }
            getModuleByPath("^")->getDisplayString().setTagArg("i2", 0, buf);
        }
    }
    else {
        trafficEV << "received a packet: " << msg << endl;
    }

    delete msg;
    numReceived++;
}
//}
