CFLAGS = -I ~/Software/vrep/programming/include -Wall -fPIC -static -std=c++11

OS = $(shell uname -s)
ifeq ($(OS), Linux)
	CFLAGS += -D__linux
	EXT = so
else
	CFLAGS += -D__APPLE__
	EXT = dylib
endif

VREP_PATH := ~/Software/vrep
VREP_INCLUDE	:= ${VREP_PATH}/programming/include
VREP_SRC	:= ${VREP_PATH}/programming/common

all:
	@rm -f lib/*.$(EXT)
	@rm -f *.o
	g++ $(CFLAGS) -c finkenCoreExt.cpp -o finkenCoreExt.o
	g++ $(CFLAGS) -c ${VREP_SRC}/scriptFunctionData.cpp -o scriptFunctionData.o
	g++ $(CFLAGS) -c ${VREP_SRC}/scriptFunctionDataItem.cpp -o scriptFunctionDataItem.o
	g++ $(CFLAGS) -c ${VREP_SRC}/v_repLib.cpp -o v_repLib.o
	@mkdir -p lib
	g++ scriptFunctionData.o scriptFunctionDataItem.o finkenCoreExt.o v_repLib.o -o lib/libv_repExtFinkenCore.$(EXT) -lpthread -ldl -shared
