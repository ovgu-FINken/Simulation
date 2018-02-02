# Copyright 2006-2016 Coppelia Robotics GmbH. All rights reserved. 
# marc@coppeliarobotics.com
# www.coppeliarobotics.com
# 
# -------------------------------------------------------------------
# THIS FILE IS DISTRIBUTED "AS IS", WITHOUT ANY EXPRESS OR IMPLIED
# WARRANTY. THE USER WILL USE IT AT HIS/HER OWN RISK. THE ORIGINAL
# AUTHORS AND COPPELIA ROBOTICS GMBH WILL NOT BE LIABLE FOR DATA LOSS,
# DAMAGES, LOSS OF PROFITS OR ANY OTHER KIND OF LOSS WHILE USING OR
# MISUSING THIS SOFTWARE.
# 
# You are free to use/modify/distribute this file for whatever purpose!
# -------------------------------------------------------------------
#
# This file was automatically created for V-REP release V3.3.0 on February 19th 2016
# This file was extended for the v_repExtFINkenCommunication project by lmaeurer

#set the path to the location of your boost library
BOOST_PATH = "C:/Chocolatey/lib/boost.1.60.0.0"
#set the path to the folder containing your v_rep library
win32: VREP_PATH = "C:/Program Files (x86)/V-REP3/V-REP_PRO_EDU"
macx: VREP_PATH = "/Applications/vrep"
#set this path to the folder containing your Omnet++ installation
OMNET_PATH = "C:/cpp/omnetpp-4.6"
#set this path to the folder containing your INET installation
INET_PATH = "C:/Users/Lukas/Documents/Programmieren/ThesisTemp/inet"
#set this path to the folder containing the 802.15.4 simulation for OMNET_PATH
SIM802154_PATH = "../802154OmnetFINken"

QT -= core
QT -= gui

TARGET = v_repExtFINkenCommunication
TEMPLATE = lib

DEFINES -= UNICODE
DEFINES += QT_COMPIL
#load NED files dynamically in omnet
DEFINES += WITH_NETBUILDER
CONFIG += shared
INCLUDEPATH += "./include"
INCLUDEPATH += $$BOOST_PATH
INCLUDEPATH += $$VREP_PATH"/programming/include"
#include for omnet library
INCLUDEPATH += $$OMNET_PATH"/include"
INCLUDEPATH += $$OMNET_PATH"/src"
#include for oment envir(onment) of opp simulation
INCLUDEPATH += $$OMNET_PATH"/include/platdep"
INCLUDEPATH += $$OMNET_PATH"/src/common"
INCLUDEPATH += $$OMNET_PATH"/src/envir"
INCLUDEPATH += $$OMNET_PATH"/src/sim"
#INCLUDEPATH += $$OMNET_PATH"/src/nedxml"
INCLUDEPATH += $$INET_PATH"/src"
INCLUDEPATH += $$INET_PATH"/src/util"
INCLUDEPATH += $$INET_PATH"/src/base"
INCLUDEPATH += $$INET_PATH"/src/battery/models"
INCLUDEPATH += $$INET_PATH"/src/networklayer/common"
INCLUDEPATH += $$INET_PATH"/src/linklayer/contract"
INCLUDEPATH += $$INET_PATH"/src/linklayer/radio"
INCLUDEPATH += $$INET_PATH"/src/linklayer/radio/propagation"
INCLUDEPATH += $$INET_PATH"/src/mobility/common"
INCLUDEPATH += $$INET_PATH"/src/mobility/contract"
INCLUDEPATH += $$INET_PATH"/src/networklayer/contract"
# @TODO substitude with correctly embedding INET
INCLUDEPATH += $$INET_PATH"/src/world/radio/"
INCLUDEPATH += $$INET_PATH"/src/world/obstacles/"
INCLUDEPATH += $$SIM802154_PATH"/src/util"
INCLUDEPATH += $$SIM802154_PATH"/src/Modules"
#INET library
LIBS += -L$$INET_PATH"/src" -llibinet
#omnet  helper functions for envir
LIBS += -L$$OMNET_PATH"/bin" -lliboppcommond
#omnet functions for dynamically loading ned files 
LIBS += -L$$OMNET_PATH"/bin" -lliboppnedxmld
#omnet simulation library
LIBS += -L$$OMNET_PATH"/bin" -lliboppsimd

