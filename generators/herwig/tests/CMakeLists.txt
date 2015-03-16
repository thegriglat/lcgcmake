cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(herwig-tests CXX Fortran)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH2})

find_package(Herwig REQUIRED)
find_package(HepMC REQUIRED)

include_directories(${HERWIG_INCLUDE_DIR} ${HEPMC_INCLUDE_DIR})

add_executable(herwig_genser_outhepmc herwig_genser_outhepmc.cc)
target_link_libraries(herwig_genser_outhepmc ${HERWIG_LIBRARIES} ${HEPMC_LIBRARIES} ${HEPMC_fio_LIBRARY})
