cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(pythia8-tests CXX)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH2})

find_package(Pythia8 REQUIRED)

if(PYTHIA8_VERSION VERSION_GREATER 176)
  add_definitions(-DPYTHIA8NEWVERS)
endif()
if(NOT (PYTHIA8_VERSION VERSION_LESS 200))
  add_definitions(-DPYTHIA8200)
endif()

#if(PYTHIA8_VERSION VERSION_LESS 200)
#  set(PYTHIA8_lhapdfdummy_LIBRARY "")
#endif()

find_package(HepMC REQUIRED)

find_package(FastJet REQUIRED)

include_directories(${CMAKE_SOURCE_DIR}/analyserhepmc ${PYTHIA8_INCLUDE_DIR} ${HEPMC_INCLUDE_DIR} ${FASTJET_INCLUDE_DIR})

if(PYTHIA8_VERSION VERSION_LESS 200 OR PYTHIA8_VERSION VERSION_GREATER 204)
  set(TESTS_DIR ${PYTHIA8_ROOT_DIR}/../share/sources/examples)
else()
  set(TESTS_DIR ${PYTHIA8_ROOT_DIR}/../share/sources/share/Pythia8/examples)
endif()

add_executable(pythia8_genser_test1 pythia8_test1.cc analyserhepmc/AnalyserHepMC.cc analyserhepmc/LeptonAnalyserHepMC.cc analyserhepmc/JetInputHepMC.cc)
target_link_libraries(pythia8_genser_test1 ${PYTHIA8_LIBRARIES} ${HEPMC_LIBRARIES} ${FASTJET_LIBRARIES})

add_executable(pythia8 pythia8.cc)
target_link_libraries(pythia8 ${PYTHIA8_LIBRARIES} ${HEPMC_LIBRARIES} ${FASTJET_LIBRARIES})

if(${PYTHIA8_VERSION} MATCHES "^2[0-9][0-9]" OR ${PYTHIA8_VERSION} MATCHES "HEAD")
  add_executable(pythia8_genser_test1_lhapdf pythia8_test1_lhapdf.cc analyserhepmc/AnalyserHepMC.cc analyserhepmc/LeptonAnalyserHepMC.cc analyserhepmc/JetInputHepMC.cc)
  target_link_libraries(pythia8_genser_test1_lhapdf ${PYTHIA8_LIBRARIES} ${HEPMC_LIBRARIES} ${FASTJET_LIBRARIES})
endif()

add_executable(pythia8_genser_test2 pythia8_test2.cc analyserhepmc/AnalyserHepMC.cc analyserhepmc/LeptonAnalyserHepMC.cc analyserhepmc/JetInputHepMC.cc)
target_link_libraries(pythia8_genser_test2 ${PYTHIA8_LIBRARIES} ${HEPMC_LIBRARIES} ${FASTJET_LIBRARIES})

add_executable(pythia8_main14_genser main14_genser.cc)
target_link_libraries(pythia8_main14_genser ${PYTHIA8_LIBRARIES} ${HEPMC_LIBRARIES})

add_executable(pythia8_genser_test3 pythia8_test3.cc)
target_link_libraries(pythia8_genser_test3 ${PYTHIA8_LIBRARIES} ${HEPMC_LIBRARIES})

add_executable(pythia8_genser_test4 pythia8_test4.cc)
target_link_libraries(pythia8_genser_test4 ${PYTHIA8_LIBRARIES} ${HEPMC_LIBRARIES})


add_executable(native-main01 ${TESTS_DIR}/main01.cc)
target_link_libraries(native-main01 ${PYTHIA8_LIBRARY} ${PYTHIA8_lhapdfdummy_LIBRARY})

add_executable(pythia8_orig_test2 ${TESTS_DIR}/main02.cc)
target_link_libraries(pythia8_orig_test2 ${PYTHIA8_LIBRARY} ${PYTHIA8_lhapdfdummy_LIBRARY})

add_executable(pythia8_orig_test3 ${TESTS_DIR}/main03.cc)
target_link_libraries(pythia8_orig_test3 ${PYTHIA8_LIBRARY} ${PYTHIA8_lhapdfdummy_LIBRARY})

add_executable(pythia8_orig_test4 ${TESTS_DIR}/main04.cc)
target_link_libraries(pythia8_orig_test4 ${PYTHIA8_LIBRARY} ${PYTHIA8_lhapdfdummy_LIBRARY})

add_executable(pythia8_orig_test5 ${TESTS_DIR}/main05.cc)
target_link_libraries(pythia8_orig_test5 ${PYTHIA8_LIBRARY} ${PYTHIA8_lhapdfdummy_LIBRARY})

add_executable(pythia8_orig_test6 ${TESTS_DIR}/main06.cc)
target_link_libraries(pythia8_orig_test6 ${PYTHIA8_LIBRARY} ${PYTHIA8_lhapdfdummy_LIBRARY})

add_executable(pythia8_orig_test7 ${TESTS_DIR}/main07.cc)
target_link_libraries(pythia8_orig_test7 ${PYTHIA8_LIBRARY} ${PYTHIA8_lhapdfdummy_LIBRARY})

add_executable(pythia8_orig_test8 ${TESTS_DIR}/main08.cc)
target_link_libraries(pythia8_orig_test8 ${PYTHIA8_LIBRARY} ${PYTHIA8_lhapdfdummy_LIBRARY})

add_executable(pythia8_orig_test9 ${TESTS_DIR}/main09.cc)
target_link_libraries(pythia8_orig_test9 ${PYTHIA8_LIBRARY} ${PYTHIA8_lhapdfdummy_LIBRARY})
