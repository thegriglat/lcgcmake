cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(pythia6-tests CXX Fortran)

set(TEST_DIR ${BLACKHAT_ROOT_DIR}/../share/sources/examples)

add_executable(cpp_example ${TEST_DIR}/cpp_example.cpp)
add_executable(fortran_example ${TEST_DIR}/fortran_example.f)

file (GLOB blackhat_libraries ${BLACKHAT_ROOT_DIR}/lib/blackhat/*.so)
file (GLOB qd_libraries ${BLACKHAT_ROOT_DIR}/lib/*.so)

file (GLOB test_files ${TEST_DIR}/*)
file (COPY ${test_files} DESTINATION ./)

target_link_libraries(cpp_example ${blackhat_libraries})
target_link_libraries(fortran_example ${blackhat_libraries} ${qd_libraries})
