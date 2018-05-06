
OS = $(shell uname -s)
ifeq ($(OS), Linux)
	CFLAGS += -D__linux
	EXT = so
else
	CFLAGS += -D__APPLE__
	EXT = dylib
endif

VREP_PATH := ~/software/vrep
VREP_INCLUDE	:= ${VREP_PATH}/programming/include
VREP_SRC	:= ${VREP_PATH}/programming/common

CXXFLAGS=-I ${VREP_INCLUDE} -I . -Wall -fPIC -static -std=c++11

NAME:=FinkenCore
LIBNAME:=libv_repExt${NAME}.so
OBJECTS:=finkenCoreExt finkenPID  scriptFunctionData scriptFunctionDataItem v_repLib
OBJECTS:=$(addsuffix .o, ${OBJECTS})
LDFLAGS:=-shared
LDPATH:=
LIBS:=pthread dl 
LIBS:=$(addprefix -l, ${LIBS})

DIRS:=lib

all: lib/${LIBNAME}

%.o: ${VREP_SRC}/%.cpp
	${CXX} -c ${CXXFLAGS} $< -o $@ 

%.o: %.cpp
	${CXX} -c ${CXXFLAGS} $< -o $@ 

${DIRS}: %:
	mkdir -p $@

lib/${LIBNAME}: ${OBJECTS} | lib
	${CXX} $^ -o $@ ${LDFLAGS} ${LDPATHS} ${LIBS}
