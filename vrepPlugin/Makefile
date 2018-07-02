VREP_PATH       :=${HOME}/software/vrep
PAPARAZZI_HOME  ?=${HOME}/swarmlab/paparazzi

CXXFLAGS        += -Wall -O0 -g
PLUGIN_SOURCES  := attitudesensor.cpp finken.cpp finkenplugin.cpp log.cpp positionsensor.cpp sensor.cpp sonar.cpp vrepplugin.cpp heightsensor.cpp rotor.cpp skeleton.cpp v_repLib.cpp

TARGET          := Paparazzi
INCLUDES        += . /usr/include/eigen3
SRC             := ./src
BUILD           := ./build
LIB             := ./lib

include plugin.mk
