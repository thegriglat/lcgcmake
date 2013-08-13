cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(sherpa-tests CXX)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../../../cmake/modules)

find_package(Sherpa REQUIRED)
find_package(HepMC REQUIRED)
find_package(GSL REQUIRED)

message("HEPMC_INCLUDE_DIR=${HEPMC_INCLUDE_DIR}")

include_directories(${SHERPA_INCLUDE_DIR} ${GSL_INCLUDE_DIR} ${HEPMC_INCLUDE_DIR})
