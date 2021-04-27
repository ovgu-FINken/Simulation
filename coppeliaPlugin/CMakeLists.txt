cmake_minimum_required(VERSION 3.0.0)
project(simExtFinken)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_MODULE_PATH
  "../../CoppeliaSim/programming/libPlugin/cmake/")
set(PAPARAZZI_HOME "../../paparazzi" )
set(CMAKE_EXPORT_COMPILE_COMMANDS 1)

find_package(CoppeliaSim 4.2.0 REQUIRED)
find_package(Eigen3 REQUIRED)
find_package(Boost 1.72 REQUIRED COMPONENTS thread system random filesystem serialization)

include_directories(${CMAKE_CURRENT_BINARY_DIR}/generated)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/external)

coppeliasim_generate_stubs(${CMAKE_CURRENT_BINARY_DIR}/generated XML_FILE ${CMAKE_CURRENT_SOURCE_DIR}/callbacks.xml)

#configure_file(${CMAKE_CURRENT_SOURCE_DIR}/config.h.in ${CMAKE_CURRENT_BINARY_DIR}/config.h ESCAPE_QUOTES)

include_directories(${PAPARAZZI_HOME}/sw/simulator/nps/ ${EIGEN3_INCLUDE_DIRS})

COPPELIASIM_ADD_PLUGIN(simExtFinken SOURCES sonar.cpp positionsensor.cpp
  heightsensor.cpp finken.cpp attitudesensor.cpp accelerometer.cpp
  finkenplugin.cpp rotor.cpp log.cpp)

target_link_libraries(simExtFinken Boost::system Boost::random
  Boost::filesystem Boost::serialization Boost::thread)
