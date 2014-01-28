# Install the  version.txt file into the <INSTALL_DIR> area
# Parameters:
#   NAME the file will be called buildinfo_<name>.txt
#   INSTALL_DIR Installation prefix
#   BUILDINFO    build info

file(WRITE ${INSTALL_DIR}/.buildinfo_${NAME}.txt ${BUILDINFO} "\n")


