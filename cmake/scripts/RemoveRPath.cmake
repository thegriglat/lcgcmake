# Strip the rpath from all .so files in the given dir
# Parameters:
#    INSTALL_DIR Installation prefix

file(GLOB_RECURSE sharedlibs ${INSTALL_DIR}/*.so)
foreach(file ${sharedlibs})
  file(RPATH_REMOVE FILE "${file}" )
endforeach()

