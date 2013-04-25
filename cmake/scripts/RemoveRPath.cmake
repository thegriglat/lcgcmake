# Strip the rpath from all .so files in the given dir
# Parameters:
#    INSTALL_DIR Installation prefix

file(GLOB_RECURSE sharedlibs ${INSTALL_DIR}/*.so)
foreach(file ${sharedlibs})
  if(NOT APPLE)
    execute_process(COMMAND stat -c "%a" "${file}" OUTPUT_VARIABLE permissions)
    string(REGEX REPLACE "(\r?\n)+$" "" permissions "${permissions}")
    execute_process(COMMAND chmod ugo+wx "${file}")
    file(RPATH_REMOVE FILE "${file}")
    execute_process(COMMAND chmod ${permissions} "${file}")
  endif()
endforeach()

