# Strip the debug symbols from all .so files in the given dir
# Parameters:
#    INSTALL_DIR Installation prefix

cmake_policy(SET CMP0009 NEW) # FILE GLOB_RECURSE calls should not follow symlinks by default

file(GLOB_RECURSE sharedlibs ${INSTALL_DIR}/*.so ${INSTALL_DIR}/*.dylib)
foreach(file ${sharedlibs})
  if(NOT APPLE)
    execute_process(COMMAND stat -c "%a" "${file}" OUTPUT_VARIABLE permissions)
    string(REGEX REPLACE "(\r?\n)+$" "" permissions "${permissions}")
    execute_process(COMMAND chmod ugo+wx "${file}")
    execute_process(COMMAND strip "${file}")
    execute_process(COMMAND chmod ${permissions} "${file}")
  endif()
  if(APPLE)
    execute_process(COMMAND strip -S "${file}")
  endif()
endforeach()
