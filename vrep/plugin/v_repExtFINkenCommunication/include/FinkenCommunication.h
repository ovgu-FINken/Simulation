#pragma once

#include <VREPPlugin.h>
#include <v_repLib.h>
#include <luaFunctionData.h>
#include <vector>

#include "FinkenOmnetSim.h"
#include "FinkenTrafGen.h"
#include "FinkenCommHost.h"

namespace FinkenComm {

class FinkenCommunication: public VREPPlugin
{
    public:
        FinkenCommunication(){}
        FinkenCommunication& operator=(const FinkenCommunication&) = delete;
        FinkenCommunication(const FinkenCommunication&) = delete;
        virtual ~FinkenCommunication(){}
        virtual unsigned char version() const;
//		void luaSimExtFinken_sendData_callback(SLuaCallBack* p);
//		void luaSimExtFinken_receiveData_callback(SLuaCallBack* p);
        virtual bool load();
        virtual bool unload();
        virtual const std::string name() const;
		void* simStart(int *auxiliaryData, void *customData, int *replyData);
        void* action(int* auxiliaryData,void* customData,int* replyData);
		void* simEnd(int *auxiliaryData, void *customData, int *replyData);
	private:
		FinkenOmnetSim *oppSimulation;
		std::vector<std::unique_ptr<FinkenCommHost>> finkenCommHosts;	
};
}
