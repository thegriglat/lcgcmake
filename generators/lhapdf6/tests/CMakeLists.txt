cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(lhapdf6-tests CXX)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../../../cmake/modules)

find_package(Lhapdf6 REQUIRED)
find_package(Yamlcpp REQUIRED)

if(APPLE AND CMAKE_CXX_COMPILER_ID STREQUAL Clang)
  set(Boost_COMPILER -xgcc42)
endif()
#set(Boost_DEBUG ON)
# "1.49" is a minimum required version
find_package(Boost 1.49 REQUIRED COMPONENTS filesystem system)

set(TEST_DIR ${LHAPDF6_ROOT_DIR}/../share/sources/examples/)

include_directories(${LHAPDF6_INCLUDE_DIRS} ${Boost_INCLUDE_DIRS} ${YAMLCPP_INCLUDE_DIRS})

add_executable(native-testpdf ${TEST_DIR}/testpdf.cc)
target_link_libraries(native-testpdf ${LHAPDF6_LIBRARIES} ${Boost_LIBRARIES} ${YAMLCPP_LIBRARIES})
