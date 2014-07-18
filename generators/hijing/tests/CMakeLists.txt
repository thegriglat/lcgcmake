cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(hijing-tests Fortran)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../../../cmake/modules)

find_package(Hijing REQUIRED)

# strip PAUSE FORTRAN command
file(READ ${HIJING_ROOT_DIR}/../share/sources/examples/example_1.f ORIGINAL)
STRING(REPLACE "PAUSE" "" REPLACED ${ORIGINAL})
STRING(REPLACE "N_events=100" "N_events=10" REPLACED ${REPLACED})
file(WRITE ${CMAKE_BINARY_DIR}/example_1-nopause.f ${REPLACED})

add_executable(hijing_orig_example1-nopause ${CMAKE_BINARY_DIR}/example_1-nopause.f)
target_link_libraries(hijing_orig_example1-nopause ${HIJING_LIBRARIES})

