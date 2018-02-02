#include "FinkenCommLuaFunctions.h"

#include "FinkenOmnetSim.h"

namespace FinkenComm {
#define CONCAT(x,y,z) x y z
#define strConCat(x,y,z)	CONCAT(x,y,z)

//name the new lua command
#define LUA_FINKENREGISTERMAC_COMMAND "simExtFinken_registerMac@FINkenCommunication"  
#define LUA_FINKENSENDDATA_COMMAND "simExtFinken_sendData@FINkenCommunication"  
#define LUA_FINKENRECEIVEDATA_COMMAND "simExtFinken_receiveData@FINkenCommunication"

const int inArgs_FINKENREGISTERMAC[] = {
	2,
	sim_script_arg_int32, 0, 		//FinkenOmnetSim instance index
	sim_script_arg_charbuff, 23,	//MAC address
};
//define the arguments for the lua function
//arg1 number of arguments
//arg2..n simu_lua-datatype and array length (0 for no array)
const int inArgs_FINKENSENDDATA[] = { 
	4,
	sim_script_arg_int32, 0, //FinkenOmnetSim instance index
	sim_script_arg_int32, 0, //target handle
//	sim_script_arg_string, 0,//payload zeros appearently terminates string in readDataFromStack()
	sim_script_arg_charbuff, 102,//payload
	sim_script_arg_int32, 0, //payload data length
};

const int inArgs_FINKENRECEIVEDATA[] = {
	1,
	sim_script_arg_int32, 0,
};
/*! custom Lua function to map V-REP handle to Omnet++ MAC adress
 */
void FinkenCommLuaFunctions::luaSimExtFinken_registerMac_callback(SScriptCallBack* cb){
	CScriptFunctionData D;
	if (D.readDataFromStack(cb->stackID, inArgs_FINKENREGISTERMAC, inArgs_FINKENREGISTERMAC[0], LUA_FINKENREGISTERMAC_COMMAND)){
		std::vector<CScriptFunctionDataItem>* inData = D.getInDataPtr();
		int instanceIndex = inData->at(0).int32Data[0];
		std::basic_string<char> macAddress = inData->at(1).stringData[0];
		try {
			FinkenOmnetSim* finkenOmnetSimInstance = FinkenOmnetSim::getInstanceById(instanceIndex);
			finkenOmnetSimInstance->addVrepCommNode(macAddress, cb->objectID);
			D.pushOutData(CScriptFunctionDataItem(true));
		}
		catch (const std::exception& e){
			simSetLastError(LUA_FINKENREGISTERMAC_COMMAND, e.what());
			D.pushOutData(CScriptFunctionDataItem(false));
		}
	}
	D.writeDataToStack(cb->stackID);
}

/*! custom Lua function to send data via Omnet++
 */
void FinkenCommLuaFunctions::luaSimExtFinken_sendData_callback(SScriptCallBack* cb){ 
	CScriptFunctionData D;
	if (D.readDataFromStack(cb->stackID,inArgs_FINKENSENDDATA,inArgs_FINKENSENDDATA[0],LUA_FINKENSENDDATA_COMMAND))
	{ // above function reads in the expected arguments. If the arguments are wrong, it returns false and outputs a message to the simulation status bar
		std::vector<CScriptFunctionDataItem>* inData=D.getInDataPtr();
		//accessing the first, second, n-th element with at(n)
		int oppInstance=inData->at(0).int32Data[0]; 
		int targetHandle=inData->at(1).int32Data[0];
		std::basic_string<char> dataContent=inData->at(2).stringData[0];
		int messageLength=inData->at(3).int32Data[0];
		// Now you can do something with above's arguments. For example:
		//simSendData(targetID, dataHeader, dataName, data, datalength, antennaHandle, actionRadius, emissionAngleVertically(antennas z-axis 0<alpha<pi), emissionAngleHorizontally(antennas x-y-axis 0<beta<2pi), persistance(factor for simTimeStep))
		//returnResult = simSendData(sim_handle_all, 802154, std::to_string(oppInstance).c_str(), dataContent.c_str(), dataContent.length(), cb->objectID,signalPower, 3.14f, 6.28f, 0.0f);
		simFloat simulationTimeStep = simGetSimulationTimeStep(); 
		//returnResult = simSendData(sim_handle_all, 802154, std::to_string(oppInstance).c_str(), dataContent.c_str(), dataContent.length(), sim_handle_self, 25, 3.1416, 6.283, 1*simulationTimeStep);
		FinkenOmnetSim* finkenOmnetSimInstance = FinkenOmnetSim::getInstanceById(oppInstance);
		simFloat now = simGetSimulationTime();
		std::vector<unsigned char> payload(dataContent.begin(), dataContent.end());
		payload.resize(messageLength);
		unsigned char* dataRaw = payload.data();
		float dataFloat[3] =  {0, 0, 0};
		dataFloat[0] = ((float*)dataRaw)[0];
        dataFloat[1] = ((float*)dataRaw)[1];
        dataFloat[2] = ((float*)dataRaw)[2];
		std::cout << "send: fit: " << dataFloat[0] << " x: " << dataFloat[1] << " y: " << dataFloat[2] << std::endl;
		//@TODO correct size of payload
		finkenOmnetSimInstance->sendData(cb->objectID, targetHandle, now,  payload,  0);
		
	}
	D.writeDataToStack(cb->stackID);
}
/*! custom Lua function to receive data sent via Omnet++
 * reads the buffer of all messages sent in the last simulation step from 
 * FinkenOmnetSim
 */
void FinkenCommLuaFunctions::luaSimExtFinken_receiveData_callback(SScriptCallBack* cb){
	CScriptFunctionData D;
	if (D.readDataFromStack(cb->stackID, inArgs_FINKENRECEIVEDATA, inArgs_FINKENRECEIVEDATA[0], LUA_FINKENREGISTERMAC_COMMAND)){
		std::vector<CScriptFunctionDataItem>* inData = D.getInDataPtr();
		int instanceIndex = inData->at(0).int32Data[0];
		try {
			FinkenOmnetSim* finkenOmnetSimInstance = FinkenOmnetSim::getInstanceById(instanceIndex);
			std::vector<FinkenOmnetSim::oppPacket_t> oppPackets(finkenOmnetSimInstance->removeReceivedData(cb->objectID));
			//number senderID
			//number time 
			//charbuff payload or string and unpackfloats
			std::vector<int> senderIds;
			std::vector<double> timeStamps;
			std::vector<std::string> payloads;
			for (auto oppPacket_it:oppPackets) {
				senderIds.push_back(finkenOmnetSimInstance->resolveMAC2SimHandle(oppPacket_it.sourceAddress));
				timeStamps.push_back(oppPacket_it.timeStamp.dbl());
				payloads.emplace_back(std::string(reinterpret_cast<char*>(oppPacket_it.payload.data()), oppPacket_it.payload.size()));
		const char* dataRaw =std::string(reinterpret_cast<char*>(oppPacket_it.payload.data()), oppPacket_it.payload.size()).c_str(); 
		float dataFloat[3] = {0, 0, 0};
		dataFloat[0] = ((float*)dataRaw)[0];
        dataFloat[1] = ((float*)dataRaw)[1];
        dataFloat[2] = ((float*)dataRaw)[2];
		std::cout << "received: fit: " << dataFloat[0] << " x: " << dataFloat[1] << " y: " << dataFloat[2] << std::endl;
			}
			/*
			senderIds.push_back(10);
			senderIds.push_back(11);
			timeStamps.push_back(0.1);
			timeStamps.push_back(0.2);
			payloads.push_back("test0");
			payloads.push_back("test1");
			*/
			D.pushOutData(CScriptFunctionDataItem(senderIds));
			D.pushOutData(CScriptFunctionDataItem(timeStamps));
			D.pushOutData(CScriptFunctionDataItem(payloads));
		}
		catch (const std::exception& e){
			simSetLastError(LUA_FINKENRECEIVEDATA_COMMAND, e.what());
			D.pushOutData(CScriptFunctionDataItem(false));
		}
	}
	//get data attached to script
	//todo copy data from FinkenOmnetSim with correct structure to D
	//structure should inclode simInt sourceHandle, float[3] Coords
	D.writeDataToStack(cb->stackID);
}

/*! register the MAC mapping function in V-REP
 */
int FinkenCommLuaFunctions::register_FINKENREGISTERMAC(){
	int result = simRegisterScriptCallbackFunction(LUA_FINKENREGISTERMAC_COMMAND,strConCat("number result=",LUA_FINKENREGISTERMAC_COMMAND,"(charbuff macAdress)"),luaSimExtFinken_registerMac_callback);
	return result;
}

/*! register the custom sendData function in V-REP
 */
int FinkenCommLuaFunctions::register_FINKENSENDDATA(){
	int result = simRegisterScriptCallbackFunction(LUA_FINKENSENDDATA_COMMAND,strConCat("number result=",LUA_FINKENSENDDATA_COMMAND,"(number oppInstanceId, number targetHandle, charbuff[102] data, number dataLength)"),luaSimExtFinken_sendData_callback);
	return result;
}
/*! register the custom receiveData function in V-REP
 */
int FinkenCommLuaFunctions::register_FINKENRECEIVEDATA(){
	int result = simRegisterScriptCallbackFunction(LUA_FINKENRECEIVEDATA_COMMAND,strConCat("number_table sender, number_table timeOfArrival, string_table data=",LUA_FINKENRECEIVEDATA_COMMAND,"(number oppInstanceId)"),luaSimExtFinken_receiveData_callback);
	return result;
}
}
