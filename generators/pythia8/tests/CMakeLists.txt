cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(pythia8-tests CXX)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH2})

message("CMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}")

find_package(Pythia8 REQUIRED)
find_package(HepMC REQUIRED)

message("PYTHIA8_INCLUDE_DIR=${PYTHIA8_INCLUDE_DIRS}")

find_package(FastJet REQUIRED)
find_package(CLHEP REQUIRED)

include_directories(${CMAKE_SOURCE_DIR}/analyserhepmc ${PYTHIA8_INCLUDE_DIR} ${HEPMC_INCLUDE_DIR} ${FASTJET_INCLUDE_DIR} ${CLHEP_INCLUDE_DIR})

set(TESTS_DIR ${PYTHIA8_ROOT_DIR}/../share/sources/examples)

add_executable(pythia8_genser_test1 pythia8_test1.cc analyserhepmc/AnalyserHepMC.cc analyserhepmc/LeptonAnalyserHepMC.cc analyserhepmc/JetInputHepMC.cc)
target_link_libraries(pythia8_genser_test1 ${PYTHIA8_LIBRARIES} ${HEPMC_LIBRARIES} ${FASTJET_LIBRARIES} ${CLHEP_LIBRARIES})

#add_executable(pythia8_genser_test2 pythia8_test2.cc)
#target_link_libraries(pythia8_genser_test2 ${PYTHIA8_LIBRARIES} ${HEPMC_LIBRARIES})

add_executable(pythia8_genser_test3 pythia8_test3.cc)
target_link_libraries(pythia8_genser_test3 ${PYTHIA8_LIBRARIES} ${HEPMC_LIBRARIES})

add_executable(pythia8_genser_test4 pythia8_test4.cc)
target_link_libraries(pythia8_genser_test4 ${PYTHIA8_LIBRARIES} ${HEPMC_LIBRARIES})


add_executable(pythia8_orig_test1 ${TESTS_DIR}/main01.cc)
target_link_libraries(pythia8_orig_test1 ${PYTHIA8_LIBRARIES} ${HEPMC_LIBRARIES})

add_executable(pythia8_orig_test2 ${TESTS_DIR}/main02.cc)
target_link_libraries(pythia8_orig_test2 ${PYTHIA8_LIBRARIES} ${HEPMC_LIBRARIES})

add_executable(pythia8_orig_test3 ${TESTS_DIR}/main03.cc)
target_link_libraries(pythia8_orig_test3 ${PYTHIA8_LIBRARIES} ${HEPMC_LIBRARIES})

add_executable(pythia8_orig_test4 ${TESTS_DIR}/main04.cc)
target_link_libraries(pythia8_orig_test4 ${PYTHIA8_LIBRARIES} ${HEPMC_LIBRARIES})

add_executable(pythia8_orig_test5 ${TESTS_DIR}/main05.cc)
target_link_libraries(pythia8_orig_test5 ${PYTHIA8_LIBRARIES} ${HEPMC_LIBRARIES})

add_executable(pythia8_orig_test6 ${TESTS_DIR}/main06.cc)
target_link_libraries(pythia8_orig_test6 ${PYTHIA8_LIBRARIES} ${HEPMC_LIBRARIES})

add_executable(pythia8_orig_test7 ${TESTS_DIR}/main07.cc)
target_link_libraries(pythia8_orig_test7 ${PYTHIA8_LIBRARIES} ${HEPMC_LIBRARIES})

add_executable(pythia8_orig_test8 ${TESTS_DIR}/main08.cc)
target_link_libraries(pythia8_orig_test8 ${PYTHIA8_LIBRARIES} ${HEPMC_LIBRARIES})

add_executable(pythia8_orig_test9 ${TESTS_DIR}/main09.cc)
target_link_libraries(pythia8_orig_test9 ${PYTHIA8_LIBRARIES} ${HEPMC_LIBRARIES})

add_executable(pythia8_orig_test10 ${TESTS_DIR}/main10.cc)
target_link_libraries(pythia8_orig_test10 ${PYTHIA8_LIBRARIES} ${HEPMC_LIBRARIES})

add_executable(pythia8_orig_test11 ${TESTS_DIR}/main11.cc)
target_link_libraries(pythia8_orig_test11 ${PYTHIA8_LIBRARIES} ${HEPMC_LIBRARIES})

add_executable(pythia8_orig_test12 ${TESTS_DIR}/main12.cc)
target_link_libraries(pythia8_orig_test12 ${PYTHIA8_LIBRARIES} ${HEPMC_LIBRARIES})

add_executable(pythia8_orig_test13 ${TESTS_DIR}/main13.cc)
target_link_libraries(pythia8_orig_test13 ${PYTHIA8_LIBRARIES} ${HEPMC_LIBRARIES})

add_executable(pythia8_orig_test14 ${TESTS_DIR}/main14.cc)
target_link_libraries(pythia8_orig_test14 ${PYTHIA8_LIBRARIES} ${HEPMC_LIBRARIES})

add_executable(pythia8_orig_test15 ${TESTS_DIR}/main15.cc)
target_link_libraries(pythia8_orig_test15 ${PYTHIA8_LIBRARIES} ${HEPMC_LIBRARIES})


