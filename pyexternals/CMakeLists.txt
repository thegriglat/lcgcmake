#---General parameters--------------------------------------------------------------------------------------------
set(Python_cmd ${Python_home}/bin/python)
set(Exec_cmd ${CMAKE_SOURCE_DIR}/cmake/scripts/exec-with-env)

#=================================================================================================================
#---pyanalysis----------------------------------------------------------------------------------------------------
# This is only a placeholder where all the sub-packages will be installed
#=================================================================================================================
LCGPackage_Add(
  pyanalysis
  DOWNLOAD_COMMAND <VOID>
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND <VOID>
)

#---numpy---------------------------------------------------------------------------------------------------------
LCGPackage_Add(
  numpy
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/numpy-${numpy_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Python_cmd} setup.py build
  INSTALL_COMMAND ${Python_cmd} setup.py install --prefix <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEST_NAME pyanalysis
  DEPENDS Python
)

#---scipy---------------------------------------------------------------------------------------------------------
LCGPackage_Add(
  scipy
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/scipy-${scipy_native_version}.tar.gz
  PATCH_COMMAND patch -p0 -i ${CMAKE_CURRENT_SOURCE_DIR}/scipy-${scipy_native_version}.patch
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Exec_cmd} PYTHONPATH=${pyanalysis_home}/lib/python${Python_config_version_twodigit}/site-packages
                            BLAS=${blas_home}/lib/libBLAS.a
                ${Python_cmd} setup.py build
  INSTALL_COMMAND ${Exec_cmd} PYTHONPATH=${pyanalysis_home}/lib/python${Python_config_version_twodigit}/site-packages
                  ${Python_cmd} setup.py install --prefix <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEST_NAME pyanalysis
  DEPENDS Python numpy blas
)

#---matplotlib----------------------------------------------------------------------------------------------------
LCGPackage_Add(
  matplotlib
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/matplotlib-${matplotlib_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Exec_cmd} PYTHONPATH=${pyanalysis_home}/lib/python${Python_config_version_twodigit}/site-packages 
                ${Python_cmd} setup.py build
  INSTALL_COMMAND ${Exec_cmd} PYTHONPATH=${pyanalysis_home}/lib/python${Python_config_version_twodigit}/site-packages 
                  ${Python_cmd} setup.py install --prefix <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEST_NAME pyanalysis
  DEPENDS Python numpy
)

#---pyminuit---------------------------------------------------------------------------------------------------------
LCGPackage_Add(
  pyminuit
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/pyminuit2-${pyminuit_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Exec_cmd} PATH=${ROOT_home}/bin:$ENV{PATH} ${Python_cmd} setup.py build
  INSTALL_COMMAND ${Python_cmd} setup.py install --prefix <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEST_NAME pyanalysis
  DEPENDS Python ROOT
)

#---Add the dependencies now----------------------------------------------------------------------------------------
add_dependencies(pyanalysis matplotlib numpy scipy pyminuit)


#=================================================================================================================
#---pytools----------------------------------------------------------------------------------------------------
# This is only a placeholder where all the sub-packages will be installed
#=================================================================================================================
LCGPackage_Add(
  pytools
  DOWNLOAD_COMMAND <VOID>
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND <VOID>
)

#LXML 2.2.7 NEW!
#SQLALCHEMY 0.6.3
#GENSHI 0.6.3
#4SUITE 1.0.2P1
#CX_ORACLE 5.0.1
#IPYTHON 0.8.4
#JSON 2.1.1
#MOCK 0.6.0
#MULTIPROCESSING 2.6.1
#MYSQL_PYTHON 1.2.2
#PROCESSING 0.51
#PY 1.2.1
#PYXML 0.84P1
#SETUPTOOLS 06C11
#STORM 0.16.0

#---lxml---------------------------------------------------------------------------------------------------------
LCGPackage_Add(
  lxml
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/lxml-${lxml_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Python_cmd} setup.py build
  INSTALL_COMMAND ${Python_cmd} setup.py install --prefix <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEST_NAME pytools
  DEPENDS Python
)

#---sqlarchemy---------------------------------------------------------------------------------------------------
LCGPackage_Add(
  sqlalchemy
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/SQLAlchemy-${sqlalchemy_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Python_cmd} setup.py build
  INSTALL_COMMAND ${Python_cmd} setup.py install --prefix <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEST_NAME pytools
  DEPENDS Python
)

#---genshi------------------------------------------------------------------------------------------------------
LCGPackage_Add(
  genshi
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/Genshi-${genshi_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Python_cmd} setup.py build
  INSTALL_COMMAND ${Python_cmd} setup.py install --prefix <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEST_NAME pytools
  DEPENDS Python
)

