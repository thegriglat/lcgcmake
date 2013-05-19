cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(hydjet-tests Fortran)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../../../cmake/modules)

find_package(Hydjet REQUIRED)
find_package(Pythia6 REQUIRED)
find_package(Pyquen REQUIRED)

include_directories(${HYDJET_INCLUDE_DIR} ${PYTHIA6_INCLUDE_DIR}  ${PYQUEN_INCLUDE_DIR})

add_executable(hydjet_test hydjet_test3.f ${PYTHIA6_INCLUDE_DIR}/../../share/sources/orig/pythia-6.4.27.f ${HYDJET_INCLUDE_DIR}/../share/sources/src/hydjet1_8.f ${PYQUEN_INCLUDE_DIR}/../share/sources/orig/pyquen.f ${HYDJET_INCLUDE_DIR}/../share/sources/jetset_orig/jetset_73.f)

target_link_libraries(hydjet_test ${HYDJET_LIBRARIES} ${PYQUEN_LIBRARIES} ${PYTHIA6_LIBRARIES} )

