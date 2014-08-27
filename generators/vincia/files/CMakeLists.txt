cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
#----------------------------------------------------------------------------
project(vincia CXX Fortran)

set(BUILD_ALL_EXAMPLES OFF)   # by default we build only vincia01.cc
INCLUDE( ${PROJECT_SOURCE_DIR}/cmake/modules/TargetDistclean.cmake OPTIONAL)

set(CMAKE_DISABLE_SOURCE_CHANGES ON)
SET(CMAKE_COLOR_MAKEFILE ON)

#set this to true if you are using makefiles and want to see the full compile and link commands instead of only the shortened ones 
SET(CMAKE_VERBOSE_MAKEFILE ON)

configure_file(
    "${PROJECT_SOURCE_DIR}/vinciaenv.sh.in"
    "${PROJECT_BINARY_DIR}/vinciaenv.sh"
    @ONLY)
configure_file(
    "${PROJECT_SOURCE_DIR}/vinciaenv.csh.in"
    "${PROJECT_BINARY_DIR}/vinciaenv.csh"
    @ONLY)


IF( NOT CMAKE_BUILD_TYPE )
    SET( CMAKE_BUILD_TYPE "Release" )
ENDIF()

set(CMAKE_Fortran_FLAGS        "-fPIC -g -fno-automatic")
set(CMAKE_Fortran_FLAGS_RELEASE        "-fPIC -g -fno-automatic")

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/modules)

if (ROOTSYS)
 	find_package(ROOT REQUIRED COMPONENTS Core RIO Hist Graf Gpad)
endif (ROOTSYS)

find_package(FastJet REQUIRED)
find_package(Pythia8 REQUIRED)

if(PYTHIA8_VERSION VERSION_GREATER 176)
  add_definitions(-DPYTHIA8NEWVERS)
endif()

if ( NOT PYTHIA8_FOUND)
  message(FATAL_ERROR "Package Pythia8 required, but not found!")
endif( NOT PYTHIA8_FOUND)


#set (CMAKE_SHARED_LIBRARY_CREATE_CXX_FLAGS "-g -fPIC")




#---Compilation and Link options----------------------------------------------
if(CMAKE_SYSTEM_NAME MATCHES Darwin)
  set(CMAKE_SHARED_LIBRARY_CREATE_Fortran_FLAGS "${CMAKE_SHARED_LIBRARY_CREATE_Fortran_FLAGS} -flat_namespace -single_module -undefined dynamic_lookup")
  set( CMAKE_SHARED_LIBRARY_CREATE_CXX_FLAGS "${CMAKE_SHARED_LIBRARY_CREATE_CXX_FLAGS} -Wl,-undefined -Wl,dynamic_lookup -Wl,-single_module")
endif()

if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "4.7")
  set (std_flag "c++0x")
else()
  set (std_flag "c++11")
endif()

set(CMAKE_Fortran_FLAGS                "")
set(CMAKE_Fortran_FLAGS_DEBUG          "-fPIC -g -fno-automatic")
set(CMAKE_Fortran_FLAGS_MINSIZEREL     "-fPIC -Os -DNDEBUG -fno-automatic")
set(CMAKE_Fortran_FLAGS_RELEASE        "-fPIC -O2 -g  -fno-automatic")
set(CMAKE_Fortran_FLAGS_RELWITHDEBINFO "-fPIC -O2 -g -fno-automatic")
set(CMAKE_CXX_FLAGS_RELEASE        "-fPIC -g -O2 -fbounds-check -std=${std_flag}")

message(STATUS "PYTHIA8_INCLUDE_DIR == " ${PYTHIA8_INCLUDE_DIR} )
message(STATUS "PYTHIA8_LIBRARY == " ${PYTHIA8_LIBRARY} )
message(STATUS "PYTHIA8_LIBRARIES == " ${PYTHIA8_LIBRARIES} )


include_directories(${PYTHIA8_INCLUDE_DIR} ${PROJECT_SOURCE_DIR}/include
${PROJECT_SOURCE_DIR}/vinciaroot/include ${ROOT_INCLUDE_DIRS}
${FASTJET_INCLUDE_DIR} )

