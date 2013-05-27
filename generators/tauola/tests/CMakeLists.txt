cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(tauola-tests Fortran)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../../../cmake/modules)

find_package(Photos REQUIRED)
find_package(Pythia6 REQUIRED)
find_package(Tauola REQUIRED)

include_directories(${PHOTOS_INCLUDE_DIR} ${PYTHIA6_INCLUDE_DIR}  ${TAUOLA_INCLUDE_DIR})

add_executable(tauola_test1 tauola_test1.F)
target_link_libraries(tauola_test1 ${TAUOLA_LIBRARIES} ${PHOTOS_LIBRARIES} ${PYTHIA6_LIBRARIES} ${PYTHIA6_LIBRARY_DIR}/pydata.o)

