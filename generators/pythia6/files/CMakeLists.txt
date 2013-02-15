cmake_minimum_required(VERSION 2.6 FATAL_ERROR)
#----------------------------------------------------------------------------
project(pythia6 Fortran)
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
#---This CMakeList. txt file asumes that the Pythia6 file has been splitted
#   add prepared moving the files around
#----------------------------------------------------------------------------

#---Select sources for the various libraries---------------------------------
file(GLOB pythia_sources ${PROJECT_SOURCE_DIR}/src/*.f)
file(GLOB pythia_dummy_sources ${PROJECT_SOURCE_DIR}/dummy/*.f)
file(GLOB pythia_pdfdummy_sources ${PROJECT_SOURCE_DIR}/pdfdummy/*.f)

#---Add libraries------------------------------------------------------------
add_library(pythia6_dummy SHARED ${pythia_dummy_sources})
add_library(pythia6_pdfdummy SHARED ${pythia_pdfdummy_sources})
add_library(pythia6 SHARED ${pythia_sources})


#---Install build products---------------------------------------------------
install(TARGETS pythia6  pythia6_dummy  pythia6_pdfdummy DESTINATION lib)


