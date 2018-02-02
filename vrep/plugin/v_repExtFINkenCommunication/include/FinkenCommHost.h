#pragma once

#include <string>
#include <vector>
#include <v_repLib.h>

namespace FinkenComm {
class FinkenCommHost {
	struct message {
		std::string addr;
		const char* payload;
		unsigned int flags;
	};

	public:
		FinkenCommHost();
		FinkenCommHost(simInt newHandle, std::string newMacAddr);
		~FinkenCommHost();
	private:
		simInt handle;
		std::string macAddr;
		void send(std::string targetAddr, const char* payload, unsigned int flags);
		void receive(std::string sourceAddr, const char* payload, unsigned int flags);
		std::vector<message> rcvdMsgBuffer; 

};

}
