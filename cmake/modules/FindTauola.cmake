# - Locate tauola library
# Defines:
#
#  TAUOLA_FOUND
#  TAUOLA_INCLUDE_DIR
#  TAUOLA_INCLUDE_DIRS (not cached)
#  TAUOLA_LIBRARY
#  TAUOLA_LIBRARIES (not cached)


find_path(TAUOLA_INCLUDE_DIR hepevt.inc
          HINTS $ENV{TAUOLA_ROOT_DIR}/include ${TAUOLA_ROOT_DIR}/include)

find_library(TAUOLA_LIBRARY NAMES tauola
             HINTS $ENV{TAUOLA_ROOT_DIR}/lib ${TAUOLA_ROOT_DIR}/lib)

set(TAUOLA_INCLUDE_DIRS ${TAUOLA_INCLUDE_DIR})
set(TAUOLA_LIBRARIES ${TAUOLA_LIBRARY})

# handle the QUIETLY and REQUIRED arguments and set TAUOLA_FOUND to TRUE if
# all listed variables are TRUE

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(tauola DEFAULT_MSG TAUOLA_INCLUDE_DIR TAUOLA_LIBRARY)

mark_as_advanced(TAUOLA_FOUND TAUOLA_INCLUDE_DIR TAUOLA_LIBRARY)
