cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(pyquen-tests Fortran)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../../../cmake/modules)

find_package(Pyquen REQUIRED)
find_package(Pythia6 REQUIRED)

include_directories(${PYQUEN_INCLUDE_DIR} ${PYTHIA6_INCLUDE_DIR})

add_executable(pyquen_test1 pyquen_test1.f ${PYTHIA6_ROOT_DIR}/lib/pydata.o)
target_link_libraries(pyquen_test1 ${PYQUEN_LIBRARIES} ${PYTHIA6_LIBRARIES})
