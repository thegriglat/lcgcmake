cmake_minimum_required(VERSION 2.6 FATAL_ERROR)
#----------------------------------------------------------------------------
project(pythia6 Fortran)
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
#---This CMakeList.txt file asumes that the Pythia6 file has been splitted
#   add prepared moving the files around
#----------------------------------------------------------------------------

#---Compilation and Link options----------------------------------------------
if(CMAKE_SYSTEM_NAME MATCHES Darwin)
  set(CMAKE_SHARED_LIBRARY_CREATE_Fortran_FLAGS "${CMAKE_SHARED_LIBRARY_CREATE_Fortran_FLAGS} -flat_namespace -single_module -undefined dynamic_lookup")
endif()

set(CMAKE_Fortran_FLAGS                "")
set(CMAKE_Fortran_FLAGS_DEBUG          "-fPIC -g -fno-automatic")
set(CMAKE_Fortran_FLAGS_MINSIZEREL     "-fPIC -Os -DNDEBUG -fno-automatic")
set(CMAKE_Fortran_FLAGS_RELEASE        "-fPIC -O2 -DNDEBUG -fno-automatic")
set(CMAKE_Fortran_FLAGS_RELWITHDEBINFO "-fPIC -O2 -g -fno-automatic")

include_directories(include)

#---Select sources for the various libraries---------------------------------
file(GLOB pythia_sources ${PROJECT_SOURCE_DIR}/src/*.f)
file(GLOB pythia_dummy_sources ${PROJECT_SOURCE_DIR}/dummy/*.f)
file(GLOB pythia_pdfdummy_sources ${PROJECT_SOURCE_DIR}/pdfdummy/*.f)
set(rootinterface_sources
  ${PROJECT_SOURCE_DIR}/rootinterface/pythia6_common_address.c
  ${PROJECT_SOURCE_DIR}/rootinterface/tpythia6_called_from_cc.f
)

#---Add libraries------------------------------------------------------------

add_library(pythia6 SHARED ${pythia_sources})
add_library(pythia6_static STATIC ${pythia_sources})
set_target_properties(pythia6 PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/src)
set_target_properties(pythia6_static PROPERTIES OUTPUT_NAME pythia6 ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/src)

add_library(pythia6_dummy SHARED ${pythia_dummy_sources})
add_library(pythia6_dummy_static STATIC ${pythia_dummy_sources})
set_target_properties(pythia6_dummy PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/dummy)
set_target_properties(pythia6_dummy_static PROPERTIES OUTPUT_NAME pythia6_dummy ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/dummy)

add_library(pythia6_pdfdummy SHARED ${pythia_pdfdummy_sources})
add_library(pythia6_pdfdummy_static STATIC ${pythia_pdfdummy_sources})
set_target_properties(pythia6_pdfdummy PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/pdfdummy)
set_target_properties(pythia6_pdfdummy_static PROPERTIES OUTPUT_NAME pythia6_pdfdummy ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/pdfdummy)

add_library(rootinterface SHARED ${rootinterface_sources})
add_library(rootinterface_static STATIC ${rootinterface_sources})
set_target_properties(rootinterface PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/rootinterface)
set_target_properties(rootinterface_static PROPERTIES OUTPUT_NAME rootinterface ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/rootinterface)

#---Install build products---------------------------------------------------
install(TARGETS pythia6  pythia6_dummy  pythia6_pdfdummy rootinterface DESTINATION lib)
install(TARGETS pythia6_static  pythia6_dummy_static  pythia6_pdfdummy_static rootinterface_static DESTINATION lib)
install(DIRECTORY include/ DESTINATION include FILES_MATCHING PATTERN *.inc PATTERN *.f PATTERN .svn EXCLUDE)

#---Install pydata.o file----------------------------------------------------
install(FILES ${CMAKE_BINARY_DIR}/CMakeFiles/pythia6.dir/src/pydata.f.o DESTINATION lib RENAME pydata.o)

#---create subdirectory archive with symlinks----------------------------------
install(CODE "file(MAKE_DIRECTORY ${CMAKE_INSTALL_PREFIX}/lib/archive)")
install(CODE "execute_process(COMMAND cmake -E create_symlink ../libpythia6.a ${CMAKE_INSTALL_PREFIX}/lib/archive/libpythia6.a)")
install(CODE "execute_process(COMMAND cmake -E create_symlink ../libpythia6_dummy.a ${CMAKE_INSTALL_PREFIX}/lib/archive/libpythia6_dummy.a)")
install(CODE "execute_process(COMMAND cmake -E create_symlink ../libpythia6_pdfdummy.a ${CMAKE_INSTALL_PREFIX}/lib/archive/libpythia6_pdfdummy.a)")
install(CODE "execute_process(COMMAND cmake -E create_symlink ../librootinterface.a ${CMAKE_INSTALL_PREFIX}/lib/archive/librootinterface.a)")
