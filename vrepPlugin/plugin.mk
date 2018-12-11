ifeq (${VREP_PATH},)
	$(error "Please set the VREP_PATH")
endif

PLUGIN_INCLUDE := $(abspath $(dir $(lastword ${MAKEFILE_LIST}))/../include)
PLUGIN_SRC     := $(abspath $(dir $(lastword ${MAKEFILE_LIST}))/../src)
PLUGIN_BUILD   := $(abspath $(dir $(lastword ${MAKEFILE_LIST}))/../build)
VREP_INCLUDE  := ${VREP_PATH}/programming/include
VREP_SRC      := ${VREP_PATH}/programming/common
EIGEN_INCLUDE := ${VREP_PATH}/programming/include/Eigen
PAPARAZZI_INCLUDE := ${PAPARAZZI_HOME}/sw/simulator/nps

VREP_SOURCES  := v_repLib.cpp scriptFunctionData.cpp scriptFunctionDataItem.cpp
PLUGIN_SOURCES ?= skeleton.cpp vrepplugin.cpp log.cpp attitudesensor.cpp finken.cpp heightsensor.cpp log.cpp positionsensor.cpp sensor.cpp skeleton.cpp sonar.cpp rotor.cpp finkenPID.cpp server.cpp

VREP_OBJS     := $(addsuffix .o, $(addprefix ${PLUGIN_BUILD}/, $(basename ${VREP_SOURCES})))
PLUGIN_OBJS   := $(addsuffix .o, $(addprefix ${PLUGIN_BUILD}/, $(basename ${PLUGIN_SOURCES})))
OBJECTS       := $(addsuffix .o, $(addprefix ${BUILD}/, $(basename ${SOURCES})))

CXXFLAGS      += -std=gnu++11 -fPIC
LDFLAGS       += -shared
LIBS          := $(addprefix -l, ${LIBS} dl boost_filesystem boost_serialization boost_system boost_thread pthread)
LDPATHS       := $(addprefix -L, ${LDPATHS})
SOURCES       := $(addprefix ${SRC}/,${SOURCES})
INCLUDES      := $(addprefix -I, ${INCLUDES} ${PLUGIN_INCLUDE} ${VREP_INCLUDE} ${EIGEN_INCLUDE} ${PAPARAZZI_INCLUDE})
SYMBOLS       := $(addprefix -D, ${SYMBOLS})
TARGET        := ${LIB}/libv_repExt${TARGET}.so
DEPS          := $(wildcard ${BUILD}/*.o.d) $(wildcard ${PLUGIN_BUILD}/*.o.d)

vpath %.cpp ${VREP_SRC}:${PLUGIN_SRC}:${SRC}
vpath %.o ${PLUGIN_BUILD}:${BUILD}

.PHONY: all install clean doc

all: ${TARGET}

${PLUGIN_BUILD} ${BUILD} ${LIB}: %:
	@mkdir $@

${TARGET}: ${OBJECTS} ${PLUGIN_OBJS} ${VREP_OBJS} ${CUSTOM_OBJS} | ${LIB}
	@echo "Linking $@ from [$^]"
	@${CXX} -o $@ ${LDFLAGS} $^ ${LDPATHS} ${LIBS}

${OBJECTS}: ${BUILD}/%.o: %.cpp | ${BUILD}
	@echo "Compiling $@ from $<"
	@${CXX} -c -MM -MT $@ ${CXXFLAGS} ${SYMBOLS} -o $@.d $< ${INCLUDES}
	@${CXX} -c ${CXXFLAGS} ${SYMBOLS} -o $@ $< ${INCLUDES}

${PLUGIN_BUILD}/%.o: %.cpp | ${PLUGIN_BUILD}
	@echo "Compiling $@ from $<"
	@${CXX} -c -MM -MT $@ ${CXXFLAGS} ${SYMBOLS} -o $@.d $< ${INCLUDES}
	@${CXX} -c ${CXXFLAGS} ${SYMBOLS} -o $@ $< ${INCLUDES}

install: ${TARGET}
	@echo "Install $< to ${VREP_PATH}"
	@cp $< ${VREP_PATH}

clean:
	@echo "Cleaning"
	@rm -rf ${PLUGIN_BUILD} ${BUILD} ${LIB} ./latex ./html

doc:
	@echo "Generating Documentation"
	@doxygen Doxyfile

-include ${DEPS}
