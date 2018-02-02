#
# OMNeT++/OMNEST Makefile for IEEE802154INET-Standalone
#
# This file was generated with the command:
#  opp_makemake -f --deep -IC:\Users\Lukas\Documents\Programmieren\Masterthesis\vrep_plugin\v_repExtFINkenCommunication\include -IC:\Chocolatey\lib\boost.1.60.0.0 -IC:\Program Files \(x86\)\V-REP3\V-REP_PRO_EDU\programming\include -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src/linklayer/ieee80211/radio -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src/networklayer/routing/aodv -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src/networklayer/common -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src/networklayer/icmpv6 -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src/world/obstacles -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src/networklayer/contract -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src/networklayer/xmipv6 -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src/networklayer/autorouting/ipv4 -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src/util -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src/transport/contract -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src/linklayer/common -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src/status -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src/linklayer/radio/propagation -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src/linklayer/ieee80211/radio/errormodel -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src/linklayer/radio -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src/util/headerserializers/tcp -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src/networklayer/ipv4 -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src/mobility/contract -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src/util/headerserializers/ipv4 -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src/base -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src/util/headerserializers -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src/world/radio -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src/linklayer/ieee80211/mac -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src/networklayer/ipv6 -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src/transport/sctp -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src/util/headerserializers/udp -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src/networklayer/ipv6tunneling -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src/util/headerserializers/ipv6 -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src/battery/models -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src/applications/pingapp -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src/linklayer/contract -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src/util/headerserializers/sctp -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src/networklayer/arp -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src/transport/tcp_common -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src/transport/udp -IC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/src/mobility/common -LC:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet/out/$$\(CONFIGNAME\)/src -linet -DINET_IMPORT -KINET_PROJ=C:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet
#

# Name of target to be created (-o option)
TARGET = IEEE802154INET-Standalone$(EXE_SUFFIX)

# User interface (uncomment one) (-u option)
USERIF_LIBS = $(ALL_ENV_LIBS) # that is, $(TKENV_LIBS) $(CMDENV_LIBS)
#USERIF_LIBS = $(CMDENV_LIBS)
#USERIF_LIBS = $(TKENV_LIBS)

# C++ include paths (with -I)
INCLUDE_PATH = \
    -IC:/Users/Lukas/Documents/Programmieren/Masterthesis/vrep_plugin/v_repExtFINkenCommunication/include \
    -IC:/Chocolatey/lib/boost.1.60.0.0 \
    -I"C:/Program Files (x86)/V-REP3/V-REP_PRO_EDU/programming/include" \
    -I$(INET_PROJ)/src/linklayer/ieee80211/radio \
    -I$(INET_PROJ)/src/networklayer/routing/aodv \
    -I$(INET_PROJ)/src/networklayer/common \
    -I$(INET_PROJ)/src \
    -I$(INET_PROJ)/src/networklayer/icmpv6 \
    -I$(INET_PROJ)/src/world/obstacles \
    -I$(INET_PROJ)/src/networklayer/contract \
    -I$(INET_PROJ)/src/networklayer/xmipv6 \
    -I$(INET_PROJ)/src/networklayer/autorouting/ipv4 \
    -I$(INET_PROJ)/src/util \
    -I$(INET_PROJ)/src/transport/contract \
    -I$(INET_PROJ)/src/linklayer/common \
    -I$(INET_PROJ)/src/status \
    -I$(INET_PROJ)/src/linklayer/radio/propagation \
    -I$(INET_PROJ)/src/linklayer/ieee80211/radio/errormodel \
    -I$(INET_PROJ)/src/linklayer/radio \
    -I$(INET_PROJ)/src/util/headerserializers/tcp \
    -I$(INET_PROJ)/src/networklayer/ipv4 \
    -I$(INET_PROJ)/src/mobility/contract \
    -I$(INET_PROJ)/src/util/headerserializers/ipv4 \
    -I$(INET_PROJ)/src/base \
    -I$(INET_PROJ)/src/util/headerserializers \
    -I$(INET_PROJ)/src/world/radio \
    -I$(INET_PROJ)/src/linklayer/ieee80211/mac \
    -I$(INET_PROJ)/src/networklayer/ipv6 \
    -I$(INET_PROJ)/src/transport/sctp \
    -I$(INET_PROJ)/src/util/headerserializers/udp \
    -I$(INET_PROJ)/src/networklayer/ipv6tunneling \
    -I$(INET_PROJ)/src/util/headerserializers/ipv6 \
    -I$(INET_PROJ)/src/battery/models \
    -I$(INET_PROJ)/src/applications/pingapp \
    -I$(INET_PROJ)/src/linklayer/contract \
    -I$(INET_PROJ)/src/util/headerserializers/sctp \
    -I$(INET_PROJ)/src/networklayer/arp \
    -I$(INET_PROJ)/src/transport/tcp_common \
    -I$(INET_PROJ)/src/transport/udp \
    -I$(INET_PROJ)/src/mobility/common \
    -I. \
    -IModules \
    -INED \
    -Iutil

