cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(photos-tests Fortran)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../../../cmake/modules)

find_package(Photos REQUIRED)
find_package(Pythia6 REQUIRED)

include_directories(${PHOTOS_INCLUDE_DIR} ${PYTHIA6_INCLUDE_DIR})

add_executable(photos_test1 photos_test1.F)
target_link_libraries(photos_test1 ${PHOTOS_LIBRARIES} ${PYTHIA6_LIBRARIES} ${PYTHIA6_LIBRARY_DIR}/pydata.o)

