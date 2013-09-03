#---General parameters--------------------------------------------------------------------------------------------
set(Python_cmd ${Python_home}/bin/python)
set(PythonFW_cmd ${Python_home}/Library/Frameworks/Python.framework/Versions/Current/bin/python)
set(Exec_cmd ${CMAKE_SOURCE_DIR}/cmake/scripts/exec-with-env)

#=================================================================================================================
#---pyanalysis----------------------------------------------------------------------------------------------------
# This is only a placeholder where all the sub-packages will be installed
#=================================================================================================================
LCGPackage_set_home(pyanalysis)

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
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Exec_cmd} PYTHONPATH=${pyanalysis_home}/lib/python${Python_config_version_twodigit}/site-packages
                            BLAS=${blas_home}/lib/libBLAS.a LAPACK=${lapack_home}/lib/libLAPACK.a
                ${Python_cmd} setup.py build
  INSTALL_COMMAND ${Exec_cmd} PYTHONPATH=${pyanalysis_home}/lib/python${Python_config_version_twodigit}/site-packages
                              BLAS=${blas_home}/lib/libBLAS.a LAPACK=${lapack_home}/lib/libLAPACK.a
                  ${Python_cmd} setup.py install --prefix <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEST_NAME pyanalysis
  DEPENDS Python numpy blas lapack
)

