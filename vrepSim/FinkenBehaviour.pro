TEMPLATE = app
CONFIG += console c++11
CONFIG -= app_bundle
CONFIG -= qt
CONFIG += c++11
LIBS += \
    -ldl\
    -lboost_system\
    -lboost_filesystem
INCLUDEPATH += "/home/dom/Software/vrep/programming/include"
INCLUDEPATH += "/home/dom/Software/vrep/programming/common"
INCLUDEPATH += "/home/dom/swarmlab/Simulation/FinkenBehaviour/pprz"
SOURCES += \
    sensor.cpp \
    simtestdummy.cpp \
    positionsensor.cpp \
    attitudesensor.cpp \
    heightsensor.cpp \
    finken.cpp \
    sonar.cpp \
    vrepplugin.cpp \
    log.cpp \
    finkenplugin.cpp \
    skeleton.cpp \
    rotor.cpp \
    finkencontrol.cpp \
    finkenPID.cpp \
    pprz/ahrs_float_cmpl.c

HEADERS += \
    sensor.h \
    simtestdummy.h \
    positionsensor.h \
    attitudesensor.h \
    heightsensor.h \
    finken.h \
    sonar.h \
    vrepplugin.h \
    log.h \
    rotor.h \
    v_repLib.h \
    finkencontrol.h \
    finkenPID.h \
    pprz/ahrs_float_cmpl.h
