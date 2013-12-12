# Strip the rpath from all .so files in the given dir
# Parameters:
#    INSTALL_DIR Installation prefix

cmake_policy(SET CMP0009 NEW) # FILE GLOB_RECURSE calls should not follow symlinks by default

file(GLOB_RECURSE sharedlibs ${INSTALL_DIR}/*.so ${INSTALL_DIR}/bin/*)
foreach(file ${sharedlibs})
  if(NOT APPLE)
    execute_process(COMMAND stat -c "%a" "${file}" OUTPUT_VARIABLE permissions)
    string(REGEX REPLACE "(\r?\n)+$" "" permissions "${permissions}")
    execute_process(COMMAND chmod ugo+wx "${file}")
    set (check_rpath 0)
    execute_process(COMMAND ${CMAKE_SOURCE_DIR}/check_relative_rpath.sh "${file}" RESULT_VARIABLE check_rpath)
    if (check_rpath)
        file(RPATH_REMOVE FILE "${file}")
    endif()
    execute_process(COMMAND chmod ${permissions} "${file}")
  endif()
endforeach()