*-msvc* {
	QMAKE_CXXFLAGS += -O2
	QMAKE_CXXFLAGS += -W3
}
*-g++* {
	QMAKE_CXXFLAGS += -O3
	QMAKE_CXXFLAGS += -Wall
	QMAKE_CXXFLAGS += -Wno-unused-parameter
	QMAKE_CXXFLAGS += -Wno-strict-aliasing
	QMAKE_CXXFLAGS += -Wno-empty-body
	QMAKE_CXXFLAGS += -Wno-write-strings

	QMAKE_CXXFLAGS += -std=c++11

	QMAKE_CXXFLAGS += -Wno-unused-but-set-variable
	QMAKE_CXXFLAGS += -Wno-unused-local-typedefs
	QMAKE_CXXFLAGS += -Wno-narrowing

	QMAKE_CFLAGS += -O3
	QMAKE_CFLAGS += -Wall
	QMAKE_CFLAGS += -Wno-strict-aliasing
	QMAKE_CFLAGS += -Wno-unused-parameter
	QMAKE_CFLAGS += -Wno-unused-but-set-variable
	QMAKE_CFLAGS += -Wno-unused-local-typedefs
}

target.path = $$VREP_PATH

win32 {
	INCLUDEPATH += $$OMNET_PATH"/tools/win32/mingw32/include"
	LIBS += -L$$OMNET_PATH"/tools/win32/mingw32/bin" -llibxml2-2 
	DEFINES += WIN_VREP
}

macx {
    DEFINES += MAC_VREP
}

unix:!macx {
    DEFINES += LIN_VREP
}


INSTALLS += target

HEADERS += \
    $$files(./include/*.h)\
	$$files($$SIM802154_PATH/src/util/*.h) \
	$$files($$SIM802154_PATH/src/Modules/*.h) \
    $$VREP_PATH/programming/include/scriptFunctionData.h \
    $$VREP_PATH/programming/include/scriptFunctionDataItem.h \
    $$VREP_PATH/programming/include/v_repLib.h \
  	$$INET_PATH/src/networklayer/contract/IPSocket.h \
	$$files($$OMNET_PATH/src/envir/*.h) 




SIM802154_SOURCES_UTIL = $$files($$SIM802154_PATH/src/util/*.cc) 
win32:SIM802154_SOURCES_UTIL ~= s|\\\\|/|g
for(SIM802154_SOURCE, SIM802154_SOURCES_UTIL ):!exists($$SIM802154_SOURCE/*):contains($$SIM802154_SOURCE, ".cc"):SOURCES += $$SIM802154_SOURCE

SIM802154_SOURCES_MODULES = $$files($$SIM802154_PATH/src/Modules/*.cc) 
win32:SIM802154_SOURCES_MODULES ~= s|\\\\|/|g
for(SIM802154_SOURCE, SIM802154_SOURCES_MODULES):!exists($$SIM802154_SOURCE/*):contains($$SIM802154_SOURCE, ".cc"):SOURCES += $$SIM802154_SOURCE

PROJECT_SOURCES = $$files(./src/*.cpp) 
win32:PROJECT_SOURCES ~= s|\\\\|/|g
for(PROJECT_SOURCE, PROJECT_SOURCES):!exists($$PROJECT_SOURCE/*):contains($$PROJECT_SOURCE, ".cpp"):SOURCES += $$PROJECT_SOURCE


SOURCES += \
	$$PROJECT_SOURCES \
    $$VREP_PATH/programming/common/scriptFunctionData.cpp \
    $$VREP_PATH/programming/common/scriptFunctionDataItem.cpp \
    $$VREP_PATH/programming/common/v_repLib.cpp \
  	$$INET_PATH/src/networklayer/contract/IPSocket.cc \
	$$SIM802154_SOURCES_MODULES \
	$$SIM802154_SOURCES_UTIL \
	$$OMNET_PATH/src/envir/sectionbasedconfig.cc \
	$$OMNET_PATH/src/envir/inifilereader.cc \
	$$OMNET_PATH/src/envir/scenario.cc \
	$$OMNET_PATH/src/envir/cxmldoccache.cc \
	$$OMNET_PATH/src/envir/valueiterator.cc 

SOURCES -= \
	$$OMNET_PATH/src/nedxml/saxparser_expat.cc \
	$$OMNET_PATH/src/nedxml/saxparser_none.cc 