# Additional object and library files to link with
EXTRA_OBJS =

# Additional libraries (-L, -l options)
LIBS = -L$(INET_PROJ)/out/$(CONFIGNAME)/src  -linet
LIBS += -Wl,-rpath,`abspath $(INET_PROJ)/out/$(CONFIGNAME)/src`

# Output directory
PROJECT_OUTPUT_DIR = ../out
PROJECTRELATIVE_PATH = src
O = $(PROJECT_OUTPUT_DIR)/$(CONFIGNAME)/$(PROJECTRELATIVE_PATH)

# Object files for local .cc and .msg files
OBJS = \
    $O/Modules/FinkenTrafGen.o \
    $O/Modules/IEEE802154Mac.o \
    $O/Modules/IEEE802154Phy.o \
    $O/Modules/IEEE802154Radio.o \
    $O/Modules/IEEE802154TrafficGenerator.o \
    $O/Modules/IEEE802154TrafficSink.o \
    $O/Modules/llc.o \
    $O/Modules/msgBuffer.o \
    $O/Modules/sscs.o \
    $O/Modules/VrepMobility.o \
    $O/util/MACAddressExt.o \
    $O/util/MacPIB.o \
    $O/util/PhyPIB.o \
    $O/util/mcpsData_m.o \
    $O/util/MPDU_m.o \
    $O/util/PPDU_m.o \
    $O/util/vrepCoords_m.o \
    $O/util/vrepPacket_m.o

# Message files
MSGFILES = \
    util/mcpsData.msg \
    util/MPDU.msg \
    util/PPDU.msg \
    util/vrepCoords.msg \
    util/vrepPacket.msg

# Other makefile variables (-K)
INET_PROJ=C:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet

#------------------------------------------------------------------------------

# Pull in OMNeT++ configuration (Makefile.inc or configuser.vc)

ifneq ("$(OMNETPP_CONFIGFILE)","")
CONFIGFILE = $(OMNETPP_CONFIGFILE)
else
ifneq ("$(OMNETPP_ROOT)","")
CONFIGFILE = $(OMNETPP_ROOT)/Makefile.inc
else
CONFIGFILE = $(shell opp_configfilepath)
endif
endif

ifeq ("$(wildcard $(CONFIGFILE))","")
$(error Config file '$(CONFIGFILE)' does not exist -- add the OMNeT++ bin directory to the path so that opp_configfilepath can be found, or set the OMNETPP_CONFIGFILE variable to point to Makefile.inc)
endif

include $(CONFIGFILE)

# Simulation kernel and user interface libraries
OMNETPP_LIB_SUBDIR = $(OMNETPP_LIB_DIR)/$(TOOLCHAIN_NAME)
OMNETPP_LIBS = -L"$(OMNETPP_LIB_SUBDIR)" -L"$(OMNETPP_LIB_DIR)" -loppmain$D $(USERIF_LIBS) $(KERNEL_LIBS) $(SYS_LIBS)

COPTS = $(CFLAGS) -DINET_IMPORT $(INCLUDE_PATH) -I$(OMNETPP_INCL_DIR)
MSGCOPTS = $(INCLUDE_PATH)

# we want to recompile everything if COPTS changes,
# so we store COPTS into $COPTS_FILE and have object
# files depend on it (except when "make depend" was called)
COPTS_FILE = $O/.last-copts
ifneq ($(MAKECMDGOALS),depend)
ifneq ("$(COPTS)","$(shell cat $(COPTS_FILE) 2>/dev/null || echo '')")
$(shell $(MKPATH) "$O" && echo "$(COPTS)" >$(COPTS_FILE))
endif
endif

