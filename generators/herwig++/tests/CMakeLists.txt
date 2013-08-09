cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(herwigpp-tests CXX)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../../../cmake/modules)

find_package(Herwigpp REQUIRED)
find_package(ThePEG REQUIRED)
find_package(HepMC REQUIRED)
find_package(GSL REQUIRED)

message("HEPMC_INCLUDE_DIR=${HEPMC_INCLUDE_DIR}")

include_directories(${HERWIGPP_INCLUDE_DIR} ${GSL_INCLUDE_DIR} ${THEPEG_INCLUDE_DIR} ${HEPMC_INCLUDE_DIR})
