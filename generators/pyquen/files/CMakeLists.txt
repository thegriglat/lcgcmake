cmake_minimum_required(VERSION 2.6 FATAL_ERROR)

add_definitions(-DCMAKE_Fortran_FLAGS=                "${CMAKE_Fortran_FLAGS} -fPIC  -O2")
add_definitions(-DCMAKE_Fortran_FLAGS_DEBUG=          "${CMAKE_Fortran_FLAGS_DEBUG} -fPIC -g -fno-automatic")
add_definitions(-DCMAKE_Fortran_FLAGS_MINSIZEREL=     "${CMAKE_Fortran_FLAGS_MINSIZEREL} -fPIC -Os -DNDEBUG -fno-automatic")
add_definitions(-DCMAKE_Fortran_FLAGS_RELEASE=        "${CMAKE_Fortran_FLAGS_RELEASE} -fPIC -O2 -DNDEBUG -fno-automatic")
add_definitions(-DCMAKE_Fortran_FLAGS_RELWITHDEBINFO= "${CMAKE_Fortran_FLAGS_RELWITHDEBINFO} -fPIC -O2 -g -fno-automatic")

project(pyquen Fortran)

#---Compilation and Link options----------------------------------------------
if(CMAKE_SYSTEM_NAME MATCHES Darwin)
  set(CMAKE_SHARED_LIBRARY_CREATE_Fortran_FLAGS "${CMAKE_SHARED_LIBRARY_CREATE_Fortran_FLAGS} -flat_namespace -single_module -undefined dynamic_lookup")
endif()

#---Select sources for the various libraries---------------------------------
file(GLOB pyquen_sources pyquen*.f)

#---Add libraries------------------------------------------------------------
add_library(pyquen SHARED ${pyquen_sources})
add_library(pyquen_static STATIC ${pyquen_sources})
set_target_properties(pyquen_static PROPERTIES OUTPUT_NAME pyquen)

#---Install build products---------------------------------------------------
install(TARGETS pyquen DESTINATION lib)
install(TARGETS pyquen_static  DESTINATION lib)
