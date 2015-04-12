cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(LCGSoft C CXX Fortran)

list(INSERT CMAKE_MODULE_PATH 0 ${CMAKE_SOURCE_DIR}/cmake/modules)
if(NOT CMAKE_CONFIGURATION_TYPES AND NOT CMAKE_BUILD_TYPE) # Default to a Release build
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build [Release MinSizeRel Debug RelWithDebInfo]" FORCE)
endif()

#---Definition options and teir default values ------------------------------------------------------------------------
set(LCG_INSTALL_POLICY separate CACHE STRING "'separate' or 'join' installation of packages")
set(LCG_SAFE_INSTALL   OFF      CACHE BOOL "Ensure that no overwites occurs at the installation area of packages")
if (VALIDATION)
  set(LCG_IGNORE         "pythia8;pythia6;agile;rivet;herwig++"       CACHE STRING "List of packages to be ignored from LCG_INSTALL_PREFIX (';' separated)")
else()
  set(LCG_IGNORE         ""       CACHE STRING "List of packages to be ignored from LCG_INSTALL_PREFIX (';' separated)")
endif()
set(LCG_INSTALL_PREFIX ""       CACHE PATH "Existing LCG installation path prefix.")
set(LCG_TARBALL_INSTALL   OFF   CACHE BOOL "Turn ON/OFF creation/installation of tarballs")
set(VALIDATION         OFF      CACHE BOOL "Enable validation settings.")
string(REPLACE " " ";" LCG_IGNORE "${LCG_IGNORE}")

#---Report the values of the options-----------------------------------------------------------------------------------
message(STATUS "Target installation prefix             : ${CMAKE_INSTALL_PREFIX}")
message(STATUS "Existing LCG installations             : ${LCG_INSTALL_PREFIX}")
message(STATUS "Safe installation                      : ${LCG_SAFE_INSTALL}")
message(STATUS "Source and binary tarball installation : ${LCG_TARBALL_INSTALL}")
message(STATUS "Validation mode                        : ${VALIDATION}")
message(STATUS "Ignored packages from LCG installation : ${LCG_IGNORE}")

include(${CMAKE_SOURCE_DIR}/toolchain.cmake)
include(lcgsoft-macros)

#---Define Global variables--------------------------------------------------------------------------------------------
find_program(env_cmd NAMES env)
mark_as_advanced(env_cmd)
set(EXEC ${env_cmd})
set(MAKE ${CMAKE_SOURCE_DIR}/cmake/scripts/make_verbose $(MAKE))

string(TOUPPER "${CMAKE_BUILD_TYPE}" _build_type_upper)
if (_build_type_upper)
  set (_flag_suffix "_${_build_type_upper}")
endif()
message (STATUS "Common compiler flags: ")
foreach (_compiler C CXX Fortran)
    message(STATUS "  ${_compiler} : ${CMAKE_${_compiler}_FLAGS${_flag_suffix}}")
    set (${_compiler}_FLAGS "${CMAKE_${_compiler}_FLAGS${_flag_suffix}}")
endforeach()


#---Enable (the defintion) of tests by default-------------------------------------------------------------------------
enable_testing()
include(CTest)

set(TESTLOGDIR "${PROJECT_BINARY_DIR}/tests")
if(NOT "$ENV{CXXFLAGS}" STREQUAL "")
  set(libtoolpatch CXX=$ENV{CXX}\ $ENV{CXXFLAGS})
endif()

file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/timestamps)

add_subdirectory(externals)
add_subdirectory(gridexternals)
add_subdirectory(projects)
add_subdirectory(pyexternals)
add_subdirectory(generators)

if (VALIDATION)
  add_custom_target(validation.pre_builds DEPENDS rivet ROOT lhapdf Python HepMC agile cmaketools)
  add_custom_target(validation.pre_tests COMMAND ctest -R lhapdf6sets.download COMMAND ctest -R rivet-tests.genser-prepare_references COMMAND ctest -R rivet-tests.genser-buildanalysis DEPENDS validation.pre_builds)
  foreach(pkg sherpa pythia8 pythia6 herwig herwig++)
    set (_deplist)
    foreach(v ${${pkg}_native_version})
      add_custom_target(validation.${pkg}-${v} COMMAND ${CMAKE_SOURCE_DIR}/generators/validation/run.sh ${pkg} ${v} DEPENDS ${pkg}-${v} validation.pre_tests)
      list (APPEND _deplist validation.${pkg}-${v})
    endforeach()
    add_custom_target(validation.${pkg} DEPENDS ${_deplist})
    list(APPEND _depglobal validation.${pkg})
  endforeach()
  add_custom_target(validation DEPENDS ${_depglobal})
  add_custom_target(validation.publish COMMAND ${CMAKE_SOURCE_DIR}/generators/validation/publish.sh)
endif()

LCG_create_dependency_files()
file(WRITE ${CMAKE_BINARY_DIR}/fail-logs.txt "")
