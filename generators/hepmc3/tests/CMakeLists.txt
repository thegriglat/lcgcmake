cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(hepmc3-pythia8-tests CXX)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH2})

find_package(Pythia8 REQUIRED)

#if(PYTHIA8_VERSION VERSION_GREATER 176)
#  add_definitions(-DPYTHIA8NEWVERS)
#endif()

find_package(hepmc3 REQUIRED)

find_package(Boost 1.40 REQUIRED)

set(HEPMC3_SOURCES_DIR ${HEPMC_ROOT_DIR}/../share/sources)
set(PYTHIA8_HEPMC3_INTERFACE ${HEPMC3_SOURCES_DIR}/tests/validation/interfaces/pythia8)


include_directories(${PYTHIA8_INCLUDE_DIR} ${PYTHIA8_HEPMC3_INTERFACE}/include ${HEPMC_INCLUDE_DIR} ${Boost_INCLUDE_DIRS})

add_executable(hepmc3_pythia8_test1 ${HEPMC3_SOURCES_DIR}/examples/pythia8_example.cc ${PYTHIA8_HEPMC3_INTERFACE}/src/Pythia8ToHepMC3.cc)
target_link_libraries(hepmc3_pythia8_test1 ${PYTHIA8_LIBRARY} ${PYTHIA8_lhapdfdummy_LIBRARY} ${HEPMC_LIBRARIES})