#------------------------------------------------------------------------------
# User-supplied makefile fragment(s)
# >>>
# <<<
#------------------------------------------------------------------------------

# Main target
all: $O/$(TARGET)
	$(Q)$(LN) $O/$(TARGET) .

$O/$(TARGET): $(OBJS)  $(wildcard $(EXTRA_OBJS)) Makefile
	@$(MKPATH) $O
	@echo Creating executable: $@
	$(Q)$(CXX) $(LDFLAGS) -o $O/$(TARGET)  $(OBJS) $(EXTRA_OBJS) $(AS_NEEDED_OFF) $(WHOLE_ARCHIVE_ON) $(LIBS) $(WHOLE_ARCHIVE_OFF) $(OMNETPP_LIBS)

.PHONY: all clean cleanall depend msgheaders

.SUFFIXES: .cc

$O/%.o: %.cc $(COPTS_FILE)
	@$(MKPATH) $(dir $@)
	$(qecho) "$<"
	$(Q)$(CXX) -c $(CXXFLAGS) $(COPTS) -o $@ $<

%_m.cc %_m.h: %.msg
	$(qecho) MSGC: $<
	$(Q)$(MSGC) -s _m.cc $(MSGCOPTS) $?

msgheaders: $(MSGFILES:.msg=_m.h)

