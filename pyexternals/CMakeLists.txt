#---General parameters--------------------------------------------------------------------------------------------
set(Python_cmd ${Python_home}/bin/python)

#---pyanalysis--------------------------------------------------------------------------------------------------
# This is only a place holder where all the sub-packages will be installed
LCGPackage_Add(
  pyanalysis
  DOWNLOAD_COMMAND <VOID>
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND <VOID>
  DEPENDS Python
)

#---numpy---------------------------------------------------------------------------------------------------------
LCGPackage_Add(
  numpy
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/numpy-${numpy_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Python_cmd} setup.py build
  INSTALL_COMMAND ${Python_cmd} setup.py install --prefix ${pyanalysis_home}
  BUILD_IN_SOURCE 1
  DEPENDS pyanalysis
)

#---numpy---------------------------------------------------------------------------------------------------------
LCGPackage_Add(
  scipy
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/scipy-${scipy_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND export PYTHONPATH=${pyanalysis_home}/lib/python${Python_config_version_twodigit}/site-packages  
        COMMAND ${Python_cmd} setup.py build
  INSTALL_COMMAND ${Python_cmd} setup.py install --prefix ${pyanalysis_home}
  BUILD_IN_SOURCE 1
  DEPENDS pyanalysis
)