#---4suite------------------------------------------------------------------------------------------------------
LCGPackage_Add(
  4suite
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/4Suite-XML-${4suite_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Python_cmd} setup.py build
  INSTALL_COMMAND ${Python_cmd} setup.py install --prefix <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEST_NAME pytools
  DEPENDS Python
)

#---cx_oracle------------------------------------------------------------------------------------------------------
if(FALSE)
  LCGPackage_Add(
    cx_oracle
    URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/cx_Oracle-${cx_oracle_native_version}.tar.gz
    CONFIGURE_COMMAND <VOID>
    BUILD_COMMAND ${Python_cmd} setup.py build
    INSTALL_COMMAND ${Python_cmd} setup.py install --prefix <INSTALL_DIR>
    BUILD_IN_SOURCE 1
    DEST_NAME pytools
    DEPENDS Python
  )
  set(cx_oracle_pkg cx_oracle)
endif()

#---ipython------------------------------------------------------------------------------------------------------
LCGPackage_Add(
  ipython
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/ipython-${ipython_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Python_cmd} setup.py build
  INSTALL_COMMAND ${Python_cmd} setup.py install --prefix <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEST_NAME pytools
  DEPENDS Python
)

#---json------------------------------------------------------------------------------------------------------
LCGPackage_Add(
  json
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/simplejson-${json_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Python_cmd} setup.py build
  INSTALL_COMMAND ${Python_cmd} setup.py install --prefix <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEST_NAME pytools
  DEPENDS Python
)

#---mock------------------------------------------------------------------------------------------------------
LCGPackage_Add(
  mock
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/mock-${mock_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Python_cmd} setup.py build
  INSTALL_COMMAND ${Python_cmd} setup.py install --prefix <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEST_NAME pytools
  DEPENDS Python
)

#---multiprocessing------------------------------------------------------------------------------------------------------
LCGPackage_Add(
  multiprocessing
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/multiprocessing-${multiprocessing_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Python_cmd} setup.py build
  INSTALL_COMMAND ${Python_cmd} setup.py install --prefix <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEST_NAME pytools
  DEPENDS Python
)

#---setuptools------------------------------------------------------------------------------------------------------
LCGPackage_Add(
  setuptools
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/setuptools-${setuptools_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Python_cmd} setup.py build
  INSTALL_COMMAND ${Exec_cmd} PYTHONPATH=${pytools_home}/lib/python${Python_config_version_twodigit}/site-packages
                  ${Python_cmd} setup.py install --prefix <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEST_NAME pytools
  DEPENDS Python
)

#---mysql_python------------------------------------------------------------------------------------------------------
LCGPackage_Add(
  mysql_python
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/MySQL-python-${mysql_python_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Exec_cmd} PATH=${mysql_home}/bin:$ENV{PATH} 
                            PYTHONPATH=${pytools_home}/lib/python${Python_config_version_twodigit}/site-packages
                ${Python_cmd} setup.py build
  INSTALL_COMMAND ${Exec_cmd} PATH=${mysql_home}/bin:$ENV{PATH} 
                              PYTHONPATH=${pytools_home}/lib/python${Python_config_version_twodigit}/site-packages
                  ${Python_cmd} setup.py install --prefix <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEST_NAME pytools 
  DEPENDS Python setuptools mysql
)

#---processing------------------------------------------------------------------------------------------------------
LCGPackage_Add(
  processing
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/processing-${processing_native_version}.zip
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Python_cmd} setup.py build
  INSTALL_COMMAND ${Python_cmd} setup.py install --prefix <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEST_NAME pytools
  DEPENDS Python
)

#---py------------------------------------------------------------------------------------------------------
LCGPackage_Add(
  py
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/py-${py_native_version}.zip
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Python_cmd} setup.py build
  INSTALL_COMMAND ${Exec_cmd} PYTHONPATH=${pytools_home}/lib/python${Python_config_version_twodigit}/site-packages
                              ${Python_cmd} setup.py install --prefix <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEST_NAME pytools
  DEPENDS Python
)

#---pyxml------------------------------------------------------------------------------------------------------
LCGPackage_Add(
  pyxml
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/PyXML-${pyxml_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Python_cmd} setup.py build
  INSTALL_COMMAND ${Python_cmd} setup.py install --prefix <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEST_NAME pytools
  DEPENDS Python
)

#---strom------------------------------------------------------------------------------------------------------
LCGPackage_Add(
  storm
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/storm-${storm_native_version}.tar.bz2
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Python_cmd} setup.py build
  INSTALL_COMMAND ${Python_cmd} setup.py install --prefix <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEST_NAME pytools
  DEPENDS Python
)

#---Add the dependencies now----------------------------------------------------------------------------------------
add_dependencies(pytools lxml sqlalchemy genshi 4suite ${cx_oracle_pkg} ipython json mock multiprocessing mysql_python processing py pyxml storm)


