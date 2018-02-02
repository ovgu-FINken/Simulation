#pragma once

#include "FinkenCommFunctions.h"
#include <scriptFunctionData.h>
namespace FinkenComm {
class FinkenCommLuaFunctions{
	public:
		FinkenCommLuaFunctions();
		~FinkenCommLuaFunctions();
		static int register_FINKENREGISTERMAC();
		static int register_FINKENSENDDATA();
		static int register_FINKENRECEIVEDATA();
	private:
		static void luaSimExtFinken_registerMac_callback(SScriptCallBack* cb);
		static void luaSimExtFinken_sendData_callback(SScriptCallBack* cb);
		static void luaSimExtFinken_receiveData_callback(SScriptCallBack* cb);
		enum struct messageTypes: int {HEIGHT = 0, DISTANCES = 1, COLOR = 2};
};
}