clean:
	$(qecho) Cleaning...
	$(Q)-rm -rf $O
	$(Q)-rm -f IEEE802154INET-Standalone IEEE802154INET-Standalone.exe libIEEE802154INET-Standalone.so libIEEE802154INET-Standalone.a libIEEE802154INET-Standalone.dll libIEEE802154INET-Standalone.dylib
	$(Q)-rm -f ./*_m.cc ./*_m.h
	$(Q)-rm -f Modules/*_m.cc Modules/*_m.h
	$(Q)-rm -f NED/*_m.cc NED/*_m.h
	$(Q)-rm -f util/*_m.cc util/*_m.h

cleanall: clean
	$(Q)-rm -rf $(PROJECT_OUTPUT_DIR)

depend:
	$(qecho) Creating dependencies...
	$(Q)$(MAKEDEPEND) $(INCLUDE_PATH) -f Makefile -P\$$O/ -- $(MSG_CC_FILES)  ./*.cc Modules/*.cc NED/*.cc util/*.cc

# DO NOT DELETE THIS LINE -- make depend depends on it.
$O/Modules/FinkenTrafGen.o: Modules/FinkenTrafGen.cc \
	Modules/FinkenTrafGen.h \
	util/IEEE802154Enum.h \
	util/IEEE802154Fields.h \
	util/MACAddressExt.h \
	util/MPDU_m.h \
	util/mcpsData_m.h \
	util/vrep802154conf.h \
	util/vrepPacket_m.h \
	$(INET_PROJ)/src/base/Compat.h \
	$(INET_PROJ)/src/base/ILifecycle.h \
	$(INET_PROJ)/src/base/INETDefs.h \
	$(INET_PROJ)/src/base/LifecycleOperation.h \
	$(INET_PROJ)/src/base/NodeOperations.h
$O/Modules/IEEE802154Mac.o: Modules/IEEE802154Mac.cc \
	Modules/IEEE802154Mac.h \
	util/IEEE802154Consts.h \
	util/IEEE802154Enum.h \
	util/IEEE802154Fields.h \
	util/MACAddressExt.h \
	util/MPDU_m.h \
	util/MacPIB.h \
	util/PPDU_m.h \
	util/mcpsData_m.h \
	$(INET_PROJ)/src/base/Compat.h \
	$(INET_PROJ)/src/base/INETDefs.h \
	$(INET_PROJ)/src/base/INotifiable.h \
	$(INET_PROJ)/src/base/ModuleAccess.h \
	$(INET_PROJ)/src/base/NotificationBoard.h \
	$(INET_PROJ)/src/base/NotifierConsts.h \
	$(INET_PROJ)/src/linklayer/contract/PhyControlInfo_m.h \
	$(INET_PROJ)/src/linklayer/contract/RadioState.h
$O/Modules/IEEE802154Phy.o: Modules/IEEE802154Phy.cc \
	Modules/IEEE802154Phy.h \
	util/IEEE802154Consts.h \
	util/IEEE802154Enum.h \
	util/IEEE802154Fields.h \
	util/MACAddressExt.h \
	util/MPDU_m.h \
	util/PPDU_m.h \
	util/PhyPIB.h \
	$(INET_PROJ)/src/base/Compat.h \
	$(INET_PROJ)/src/base/INETDefs.h
$O/Modules/IEEE802154Radio.o: Modules/IEEE802154Radio.cc \
	Modules/IEEE802154Radio.h \
	util/IEEE802154Consts.h \
	util/IEEE802154Enum.h \
	util/IEEE802154Fields.h \
	util/MACAddressExt.h \
	util/PPDU_m.h \
	util/PhyPIB.h \
	$(INET_PROJ)/src/base/BasicModule.h \
	$(INET_PROJ)/src/base/Compat.h \
	$(INET_PROJ)/src/base/Coord.h \
	$(INET_PROJ)/src/base/INETDefs.h \
	$(INET_PROJ)/src/base/INotifiable.h \
	$(INET_PROJ)/src/base/ModuleAccess.h \
	$(INET_PROJ)/src/base/NotificationBoard.h \
	$(INET_PROJ)/src/base/NotifierConsts.h \
	$(INET_PROJ)/src/battery/models/BasicBattery.h \
	$(INET_PROJ)/src/linklayer/contract/PhyControlInfo_m.h \
	$(INET_PROJ)/src/linklayer/contract/RadioState.h \
	$(INET_PROJ)/src/linklayer/radio/AirFrame_m.h \
	$(INET_PROJ)/src/linklayer/radio/IModulation.h \
	$(INET_PROJ)/src/linklayer/radio/INoiseGenerator.h \
	$(INET_PROJ)/src/linklayer/radio/IRadioModel.h \
	$(INET_PROJ)/src/linklayer/radio/Modulation.h \
	$(INET_PROJ)/src/linklayer/radio/ModulationType.h \
	$(INET_PROJ)/src/linklayer/radio/SnrList.h \
	$(INET_PROJ)/src/linklayer/radio/propagation/IReceptionModel.h \
	$(INET_PROJ)/src/util/FWMath.h \
	$(INET_PROJ)/src/world/annotations/AnnotationManager.h \
	$(INET_PROJ)/src/world/obstacles/Obstacle.h \
	$(INET_PROJ)/src/world/obstacles/ObstacleControl.h \
	$(INET_PROJ)/src/world/radio/ChannelAccess.h \
	$(INET_PROJ)/src/world/radio/IChannelControl.h
$O/Modules/IEEE802154TrafficGenerator.o: Modules/IEEE802154TrafficGenerator.cc \
	Modules/IEEE802154TrafficGenerator.h \
	util/IEEE802154Enum.h \
	util/IEEE802154Fields.h \
	util/MACAddressExt.h \
	util/MPDU_m.h \
	util/mcpsData_m.h \
	$(INET_PROJ)/src/base/Compat.h \
	$(INET_PROJ)/src/base/INETDefs.h
$O/Modules/IEEE802154TrafficSink.o: Modules/IEEE802154TrafficSink.cc \
	Modules/IEEE802154TrafficSink.h \
	util/IEEE802154Enum.h \
	util/IEEE802154Fields.h \
	util/MACAddressExt.h \
	util/MPDU_m.h \
	util/mcpsData_m.h \
	$(INET_PROJ)/src/base/Compat.h \
	$(INET_PROJ)/src/base/INETDefs.h
$O/Modules/VrepMobility.o: Modules/VrepMobility.cc \
	Modules/VrepMobility.h \
	util/vrepCoords_m.h \
	$(INET_PROJ)/src/base/Compat.h \
	$(INET_PROJ)/src/base/Coord.h \
	$(INET_PROJ)/src/base/INETDefs.h \
	$(INET_PROJ)/src/base/ModuleAccess.h \
	$(INET_PROJ)/src/mobility/common/MobilityBase.h \
	$(INET_PROJ)/src/mobility/common/MovingMobilityBase.h \
	$(INET_PROJ)/src/mobility/contract/IMobility.h \
	$(INET_PROJ)/src/util/FWMath.h
$O/Modules/llc.o: Modules/llc.cc \
	Modules/llc.h \
	util/IEEE802154Enum.h \
	util/IEEE802154Fields.h \
	util/MACAddressExt.h \
	util/MPDU_m.h \
	util/mcpsData_m.h \
	$(INET_PROJ)/src/base/Compat.h \
	$(INET_PROJ)/src/base/INETDefs.h \
	$(INET_PROJ)/src/networklayer/contract/IPProtocolId_m.h \
	$(INET_PROJ)/src/networklayer/contract/IPSocket.h \
	$(INET_PROJ)/src/networklayer/contract/IPv4Address.h \
	$(INET_PROJ)/src/networklayer/contract/IPv6Address.h \
	$(INET_PROJ)/src/networklayer/contract/IPv6ControlInfo.h \
	$(INET_PROJ)/src/networklayer/contract/IPv6ControlInfo_m.h \
	$(INET_PROJ)/src/networklayer/contract/IPvXAddress.h
$O/Modules/msgBuffer.o: Modules/msgBuffer.cc \
	Modules/msgBuffer.h \
	util/IEEE802154Enum.h \
	util/MACAddressExt.h \
	util/mcpsData_m.h \
	$(INET_PROJ)/src/base/Compat.h \
	$(INET_PROJ)/src/base/INETDefs.h
$O/Modules/sscs.o: Modules/sscs.cc \
	Modules/sscs.h \
	util/IEEE802154Enum.h \
	util/MACAddressExt.h \
	util/mcpsData_m.h \
	$(INET_PROJ)/src/base/Compat.h \
	$(INET_PROJ)/src/base/INETDefs.h
$O/util/MACAddressExt.o: util/MACAddressExt.cc \
	util/MACAddressExt.h \
	$(INET_PROJ)/src/base/Compat.h \
	$(INET_PROJ)/src/base/INETDefs.h \
	$(INET_PROJ)/src/networklayer/common/InterfaceToken.h
$O/util/MPDU_m.o: util/MPDU_m.cc \
	util/IEEE802154Enum.h \
	util/IEEE802154Fields.h \
	util/MACAddressExt.h \
	util/MPDU_m.h \
	$(INET_PROJ)/src/base/Compat.h \
	$(INET_PROJ)/src/base/INETDefs.h
$O/util/MacPIB.o: util/MacPIB.cc \
	util/MACAddressExt.h \
	util/MacPIB.h \
	$(INET_PROJ)/src/base/Compat.h \
	$(INET_PROJ)/src/base/INETDefs.h
$O/util/PPDU_m.o: util/PPDU_m.cc \
	util/IEEE802154Enum.h \
	util/IEEE802154Fields.h \
	util/MACAddressExt.h \
	util/PPDU_m.h \
	$(INET_PROJ)/src/base/Compat.h \
	$(INET_PROJ)/src/base/INETDefs.h
$O/util/PhyPIB.o: util/PhyPIB.cc \
	util/IEEE802154Consts.h \
	util/IEEE802154Enum.h \
	util/PhyPIB.h
$O/util/mcpsData_m.o: util/mcpsData_m.cc \
	util/IEEE802154Enum.h \
	util/MACAddressExt.h \
	util/mcpsData_m.h \
	$(INET_PROJ)/src/base/Compat.h \
	$(INET_PROJ)/src/base/INETDefs.h
$O/util/vrepCoords_m.o: util/vrepCoords_m.cc \
	util/vrepCoords_m.h \
	$(INET_PROJ)/src/base/Compat.h \
	$(INET_PROJ)/src/base/Coord.h \
	$(INET_PROJ)/src/base/INETDefs.h \
	$(INET_PROJ)/src/util/FWMath.h
$O/util/vrepPacket_m.o: util/vrepPacket_m.cc \
	util/IEEE802154Enum.h \
	util/MACAddressExt.h \
	util/mcpsData_m.h \
	util/vrep802154conf.h \
	util/vrepPacket_m.h \
	$(INET_PROJ)/src/base/Compat.h \
	$(INET_PROJ)/src/base/INETDefs.h

