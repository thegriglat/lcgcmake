cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(evtgen-tests CXX)

list(APPEND CMAKE_MODULE_PATH ${MYADDMODULEPATH})

find_package(EvtGen REQUIRED)
find_package(Photospp REQUIRED)
find_package(Tauolapp REQUIRED)
find_package(Pythia8 REQUIRED)
find_package(HepMC REQUIRED)
find_package(ROOT COMPONENTS Core RIO Hist)

set(TEST_DIR ${EVTGEN_ROOT_DIR}/../share/sources/test/)

include_directories(${EVTGEN_INCLUDE_DIR} 
                    ${PHOTOSPP_INCLUDE_DIR} 
                    ${HEPMC_INCLUDE_DIR} 
                    ${PYTHIA8_INCLUDE_DIR}
                    ${ROOT_INCLUDE_DIR})

file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/evtgen_test1.cc DESTINATION ./)

if (UPDATEDHEADER)
  execute_process(COMMAND sed -i -e s,report,EvtGenReport,g evtgen_test1.cc)
  execute_process(COMMAND sed -i -e s,INFO,EVTGEN_INFO,g evtgen_test1.cc)
  execute_process(COMMAND sed -i -e s,ERROR,EVTGEN_ERROR,g evtgen_test1.cc)
  execute_process(COMMAND sed -i -e s,DEBUG,EVTGEN_DEBUG,g evtgen_test1.cc)
  execute_process(COMMAND sed -i -e s,EvtStdlibRandomEngine,EvtSimpleRandomEngine,g evtgen_test1.cc)
endif()

add_executable(evtgen_test1 ${CMAKE_CURRENT_BINARY_DIR}/evtgen_test1.cc)
target_link_libraries(evtgen_test1 ${EVTGEN_LIBRARIES} ${TAUOLAPP_FORTRAN_LIBRARY} ${TAUOLAPP_INTERFACE_LIBRARY} ${PHOTOSPP_LIBRARIES} ${HEPMC_LIBRARIES} ${PYTHIA8_LIBRARIES} ${ROOT_LIBRARIES})

