cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(hydjet-tests Fortran)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../../../cmake/modules)

find_package(Hydjet REQUIRED)
find_package(Pythia6 REQUIRED)
find_package(Pyquen REQUIRED)

#include_directories(${HYDJET_INCLUDE_DIR} ${PYTHIA6_INCLUDE_DIR} ${PYQUEN_INCLUDE_DIR})

add_executable(hydjet_test1 hydjet_test1.f ${PYTHIA6_ROOT_DIR}/lib/pydata.o)
target_link_libraries(hydjet_test1 ${PYQUEN_LIBRARIES} ${HYDJET_LIBRARIES} ${PYTHIA6_LIBRARIES} )
