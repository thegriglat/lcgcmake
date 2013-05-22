# - Locate pythia6 library
# Defines:
#
#  PHOTOSPP_FOUND
#  PHOTOSPP_INCLUDE_DIR
#  PHOTOSPP_INCLUDE_DIRS (not cached)
#  PHOTOSPP_LIBRARY
#  PHOTOSPP_LIBRARIES (not cached)


find_path(PHOTOSPP_INCLUDE_DIR Log.h
          HINTS $ENV{PHOTOS++_ROOT_DIR}/include ${PHOTOSPP_ROOT_DIR}/include)

find_library(PHOTOSPP_LIBRARY NAMES photos++
             HINTS $ENV{PHOTOSPP_ROOT_DIR}/lib ${PHOTOSPP_ROOT_DIR}/lib)

set(PHOTOSPP_INCLUDE_DIRS ${PHOTOSPP_INCLUDE_DIR})
set(PHOTOSPP_LIBRARIES ${PHOTOSPP_LIBRARY})

# handle the QUIETLY and REQUIRED arguments and set PHOTOS_FOUND to TRUE if
# all listed variables are TRUE

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(Photos++ DEFAULT_MSG PHOTOSPP_INCLUDE_DIR  PHOTOSPP_LIBRARY)

mark_as_advanced(PHOTOSPP_FOUND PHOTOSPP_INCLUDE_DIR PHOTOSPP_LIBRARY)