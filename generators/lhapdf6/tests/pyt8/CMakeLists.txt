cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(lhapdf6-tests CXX)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../../../cmake/modules)

find_package(Pythia8 REQUIRED)

find_package(Lhapdf6 REQUIRED)
find_package(Yamlcpp REQUIRED)

if(APPLE AND CMAKE_CXX_COMPILER_ID STREQUAL Clang)
  set(Boost_COMPILER -xgcc42)
endif()
#set(Boost_DEBUG ON)
# "1.49" is a minimum required version
find_package(Boost 1.49 REQUIRED COMPONENTS filesystem system)

include_directories(${PYTHIA8_INCLUDE_DIR} ${LHAPDF6_INCLUDE_DIRS} ${Boost_INCLUDE_DIRS} ${YAMLCPP_INCLUDE_DIRS})

add_executable(lhapdf6_pyt8 lhapdf6_pyt8.cc)
target_link_libraries(lhapdf6_pyt8 ${PYTHIA8_LIBRARY} ${LHAPDF6_LIBRARIES} ${Boost_LIBRARIES} ${YAMLCPP_LIBRARIES})
