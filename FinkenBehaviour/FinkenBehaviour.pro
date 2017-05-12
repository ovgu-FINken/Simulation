TEMPLATE = app
CONFIG += console c++11
CONFIG -= app_bundle
CONFIG -= qt

SOURCES += main.cpp \
    sensor.cpp \
    simtestdummy.cpp \
    heightSensor.cpp \
    positionsensor.cpp \
    attitudeSensor.cpp

HEADERS += \
    sensor.h \
    heightSensor.h \
    simtestdummy.h \
    positionsensor.h \
    attitudeSensor.h
