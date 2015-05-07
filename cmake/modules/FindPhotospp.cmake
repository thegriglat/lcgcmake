# - Try to find PHOTOSPP
# Defines:
#
#  PHOTOSPP_FOUND
#  PHOTOSPP_INCLUDE_DIR
#  PHOTOSPP_INCLUDE_DIRS (not cached)
#  PHOTOSPP_<component>_LIBRARY
#  PHOTOSPP_<component>_FOUND
#  PHOTOSPP_LIBRARIES (not cached)
#  PHOTOSPP_LIBRARY_DIRS (not cached)

# Enforce a minimal list if none is explicitly requested
list (APPEND t "Fortran CxxInterface")
list(APPEND t "pp ppHepMC ppHEPEVT")
foreach (PHOTOSPP_FIND_COMPONENTS ${t})
  STRING(REPLACE " " ";" PHOTOSPP_FIND_COMPONENTS "${PHOTOSPP_FIND_COMPONENTS}")
  message ("a = ${PHOTOSPP_FIND_COMPONENTS}")
foreach(component ${PHOTOSPP_FIND_COMPONENTS})
  message ("comp = ${component}")
  find_library(PHOTOSPP_${component}_LIBRARY NAMES Photos${component}
               HINTS ${PHOTOSPP_ROOT_DIR}/lib
                     $ENV{PHOTOSPP_ROOT_DIR}/lib
                     ${PHOTOSPP_ROOT_DIR}/lib)
  if (PHOTOSPP_${component}_LIBRARY)
    set(PHOTOSPP_${component}_FOUND 1)
    list(APPEND PHOTOSPP_LIBRARIES ${PHOTOSPP_${component}_LIBRARY})

    get_filename_component(libdir ${PHOTOSPP_${component}_LIBRARY} PATH)
    list(APPEND PHOTOSPP_LIBRARY_DIRS ${libdir})
  else()
    set(PHOTOSPP_${component}_FOUND 0)
  endif()
  mark_as_advanced(PHOTOSPP_${component}_LIBRARY)
  mark_as_advanced(PHOTOSPP_LIBRARIES)
endforeach()

if(PHOTOSPP_LIBRARY_DIRS)
  list(REMOVE_DUPLICATES PHOTOSPP_LIBRARY_DIRS)
endif()

find_path(PHOTOSPP_INCLUDE_DIR Photos/Photos.h
          HINTS ${PHOTOSPP_ROOT_DIR}/include
                $ENV{PHOTOSPP_ROOT_DIR}/include
                ${PHOTOSPP_ROOT_DIR}/include)
set(PHOTOSPP_INCLUDE_DIRS ${PHOTOSPP_INCLUDE_DIR})
mark_as_advanced(PHOTOSPP_INCLUDE_DIR)

# handle the QUIETLY and REQUIRED arguments and set PHOTOSPP_FOUND to TRUE if
# all listed variables are TRUE
include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(PHOTOSPP DEFAULT_MSG PHOTOSPP_INCLUDE_DIR PHOTOSPP_LIBRARIES)
if (PHOTOSPP_FOUND)
  break()
endif()
endforeach()
mark_as_advanced(PHOTOSPP_FOUND)
