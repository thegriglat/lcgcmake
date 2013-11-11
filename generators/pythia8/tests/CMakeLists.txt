cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(pythia8-tests CXX)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH2})

find_package(Pythia8 REQUIRED)

message("from tests: PYTHIA8_VERSION_CHECK=${PYTHIA8_VERSION_CHECK}")

if(${PYTHIA8_VERSION_CHECK} STREQUAL "NEW")
  set(CMAKE_CXX_FLAGS "${CMAKE_Fortran_FLAGS} -DPYTHIA8NEWVERS")
  set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_Fortran_FLAGS_DEBUG} -DPYTHIA8NEWVERS")
  set(CMAKE_CXX_FLAGS_MINSIZEREL "${CMAKE_Fortran_FLAGS_MINSIZEREL} -DPYTHIA8NEWVERS")
  set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_Fortran_FLAGS_RELEASE} -DPYTHIA8NEWVERS")  
  set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_Fortran_FLAGS_RELWITHDEBINFO} -DPYTHIA8NEWVERS")
endif()

find_package(HepMC REQUIRED)

find_package(FastJet REQUIRED)

include_directories(${CMAKE_SOURCE_DIR}/analyserhepmc ${PYTHIA8_INCLUDE_DIR} ${HEPMC_INCLUDE_DIR} ${FASTJET_INCLUDE_DIR})

set(TESTS_DIR ${PYTHIA8_ROOT_DIR}/../share/sources/examples)

add_executable(pythia8_genser_test1 pythia8_test1.cc analyserhepmc/AnalyserHepMC.cc analyserhepmc/LeptonAnalyserHepMC.cc analyserhepmc/JetInputHepMC.cc)
target_link_libraries(pythia8_genser_test1 ${PYTHIA8_LIBRARIES} ${HEPMC_LIBRARIES} ${FASTJET_LIBRARIES})

add_executable(pythia8_genser_test2 pythia8_test2.cc analyserhepmc/AnalyserHepMC.cc analyserhepmc/LeptonAnalyserHepMC.cc analyserhepmc/JetInputHepMC.cc)
target_link_libraries(pythia8_genser_test2 ${PYTHIA8_LIBRARIES} ${HEPMC_LIBRARIES} ${FASTJET_LIBRARIES})

add_executable(pythia8_genser_test3 pythia8_test3.cc)
target_link_libraries(pythia8_genser_test3 ${PYTHIA8_LIBRARIES} ${HEPMC_LIBRARIES})

add_executable(pythia8_genser_test4 pythia8_test4.cc)
target_link_libraries(pythia8_genser_test4 ${PYTHIA8_LIBRARIES} ${HEPMC_LIBRARIES})


add_executable(pythia8_orig_test1 ${TESTS_DIR}/main01.cc)
target_link_libraries(pythia8_orig_test1 ${PYTHIA8_LIBRARY} ${PYTHIA8_lhapdfdummy_LIBRARY})

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
