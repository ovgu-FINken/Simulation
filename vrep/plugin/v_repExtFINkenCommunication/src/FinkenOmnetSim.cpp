#include "FinkenOmnetSim.h"
#include "VrepSimEnv.h"
#include "vrepPacket_m.h"
#include "vrepCoords_m.h"

#include <boost/range/adaptor/map.hpp>
#include <boost/range/algorithm/copy.hpp>
#include <envir/inifilereader.h>
#include <envir/sectionbasedconfig.h>
#include <regmacros.h>
#include <scriptFunctionData.h>


/*!
* Definition of per run configurations which are declared but not defined. Missing definition results in "external variable just declared, not defined error"
* examples in envirbase.cc, regmacros.h and onstartup.h (Omnet++ files)
*/
Register_PerRunConfigOption(CFGID_NETWORK, "network", CFG_STRING, NULL, "The name of the network to be simulated.  The package name can be omitted if the ini file is in the same directory as the NED file that contains the network.");
Register_PerRunConfigOption(CFGID_SEED_SET, "seed-set", CFG_INT, "${runnumber}", "Selects the kth set of automatic random number seeds for the simulation. Meaningful values include ${repetition} which is the repeat loop counter (see repeat= key), and ${runnumber}.");
Register_PerRunConfigOption(CFGID_RESULT_DIR, "result-dir", CFG_STRING, "results", "Value for the ${resultdir} variable, which is used as the default directory for result files (output vector file, output scalar file, eventlog file, etc.)");

