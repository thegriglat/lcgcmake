# Strip the rpath from all .so files in the given dir
# Parameters:
#    INSTALL_DIR Installation prefix

file(GLOB_RECURSE libraries ${INSTALL_DIR} *.so)

foreach(file ${libraries})
  file(RPATH_REMOVE FILE "${file}" )
endforeach()

