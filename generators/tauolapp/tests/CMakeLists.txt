cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(tauolapp-tests CXX)

set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../../../cmake/modules ${CMAKE_MODULE_PATH})

find_package(Tauolapp REQUIRED)
find_package(Pythia8 REQUIRED)
find_package(HepMC REQUIRED)

set(TEST_DIR ${TAUOLAPP_ROOT_DIR}/../share/sources/examples/)

include_directories(${TAUOLAPP_INCLUDE_DIR} ${HEPMC_INCLUDE_DIR} ${PYTHIA8_INCLUDE_DIRS})
add_definitions(-DPYTHIA8_VERSION=${PYTHIA8_VERSION})
#in version 1.1.5 the authors introduced their own variable:
if(${PYTHIA8_VERSION} VERSION_GREATER 177)
 add_definitions(-DPYTHIA8180_OR_LATER)
endif()

add_executable(native-taumain_stand_alone ${TEST_DIR}/taumain_stand_alone_example.cxx)
target_link_libraries(native-taumain_stand_alone ${TAUOLAPP_INTERFACE_LIBRARY} ${TAUOLAPP_FORTRAN_LIBRARY} ${HEPMC_LIBRARIES})

add_executable(native-taummk_pythia ${TEST_DIR}/taummk_pythia_example.cxx)
target_link_libraries(native-taummk_pythia ${TAUOLAPP_INTERFACE_LIBRARY} ${TAUOLAPP_FORTRAN_LIBRARY} ${HEPMC_LIBRARIES} ${PYTHIA8_LIBRARIES})

add_executable(native-taumain_hepevt ${TEST_DIR}/taumain_hepevt_example.cxx)
target_link_libraries(native-taumain_hepevt ${TAUOLAPP_INTERFACE_LIBRARY}  ${TAUOLAPP_FORTRAN_LIBRARY} ${HEPMC_LIBRARIES})

add_executable(genser-test1 tauolapp_test1.cc)
target_link_libraries(genser-test1 ${TAUOLAPP_INTERFACE_LIBRARY}  ${TAUOLAPP_FORTRAN_LIBRARY} ${HEPMC_LIBRARIES} ${PYTHIA8_LIBRARIES})
