cmake_minimum_required(VERSION 2.6 FATAL_ERROR)
#----------------------------------------------------------------------------
project(vincia CXX Fortran)

set(CMAKE_DISABLE_SOURCE_CHANGES ON)
set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)
SET(CMAKE_COLOR_MAKEFILE ON)

set(CMAKE_Fortran_FLAGS        "-fPIC -O2 -DNDEBUG -fno-automatic")
set(CMAKE_Fortran_FLAGS_RELEASE        "-fPIC -O2 -DNDEBUG -fno-automatic")

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/modules)

find_package(ROOT REQUIRED COMPONENTS Core RIO Hist Graf Gpad)
find_package(FastJet REQUIRED)
find_package(Pythia8 REQUIRED)

if(PYTHIA8_VERSION VERSION_GREATER 176)
  add_definitions(-DPYTHIA8NEWVERS)
endif()

if ( NOT PYTHIA8_FOUND)
  message(FATAL_ERROR "Package Pythia8 required, but not found!")
endif( NOT PYTHIA8_FOUND)






#---Compilation and Link options----------------------------------------------
if(CMAKE_SYSTEM_NAME MATCHES Darwin)
  set(CMAKE_SHARED_LIBRARY_CREATE_Fortran_FLAGS "${CMAKE_SHARED_LIBRARY_CREATE_Fortran_FLAGS} -flat_namespace -single_module -undefined dynamic_lookup")
endif()

set(CMAKE_Fortran_FLAGS                "")
set(CMAKE_Fortran_FLAGS_DEBUG          "-fPIC -g -fno-automatic")
set(CMAKE_Fortran_FLAGS_MINSIZEREL     "-fPIC -Os -DNDEBUG -fno-automatic")
set(CMAKE_Fortran_FLAGS_RELEASE        "-fPIC -O2 -DNDEBUG -fno-automatic")
set(CMAKE_Fortran_FLAGS_RELWITHDEBINFO "-fPIC -O2 -g -fno-automatic")


message(STATUS "PYTHIA8_INCLUDE_DIR == " ${PYTHIA8_INCLUDE_DIR} )

include_directories(${PYTHIA8_INCLUDE_DIR} ${PROJECT_SOURCE_DIR}/include
${PROJECT_SOURCE_DIR}/vinciaroot/include ${ROOT_INCLUDE_DIRS}
${FASTJET_INCLUDE_DIR} )
#---Select sources for the various libraries---------------------------------


file(GLOB MG_lib_files ${PROJECT_SOURCE_DIR}/MGInterface/HELAS/*.F  ${PROJECT_SOURCE_DIR}/MGInterface/HELAS/*.f)

file(GLOB vincia_lib_sources
    ${PROJECT_SOURCE_DIR}/src/*.cc
    ${PROJECT_SOURCE_DIR}/src/*.f
)

file(GLOB vincia_MGInterfaceDummy_sources MGInterface/VinciaMGInterfaceDummy.cc) 
file(GLOB vincia_MGInterface_sources MGInterface/VinciaMGInterface.cc
MGInterface/*.f MGInterface/*.F  )

file(GLOB vincia_root_sources vinciaroot/src/*)


add_library(dhelas3 STATIC ${MG_lib_files})

add_library(vincia SHARED ${vincia_lib_sources})

add_library(mginterfacedummy SHARED ${vincia_MGInterfaceDummy_sources} )

add_library(mginterface SHARED ${vincia_MGInterface_sources} )
target_link_libraries(mginterface dhelas3)

add_library(vinciaroot SHARED ${vincia_root_sources} )
target_link_libraries(vinciaroot ${ROOT_LIBRARIES})


#add_executable (Tutorial vincia01.cc)
#target_link_libraries (Tutorial  vincia_shared vincia_MG_shared ${PYTHIA8_LIBRARIES} )

file( GLOB APP_SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} vincia*.cc )
foreach( testsourcefile ${APP_SOURCES} )
    # I used a simple string replace, to cut off .cc.
    string( REPLACE ".cc" ".exe" testname ${testsourcefile} )
    add_executable( ${testname} ${testsourcefile} )
    target_link_libraries( ${testname} vincia dhelas3 mginterface
${PYTHIA8_LIBRARIES} ${ROOT_LIBRARIES} vinciaroot ${FASTJET_LIBRARIES} )
endforeach( testsourcefile ${APP_SOURCES} )

file( GLOB APP_EXEC RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} vincia*.exe )

#INSTALL_TARGETS(${CMAKE_INSTALL_PREFIX}/lib libvincia)
INSTALL_TARGETS(/lib vincia vinciaroot mginterfacedummy )
INSTALL_TARGETS(/bin/ ${APP_EXEC} )




