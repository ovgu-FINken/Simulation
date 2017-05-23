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
    v_repLib.cpp

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
    v_repLib.h
