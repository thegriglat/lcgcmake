# - Locate Boost library
# Defines:
#
#  BOOST_FOUND
#  BOOST_INCLUDE_DIR
#  BOOST_INCLUDE_DIRS (not cached)
#  BOOST_LIBRARY
#  BOOST_LIBRARIES (not cached)

#Find include dir. Complicated because of insufficient functionality of "find_path"
file(GLOB SUBDIRS1 $ENV{BOOST_ROOT_DIR}/include/*)
file(GLOB SUBDIRS2 ${BOOST_ROOT_DIR}/include/*)
find_path(BOOST_INCLUDE_DIR /boost/aligned_storage.hpp 
          HINTS $ENV{BOOST_ROOT_DIR}/include ${BOOST_ROOT_DIR}/include
          ${SUBDIRS1} ${SUBDIRS2} NO_DEFAULT_PATH)

#The same for finding libraries with platform-dependent names
file(GLOB LIB1PRE ${BOOST_ROOT_DIR}/lib/libboost_filesystem*)
#this below will work only for gcc compiler
string(REGEX MATCH boost_filesystem.............. LIB1 ${LIB1PRE})
find_library(BOOST_LIBRARY1 NAMES ${LIB1}
             HINTS $ENV{BOOST_ROOT_DIR}/lib ${BOOST_ROOT_DIR}/lib)

file(GLOB LIB2PRE ${BOOST_ROOT_DIR}/lib/libboost_system*)
#this below will work only for gcc compiler
string(REGEX MATCH boost_system.............. LIB2 ${LIB2PRE})
find_library(BOOST_LIBRARY2 NAMES ${LIB2}
             HINTS $ENV{BOOST_ROOT_DIR}/lib ${BOOST_ROOT_DIR}/lib)

set(BOOST_LIBRARIES ${BOOST_LIBRARY1} ${BOOST_LIBRARY2})

set(BOOST_INCLUDE_DIRS ${BOOST_INCLUDE_DIR})

# handle the QUIETLY and REQUIRED arguments and set BOOST_FOUND to TRUE if
# all listed variables are TRUE
INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(BOOST DEFAULT_MSG BOOST_INCLUDE_DIRS BOOST_LIBRARIES)

mark_as_advanced(BOOST_FOUND BOOST_INCLUDE_DIRS BOOST_LIBRARIES)
