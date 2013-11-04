# - Locate pythia6 library
# Defines:
#
#  PYTHIA8_FOUND
#  PYTHIA8_VERSION_CHECK (takes values NEW (v >= 177) or OLD)
#  PYTHIA8_INCLUDE_DIR
#  PYTHIA8_INCLUDE_DIRS (not cached)
#  PYTHIA8_LIBRARY
#  PYTHIA8_hepmcinterface_LIBRARY
#  PYTHIA8_lhapdfdummy_LIBRARY
#  PYTHIA8_LIBRARIES (not cached) : includes 3 libraries above; not to be used if lhapdf is used


find_path(PYTHIA8_INCLUDE_DIR_NEW Pythia8/Pythia.h
          HINTS $ENV{PYTHIA8_ROOT_DIR}/include ${PYTHIA8_ROOT_DIR}/include)

find_path(PYTHIA8_INCLUDE_DIR Pythia.h
          HINTS $ENV{PYTHIA8_ROOT_DIR}/include ${PYTHIA8_ROOT_DIR}/include)

set(PYTHIA8_VERSION_CHECK OLD)

if(${PYTHIA8_INCLUDE_DIR} STREQUAL "PYTHIA8_INCLUDE_DIR-NOTFOUND")
  if(NOT ${PYTHIA8_INCLUDE_DIR_NEW} STREQUAL "PYTHIA8_INCLUDE_DIR_NEW-NOTFOUND")
    set(PYTHIA8_INCLUDE_DIR ${PYTHIA8_INCLUDE_DIR_NEW})
    set(PYTHIA8_VERSION_CHECK NEW)
  endif()
endif()

find_library(PYTHIA8_LIBRARY NAMES pythia8 Pythia8
             HINTS $ENV{PYTHIA8_ROOT_DIR}/lib ${PYTHIA8_ROOT_DIR}/lib)

if(${PYTHIA8_VERSION_CHECK} STREQUAL "OLD")
  find_library(PYTHIA8_hepmcinterface_LIBRARY NAMES hepmcinterface
               HINTS $ENV{PYTHIA8_ROOT_DIR}/lib ${PYTHIA8_ROOT_DIR}/lib)
endif()
if(${PYTHIA8_VERSION_CHECK} STREQUAL "NEW")
  find_library(PYTHIA8_hepmcinterface_LIBRARY NAMES pythia8tohepmc
               HINTS $ENV{PYTHIA8_ROOT_DIR}/lib ${PYTHIA8_ROOT_DIR}/lib)
endif()

find_library(PYTHIA8_lhapdfdummy_LIBRARY NAMES lhapdfdummy
             HINTS $ENV{PYTHIA8_ROOT_DIR}/lib ${PYTHIA8_ROOT_DIR}/lib)

set(PYTHIA8_INCLUDE_DIRS ${PYTHIA8_INCLUDE_DIR})
set(PYTHIA8_LIBRARIES ${PYTHIA8_LIBRARY} ${PYTHIA8_hepmcinterface_LIBRARY} ${PYTHIA8_lhapdfdummy_LIBRARY})

# handle the QUIETLY and REQUIRED arguments and set PYTHIA8_FOUND to TRUE if
# all listed variables are TRUE

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(Pythia8 DEFAULT_MSG PYTHIA8_INCLUDE_DIR PYTHIA8_LIBRARY PYTHIA8_hepmcinterface_LIBRARY PYTHIA8_lhapdfdummy_LIBRARY PYTHIA8_VERSION_CHECK)

mark_as_advanced(PYTHIA8_FOUND PYTHIA8_INCLUDE_DIR PYTHIA8_LIBRARY PYTHIA8_hepmcinterface_LIBRARY PYTHIA8_lhapdfdummy_LIBRARY PYTHIA8_VERSION_CHECK)
