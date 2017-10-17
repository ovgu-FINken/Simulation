VREP_PATH       :=${HOME}/software/vrep
PAPARAZZI_HOME  :=${HOME}/swarmlab/paparazzi

CXXFLAGS        += -O0
PLUGIN_SOURCES  := attitudesensor.cpp finken.cpp finkenplugin.cpp log.cpp positionsensor.cpp sensor.cpp simtestdummy.cpp sonar.cpp vrepplugin.cpp finkenPID.cpp heightsensor.cpp rotor.cpp skeleton.cpp v_repLib.cpp

TARGET          := Paparazzi
INCLUDES        += . /usr/include/eigen3
SRC             := ./src
BUILD           := ./build
LIB             := ./lib

include plugin.mk
