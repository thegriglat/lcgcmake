cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(evtgen-tests CXX)

list(APPEND CMAKE_MODULE_PATH ${MYADDMODULEPATH})

find_package(EvtGen REQUIRED)
find_package(Photospp REQUIRED)
find_package(Tauolapp REQUIRED)
find_package(Pythia8 REQUIRED)
find_package(HepMC REQUIRED)
find_package(ROOT COMPONENTS Hist RIO)

set(TEST_DIR ${EVTGEN_ROOT_DIR}/../share/sources/test/)

include_directories(${EVTGEN_INCLUDE_DIR} 
                    ${PHOTOSPP_INCLUDE_DIR} 
                    ${HEPMC_INCLUDE_DIR} 
                    ${PYTHIA8_INCLUDE_DIR}
                    ${ROOT_INCLUDE_DIR})

add_executable(evtgen_test1 evtgen_test1.cc)
target_link_libraries(evtgen_test1 ${EVTGEN_LIBRARIES} ${PHOTOSPP_LIBRARIES} ${TAUOLAPP_INTERFACE_LIBRARY} ${HEPMC_LIBRARIES} ${PYTHIA8_LIBRARIES} ${ROOT_LIBRARIES})

