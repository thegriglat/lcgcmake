cmake_minimum_required(VERSION 2.6 FATAL_ERROR)
#----------------------------------------------------------------------------
project(pyquen Fortran)
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
#---This CMakeList.txt file asumes that the Pythia6 file has been splitted
#   add prepared moving the files around
#----------------------------------------------------------------------------

#---Compilation and Link options----------------------------------------------
if(CMAKE_SYSTEM_NAME MATCHES Darwin)
  set(CMAKE_SHARED_LIBRARY_CREATE_Fortran_FLAGS "${CMAKE_SHARED_LIBRARY_CREATE_Fortran_FLAGS} -flat_namespace -single_module -undefined dynamic_lookup")
endif()

include_directories(include)

#---Select sources for the various libraries---------------------------------
file(GLOB pyquen_sources ${PROJECT_SOURCE_DIR}/src/*.f)

#---Add libraries------------------------------------------------------------

add_library(pyquen SHARED ${pyquen_sources})
add_library(pyquen_static STATIC ${pyquen_sources})
set_target_properties(pyquen_static PROPERTIES OUTPUT_NAME pyquen)

#---Install build products---------------------------------------------------
install(TARGETS pyquen DESTINATION lib)
install(TARGETS pyquen_static  DESTINATION lib)
install(TARGETS pyquen_static  DESTINATION lib/archive)