namespace FinkenComm {
	std::vector<std::unique_ptr<FinkenOmnetSim>> FinkenOmnetSim::finkenOmnetSimInstances = std::vector<std::unique_ptr<FinkenOmnetSim>>();
/*!
 *Constructor for an Omnet++ Simulation instance in a V-REP scene
 *
 */
FinkenOmnetSim::FinkenOmnetSim(int argc, char *argv[]) {
	CodeFragments::executeAll(CodeFragments::STARTUP);
	SimTime::setScaleExp(-9);
	sim = new cSimulation("", NULL);	
	finkenOmnetSimInstances.emplace_back(this);
}

FinkenOmnetSim::~FinkenOmnetSim() {
	CodeFragments::executeAll(CodeFragments::SHUTDOWN);
}

FinkenOmnetSim* FinkenOmnetSim::getInstanceById(unsigned int instanceId) {
	if (instanceId < FinkenOmnetSim::finkenOmnetSimInstances.size()){
		return FinkenOmnetSim::finkenOmnetSimInstances.at(instanceId).get();
	}
	return NULL;
}
/*!
 * return vector handles for all VREP object which are registered as a OMNeT++ communication host
 */
std::vector<simInt> FinkenOmnetSim::getVrepCommNodeHandles(){
	std::vector<simInt> vrepCommNodeHandles;
	boost::copy(this->mapMacVrephandle.right | boost::adaptors::map_keys, std::back_inserter(vrepCommNodeHandles));
	return vrepCommNodeHandles;
}

/*!
 *Initialisation Method for the Omnet++ simulation instance.
 *
 *Reads the configuration file iniFile, creates the configuration object, the cEnvir instance and the cSimulation instance.
 * sets the simulation as an active simulation and the network type for the simulation
 */
void FinkenOmnetSim::initSim(const char *networkName, std::string iniFile, std::string confSection) {
	cModuleType *networkType =  cModuleType::find(networkName);
	if (nullptr == networkType) {
		std::cout << "No such network: " << networkName << std::endl;
		return;
	}
	int argc = 0;
	char **argv = nullptr;

	InifileReader *confReader = new InifileReader();
    confReader->readFile(iniFile.c_str());
	
	SectionBasedConfiguration *cfg = new SectionBasedConfiguration();
	cfg->setConfigurationReader(confReader);
	//@TODO implement runNumber
	cfg->activateConfig(confSection.c_str(), 0);

	//@TODO remove test
    const char* myTestParam = cfg->getParameterValue("*","numHosts", false);
    std::cout << "numHosts: " << myTestParam << std::endl;
   // end test code
   
    cEnvir *env = new oppVrep::VrepSimEnv(argc, argv,  cfg);
    //disable all output of OMNeT++
	env->disable_tracing = true;
	sim = new cSimulation("simulation", env);
	cSimulation::setActiveSimulation(sim);
	//@TODO add exception handling
	sim->setupNetwork(networkType);

}

/*!
 *Method to run OMNeT simulation until it reaches the specified time
 *
 *The OMNeT simulation is run until the internal simulation time reaches the passed threshold
 *relies on an OMNeT internal timing model.
 *By passing the time of the next V-REP simulation step, a time synchronisation is achieved. 
 */
void FinkenOmnetSim::simulate( simtime_t limit) {
	/*//begin testcode
    if (limit >= 1){
		simtime_t now = sim->getSimTime();
		float test[3] = {-1, -1, -1};
		unsigned char* testData = (unsigned char*) test;
		std::cout << "testData" <<  testData[0] << testData[1] << testData[2] << testData[3] << std::endl;
		std::cout << "testDataFloat" <<  ((float*)testData)[0] <<  std::endl;
        sendData(96, 16, now,  testData, sizeof(test) , 0);
	}
	//end testcode*/
	try {
        while (sim->getSimTime() < limit) {
			cSimpleModule *mod = sim->selectNextModule(); //E!
			if (!mod)
				break;
			//begin testcode
            //if (this->mapMacOppHost.left.find("0A:AA:00:00:00:00:00:01")->second->getSubmodule("application") == mod) {
			//	std::cout << "found mobility module" << std::endl;
			//}
			//end testcode
			sim->doOneEvent(mod);  //E!
		}
	}
	catch (cTerminationException& e) {
		std::cout << "Finished: " << e.what() << std::endl;
	}
	catch (std::exception& e) {
		std::cout << "ERROR: " << e.what() << std::endl;
	}


}

/*!
 *Method to launch the previously initialized OMNeT simulation
 *
 *The NED files are loaded and the simulation is started.
 *To run the simulation, call the FinkenOmnetSim::simulate method
 */
void FinkenOmnetSim::launchSim(std::vector<std::string>& simFolders, std::string simName, std::string iniFile, std::string confSection){
	for (std::string simFolder : simFolders) cSimulation::loadNedSourceFolder(simFolder.c_str());
	cSimulation::doneLoadingNedFiles();

	initSim(simName.c_str(), iniFile, confSection);
	
	cModule *systemModule = cSimulation::getActiveSimulation()->getSystemModule();
	for (cModule::SubmoduleIterator i(systemModule); !i.end(); i++) {
		cModule *currentModule = i();
        if (nullptr != currentModule->getSubmodule("application")) {
            //std::cout << currentModule->getSubmodule("application")->getClassName() << std::endl;
			std::string macAddress = currentModule->getModuleByPath(".NIC.MAC.IEEE802154Mac")->par("macAddr").stringValue();
			mapMacOppHost.insert({macAddress, currentModule});	
		}
        else {
            std::cout << "Module: " << currentModule->getName() << " has no application submodule and is thus not a network node" << std::endl;
        }
	}
	
	//@TODO add exception handling
	try {
		sim->startRun();
	}
	catch (std::exception& e){
		std::cout << e.what() << std::endl;
	}
}

const std::string FinkenOmnetSim::resolveSimHandle2Mac(simInt targetHandle){
	if (sim_handle_all == targetHandle){
        return "FF:FF:FF:FF:FF:FF:FF:FF";
	}
	else {
		return this->mapMacVrephandle.right.find(targetHandle)->second.c_str();
	}
	return "00:00:00:00:00:00:00:00";
}

int FinkenOmnetSim::resolveMAC2SimHandle(std::string macAddress){
	if ("FF:FF:FF:FF:FF:FF:FF:FF" == macAddress){
        return sim_handle_all;
	}
	else {
		return this->mapMacVrephandle.left.find(macAddress)->second;
	}
	return 0;
}

/*!
 * register a VREP object as a communication host in the OMNeT++ simulation
 */
void FinkenOmnetSim::addVrepCommNode(std::string macAddress, int vrepHandle){
	mapMacVrephandle.insert({macAddress, vrepHandle});	
}

/*!
 * interface to sendData() for char* as payload
 */
void FinkenOmnetSim::sendData(simInt sourceHandle, simInt targetHandle, simtime_t timeStamp, const unsigned char* payload, int payloadLength, int flags){
	const std::vector<unsigned char> vectorPayload(payload, payload + payloadLength);
		//begin test code
		std::cout << "testData" <<  payload[0] << payload[1] << payload[2] << payload[3] << std::endl;
		std::cout << "testDataFloat" <<  ((float*)payload)[0] <<  std::endl;
		//end test code
	FinkenOmnetSim::sendData(sourceHandle, targetHandle, timeStamp, vectorPayload, flags);
}	

/*!
 * inserts a message request between two VREP objects into the OMNeT++ simulation
 * a traffic generator in the OMNeT simulation then handles the correct message creation for the communication simulation
 */
void FinkenOmnetSim::sendData(simInt sourceHandle, simInt targetHandle, simtime_t timeStamp, const std::vector<unsigned char>  payload, int flags){
	const std::string sourceAddress = FinkenOmnetSim::resolveSimHandle2Mac(sourceHandle);
	const std::string targetAddress = FinkenOmnetSim::resolveSimHandle2Mac(targetHandle);
    
    vrepMacPacket *newMacMsg = new vrepMacPacket("externMacPacket");
    MACAddressExt sourceMac(sourceAddress.c_str());
	MACAddressExt targetMac(targetAddress.c_str());
	newMacMsg->setPayload(payload);
	newMacMsg->setDestAddr(targetMac);
    newMacMsg->setSentFrom(this->mapMacOppHost.left.find(sourceAddress)->second->getSubmodule("application"), -1, timeStamp);
    newMacMsg->setArrival(this->mapMacOppHost.left.find(sourceAddress)->second->getSubmodule("application"), -1, timeStamp);
    
    sim->insertMsg(newMacMsg);	
	
	//returnResult = simSendData(sim_handle_all, 802154, "FINkenData", payload, 102, sourceHandle, 10, 3.14f, 6.28f, 0.0f);
}

/*!
 * puts a packet received in OMNeT++ in the global packet buffer with a VREP handle as key
 * 
 */
void FinkenOmnetSim::writeReceivedData(std::string targetAddress, oppPacket_t oppPacket, int flags){
	simInt targetHandle = this->mapMacVrephandle.left.find(targetAddress)->second;
	auto targetPackets_it = this->receivedPackets.find(targetHandle);
	
	if (targetPackets_it != this->receivedPackets.end()){
		targetPackets_it->second.emplace_back(oppPacket);
	}
	else {
		std::vector<oppPacket_t> newPacketVector;
		newPacketVector.emplace_back(oppPacket);
		this->receivedPackets.emplace(std::make_pair(targetHandle, newPacketVector));
	}
}

/*!
 *gets all received packets for the given VREP handle and removes them from the global buffer
 *returns empty vector if no packets are available
 */
std::vector<FinkenOmnetSim::oppPacket_t> FinkenOmnetSim::removeReceivedData(int vrepHandle){
	auto receivedPackets_it = this->receivedPackets.find(vrepHandle);
	if (receivedPackets_it != this->receivedPackets.end()){
		std::vector<oppPacket_t> receivedPacketsForHandle = receivedPackets_it->second;
		this->receivedPackets.erase(receivedPackets_it);
		return receivedPacketsForHandle;	
	}
	return std::vector<FinkenOmnetSim::oppPacket_t>();
}

//send new positions of V-REP objects to OPP mobility module 
void FinkenOmnetSim::updatePositions(std::map<simInt, coordinates_t> vrepObjectsPositions, simtime_t timeStamp){
	for (std::pair<simInt, coordinates_t> vrepObjectPosition : vrepObjectsPositions){
		std::string macAddress = this->mapMacVrephandle.right.find(vrepObjectPosition.first)->second;
		Coord position(vrepObjectPosition.second.x, vrepObjectPosition.second.y, vrepObjectPosition.second.z);
		sendNextPosition(this->mapMacOppHost.left.find(macAddress)->second->getSubmodule("mobility"), timeStamp, position);
	}
}

/*!
 * sends message with new object position to a module
 * a V-REP Mobility module will then update the position of the host in the OMNeT++
 * simulation accordingly at the given time
 */
void FinkenOmnetSim::sendNextPosition(cModule *module, simtime_t timeStamp, Coord nextPosition){
	vrepCoords *newPositionMsg = new vrepCoords("newPosition");
	newPositionMsg->setPosition(nextPosition);
	newPositionMsg->setSentFrom(module, -1, timeStamp); 	
	newPositionMsg->setArrival(module, -1, timeStamp);
	sim->insertMsg(newPositionMsg);
}

/*!
 * clean up and delete OMNeT++ simulation
 */
void FinkenOmnetSim::endSim(){
	//@TODO exception handling
	sim->callFinish();	
	//@TODO add exception handling
	sim->endRun();
	sim->deleteNetwork();
	cSimulation::setActiveSimulation(nullptr);
	delete sim;
}

}