#---sympy---------------------------------------------------------------------------------------------------------
LCGPackage_Add(
  sympy
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/sympy-${sympy_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Python_cmd} setup.py build
  INSTALL_COMMAND ${Python_cmd} setup.py install --prefix <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEST_NAME pyanalysis
  DEPENDS Python
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
LCGPackage_Add(
  pyanalysis
  DOWNLOAD_COMMAND <VOID>
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND <VOID>
  BUNDLE_PACKAGE 1
  DEPENDS matplotlib numpy scipy sympy pyminuit
)

#=================================================================================================================
#---pytools----------------------------------------------------------------------------------------------------
# This is only a placeholder where all the sub-packages will be installed
#=================================================================================================================
LCGPackage_set_home(pytools)

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
LCGPackage_Add(
  cx_oracle
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/cx_Oracle-${cx_oracle_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND  ${Exec_cmd} ORACLE_HOME=${oracle_home} ${Python_cmd} setup.py build
  INSTALL_COMMAND ${Exec_cmd} ORACLE_HOME=${oracle_home} ${Python_cmd} setup.py install --prefix <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEST_NAME pytools
  DEPENDS Python oracle
)

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
  BUILD_COMMAND ${CMAKE_COMMAND} -E  make_directory <INSTALL_DIR>/lib/python${Python_config_version_twodigit}/site-packages/
        COMMAND ${Python_cmd} setup.py build
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

#---py2neo---------------------------------------------------------------------------------------------------
LCGPackage_Add(
  py2neo
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/py2neo-${py2neo_native_version}.tar.gz
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

#---pytest------------------------------------------------------------------------------------------------------
LCGPackage_Add(
  pytest
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/pytest-${pytest_native_version}.zip
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Python_cmd} setup.py build
  INSTALL_COMMAND ${Exec_cmd} PYTHONPATH=${pytools_home}/lib/python${Python_config_version_twodigit}/site-packages
                  ${Python_cmd} setup.py install --prefix <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEST_NAME pytools
  DEPENDS Python
)

#---pylint------------------------------------------------------------------------------------------------------
LCGPackage_Add(
  pylint
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/pylint-${pylint_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Python_cmd} setup.py build
  INSTALL_COMMAND ${Exec_cmd} PYTHONPATH=${pytools_home}/lib/python${Python_config_version_twodigit}/site-packages
                  ${Python_cmd} setup.py install --prefix <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEST_NAME pytools
  DEPENDS Python
)

#---nose------------------------------------------------------------------------------------------------------
LCGPackage_Add(
  nose
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/nose-${nose_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Python_cmd} setup.py build
  INSTALL_COMMAND ${Exec_cmd} PYTHONPATH=${pytools_home}/lib/python${Python_config_version_twodigit}/site-packages
                  ${Python_cmd} setup.py install --prefix <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEST_NAME pytools
  DEPENDS Python
)

#---coverage------------------------------------------------------------------------------------------------------
LCGPackage_Add(
  coverage
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/coverage-${coverage_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Exec_cmd} PYTHONPATH=${pytools_home}/lib/python${Python_config_version_twodigit}/site-packages
                ${Python_cmd} setup.py build
  INSTALL_COMMAND ${Exec_cmd} PYTHONPATH=${pytools_home}/lib/python${Python_config_version_twodigit}/site-packages
                  ${Python_cmd} setup.py install --prefix <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEST_NAME pytools
  DEPENDS Python setuptools
)

#---stomppy------------------------------------------------------------------------------------------------------
LCGPackage_Add(
  stomppy
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/stomp.py-${stomppy_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Exec_cmd} PYTHONPATH=${pytools_home}/lib/python${Python_config_version_twodigit}/site-packages
                ${Python_cmd} setup.py build
  INSTALL_COMMAND ${Exec_cmd} PYTHONPATH=${pytools_home}/lib/python${Python_config_version_twodigit}/site-packages
                  ${Python_cmd} setup.py install --prefix <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEST_NAME pytools
  DEPENDS Python
)


LCGPackage_Add(
  pytools
  DOWNLOAD_COMMAND <VOID>
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND <VOID>
  BUNDLE_PACKAGE 1
  DEPENDS lxml sqlalchemy genshi 4suite cx_oracle ipython json mock multiprocessing setuptools mysql_python processing py py2neo pyxml storm pytest pylint nose coverage stomppy
)

#=================================================================================================================
#---pygraphics----------------------------------------------------------------------------------------------------
# This is a bundle where all the sub-packages will be installed
# First we define all sub-packages and in the end the master-package
#=================================================================================================================
LCGPackage_set_home(pygraphics)

#---pydot------------------------------------------------------------------------------------------------------
LCGPackage_Add(
  pydot
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/pydot-${pydot_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Python_cmd} setup.py build
  INSTALL_COMMAND ${Python_cmd} setup.py install --prefix <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEST_NAME pygraphics
  DEPENDS Python
)

#---pyparsing------------------------------------------------------------------------------------------------------
LCGPackage_Add(
  pyparsing
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/pyparsing-${pyparsing_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Python_cmd} setup.py build
  INSTALL_COMMAND ${Python_cmd} setup.py install --prefix <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEST_NAME pygraphics
  DEPENDS Python
)

#---sip------------------------------------------------------------------------------------------------------
if(LCG_TARGET MATCHES i386-mac)
  set(sip_compile_options -p darwin-g++ CFLAGS=-m32 CXXFLAGS=-m32 CC=gcc CXX=g++ LINK=g++)
elseif(LCG_TARGET MATCHES x86_64-mac)
  set(sip_compile_options --arch=x86_64)
elseif(LCG_TARGET MATCHES slc|ubuntu AND LCG_TARGET MATCHES x86_64)
  set(sip_compile_options -p linux-g++-64)
elseif(LCG_TARGET MATCHES slc|ubuntu AND LCG_TARGET MATCHES i686)
  set(sip_compile_options -p linux-g++-64)
endif()
if (APPLE) 
  set (Python_cmd_sip ${PythonFW_cmd})
else()
  set (Python_cmd_sip ${Python_cmd})
endif()
LCGPackage_Add(
  sip
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/sip-${sip_native_version}.tar.gz
  CONFIGURE_COMMAND ${Python_cmd_sip} configure.py -b <INSTALL_DIR>/bin 
                                               -d <INSTALL_DIR>/lib/python${Python_config_version_twodigit}/site-packages 
                                               -e <INSTALL_DIR>/include/python${Python_config_version_twodigit} 
                                               -v ${sip_home}/share/sip ${sip_compile_options}
  BUILD_IN_SOURCE 1
  DEST_NAME pygraphics
  DEPENDS Python
)
#---pyqt------------------------------------------------------------------------------------------------------
if(APPLE)
  set(pyqt_platform x11)
else()
  set(pyqt_platform mac)
endif()
LCGPackage_Add(
  pyqt
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/PyQt-${pyqt_platform}-gpl-${pyqt_native_version}.tar.gz
  CONFIGURE_COMMAND ${Exec_cmd} PYTHONPATH=${pygraphics_home}/lib/python${Python_config_version_twodigit}/site-packages
                    ${PythonFW_cmd} configure.py -b <INSTALL_DIR>/bin
                                               -d <INSTALL_DIR>/lib/python${Python_config_version_twodigit}/site-packages
                                               -l ${Python_home}/include/python${Python_config_version_twodigit} 
                                               -m ${Python_home}/lib/python${Python_config_version_twodigit}/config
                                               -q ${Qt_home}/bin/qmake 
                                               -v <INSTALL_DIR>/share/sip/PyQt4
                                               -p <INSTALL_DIR>/plugins --verbose --confirm-license

  BUILD_IN_SOURCE 1
  DEST_NAME pygraphics
  DEPENDS Python Qt sip
)

LCGPackage_Add(
  pygraphics
  DOWNLOAD_COMMAND <VOID>
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND <VOID>
  BUNDLE_PACKAGE 1
  DEPENDS pydot pyparsing sip pyqt
)

#---libsvm------------------------------------------------------------------------------------------------------
LCGPackage_Add(
  libsvm
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/libsvm-${libsvm_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND make
        COMMAND make PYTHON_INCLUDEDIR=${Python_home}/include/python${Python_config_version_twodigit} 
                     -C python all LDFLAGS=\ -shared\ -L${Python_home}/lib\ -lpython${Python_config_version_twodigit}
  INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory <INSTALL_DIR>/bin
          COMMAND cp svm-train svm-predict svm-scale <INSTALL_DIR>/bin
          COMMAND ${CMAKE_COMMAND} -E make_directory <INSTALL_DIR>/include
          COMMAND ${CMAKE_COMMAND} -E copy svm.h <INSTALL_DIR>/include
          COMMAND ${CMAKE_COMMAND} -E make_directory <INSTALL_DIR>/src
          COMMAND ${CMAKE_COMMAND} -E copy svm.cpp <INSTALL_DIR>/src
          COMMAND ${CMAKE_COMMAND} -E make_directory <INSTALL_DIR>/python
          COMMAND cp python/svmc.so python/svm.py python/svm_test.py python/README <INSTALL_DIR>/python
          COMMAND cp -r README tools <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEPENDS Python 
)

#---minuit------------------------------------------------------------------------------------------------------
LCGPackage_Add(
  minuit
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/Minuit2-${minuit_native_version}.tar.gz
  CONFIGURE_COMMAND ./configure --prefix <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEPENDS Python pyanalysis
)

#---pygsi-------------------------------------------------------------------------------------------------------
LCGPackage_Add(
  pygsi
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/pygsi-${pygsi_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND   ${Exec_cmd} PYTHONPATH=${pytools_home}/lib/python${Python_config_version_twodigit}/site-packages
                  ${Python_cmd} setup.py build
  INSTALL_COMMAND mkdir -p <INSTALL_DIR>/lib/python${Python_config_version_twodigit}/site-packages/
          COMMAND ${Exec_cmd} PYTHONPATH=${pytools_home}/lib/python${Python_config_version_twodigit}/site-packages:<INSTALL_DIR>/lib/python${Python_config_version_twodigit}/site-packages ${Python_cmd} setup.py install --prefix <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEPENDS Python pytools
)