file(GLOB vincia_header_files ${PROJECT_SOURCE_DIR}/include/*.h ${PROJECT_SOURCE_DIR}/vinciaroot/include/*.h )

#---Select sources for the various libraries---------------------------------


file(GLOB MG_lib_files ${PROJECT_SOURCE_DIR}/MGInterface/HELAS/*.F  ${PROJECT_SOURCE_DIR}/MGInterface/HELAS/*.f)
list(REMOVE_ITEM MG_lib_files ${PROJECT_SOURCE_DIR}/MGInterface/HELAS/fvtikk.F ${PROJECT_SOURCE_DIR}/MGInterface/HELAS/fvtokk.F)



file(GLOB vincia_lib_sources
    ${PROJECT_SOURCE_DIR}/src/*.cc
    ${PROJECT_SOURCE_DIR}/src/*.f
)

file(GLOB vincia_MGInterfaceDummy_sources MGInterface/VinciaMGInterfaceDummy.cc) 
file(GLOB vincia_MGInterface_sources MGInterface/VinciaMGInterface.cc
MGInterface/*.f MGInterface/*.F  )

file(GLOB vincia_root_sources vinciaroot/src/*)


add_library(dhelas3 SHARED ${MG_lib_files})

add_library(vincia SHARED ${vincia_lib_sources})

#add_library(mginterfacedummy SHARED ${vincia_MGInterfaceDummy_sources} )

add_library(mginterface SHARED ${vincia_MGInterface_sources} )

if (ROOTSYS)
add_library(vinciaroot SHARED ${vincia_root_sources} )
set (VINCIAROOT_INTERFACE vinciaroot)
endif (ROOTSYS)

if ( BUILD_ALL_EXAMPLES MATCHES ON)
	file( GLOB APP_SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} vincia*.cc )
else ( BUILD_ALL_EXAMPLES MATCHES ON) 
        file( GLOB APP_SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} vincia01.cc)	
endif (BUILD_ALL_EXAMPLES MATCHES ON)

foreach( testsourcefile ${APP_SOURCES} )
    # I used a simple string replace, to cut off .cc.
    string( REPLACE ".cc" ".exe" testname ${testsourcefile} )
    add_executable( ${testname} ${testsourcefile} )
    target_link_libraries( ${testname} vincia dhelas3 mginterface ${PYTHIA8_LIBRARIES} ${ROOT_LIBRARIES} ${VINCIAROOT_INTERFACE} ${FASTJET_LIBRARIES} )
    install(TARGETS ${testname} RUNTIME DESTINATION bin)
endforeach( testsourcefile ${APP_SOURCES} )


# install targets -----------------------------------

FILE(GLOB cmnd_files "${CMAKE_CURRENT_SOURCE_DIR}/*.cmnd")	
INSTALL( FILES ${cmnd_files}  DESTINATION bin)

FILE(GLOB xml_examples_files "${CMAKE_CURRENT_SOURCE_DIR}/vincia*.xml")
INSTALL( FILES ${xml_examples_files}  DESTINATION bin)

install(TARGETS dhelas3 vincia   mginterface LIBRARY DESTINATION lib)

if (ROOTSYS)
	install(TARGETS vinciaroot LIBRARY DESTINATION lib)
endif (ROOTSYS)

install( FILES ${vincia_header_files} DESTINATION include) 

install(DIRECTORY settings DESTINATION .)

install(FILES ${CMAKE_BINARY_DIR}/vinciaenv.sh  DESTINATION .)
install(FILES ${CMAKE_BINARY_DIR}/vinciaenv.csh DESTINATION .)

# display status message for important variables
MESSAGE( STATUS )
MESSAGE( STATUS
"-------------------------------------------------------------------------------"
)
MESSAGE( STATUS "BUILD_SHARED_LIBS = ${BUILD_SHARED_LIBS}" )
MESSAGE( STATUS "CMAKE_INSTALL_PREFIX = ${CMAKE_INSTALL_PREFIX}" )
MESSAGE( STATUS "CMAKE_BUILD_TYPE = ${CMAKE_BUILD_TYPE}" )
MESSAGE( STATUS "CMAKE_MODULE_PATH = ${CMAKE_MODULE_PATH}" )
MESSAGE( STATUS "CMAKE_BINARY_DIR = ${CMAKE_BINARY_DIR}" )
MESSAGE( STATUS "${PROJECT_NAME}_DEPENDS = \"${${PROJECT_NAME}_DEPENDS}\"" )
MESSAGE( STATUS "BUILD_WITH = \"${BUILD_WITH}\"" )
MESSAGE( STATUS "INSTALL_DOC = ${INSTALL_DOC}" )
MESSAGE( STATUS "Change a value with: cmake -D<Variable>=<Value>" )
MESSAGE( STATUS
"-------------------------------------------------------------------------------"
)
MESSAGE( STATUS )

# force some variables that could be defined in the command line
# to be written to cache
SET( BUILD_SHARED_LIBS "${BUILD_SHARED_LIBS}" CACHE BOOL
    "Set to OFF to build static libraries" FORCE )
SET( CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}" CACHE PATH
    "Where to install ${PROJECT_NAME}" FORCE )
SET( CMAKE_BUILD_TYPE "${CMAKE_BUILD_TYPE}" CACHE STRING
    "Choose the type of build, options are: None Debug Release RelWithDebInfo
MinSizeRel." FORCE )
SET( CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" CACHE PATH
    "Path to custom CMake Modules" FORCE )
SET( INSTALL_DOC "${INSTALL_DOC}" CACHE BOOL
    "Set to OFF to skip build/install Documentation" FORCE )
