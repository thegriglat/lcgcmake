# Install the  version.txt file into the <INSTALL_DIR> area
# Parameters:
#    INSTALL_DIR Installation prefix
#   FULL_VERSION    Full version string

file(WRITE ${INSTALL_DIR}/version.txt ${FULL_VERSION} "\n")


