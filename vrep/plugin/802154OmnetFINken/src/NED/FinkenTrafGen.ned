// Copyright (C) 2016 Lukas Maeurer
// Copyright (C) 2004 Andras Varga
// Copyright (C) 2000 Institut fuer Telematik, Universitaet Karlsruhe
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program; if not, see <http://www.gnu.org/licenses/>.
//


package ieee802154.src.NED;
//
// Sends IP or IPv6 datagrams with the given content to the given address.
// The datagram is triggered by a VREP-plugin and the received data is fed back
// to the VREP-plugin.
// If the destAddresses parameter contains more than one address, one
// of them is randomly selected for each packet. An address may be given in the
// dotted decimal notation (or, for IPv6, in the usual notation with colons),
// or with the module name. (The IPvXAddressResolver class is used to resolve
// the address.) To disable the model, set destAddresses to "".
//
// The peer can be another ~FinkenTrafGen .
//
simple FinkenTrafGen like IIeee802154TrafficModules
{
    parameters:
    	//deprecated begin
        double startTime @unit("s") = default(1s); // time of sending the first packet
        double stopTime @unit("s") = default(-1s);  // time of finishing sending, negative values mean forever
        volatile double sendInterval @unit("s") = default(10ms); // may be a random value, e.g. exponential(1)
        int numPackets = default(-1); // max number of packets to generate, -1 means forever
        //deprecated end
        
        bool trafficDebug = default(false);         // debug output switch for the IEEE 802.15.4 Traffic Generator
        volatile int packetLength @unit("B"); // packet length in bytes
        string destAddresses = default(""); // list of destination addresses, separated by spaces
        int oppInstace = default(0); // max number of packets to generate, -1 means forever
        @display("i=block/source");
        @signal[sentPk](type=cPacket);
        @signal[rcvdPk](type=cPacket);
        @statistic[rcvdPk](title="packets received"; source=rcvdPk; record=count,"sum(packetBytes)","vector(packetBytes)"; interpolationmode=none);
        @statistic[sentPk](title="packets sent"; source=sentPk; record=count,"sum(packetBytes)","vector(packetBytes)"; interpolationmode=none);
        @statistic[endToEndDelay](title="end-to-end delay"; source="messageAge(rcvdPk)"; unit=s; record=histogram,vector; interpolationmode=none);
    	@class(FinkenTrafGen);
    gates:
        input trafficIn; 
        output trafficOut;
}

