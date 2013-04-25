cmake_minimum_required(VERSION 2.8.5)

# Declare the version of HEP Tools we use
# (must be done before including heptools-common to allow evolution of the
# structure)
set(heptools_version  preview)

include(${CMAKE_CURRENT_LIST_DIR}/heptools-common.cmake)

# please keep alphabetic order and the structure (tabbing).
# it makes it much easier to edit/read this file!


# Application Area Projects
LCG_AA_project(COOL  COOL_2_8_17)
LCG_AA_project(CORAL CORAL_2_3_26)
LCG_AA_project(RELAX RELAX_1_3_0k)
LCG_AA_project(ROOT  5.34.05)
LCG_AA_project(LCGCMT LCGCMT_${heptools_version})

# Compilers
#LCG_compiler(gcc43 gcc 4.3.5)
#LCG_compiler(gcc46 gcc 4.6.2)
#LCG_compiler(gcc47 gcc 4.7.2)
#LCG_compiler(clang30 clang 3.0)
#LCG_compiler(gccmax gcc 4.7.2)

# Externals
LCG_external_package(4suite            1.0.2p1                                  )
LCG_external_package(AIDA              3.2.1                                    )
LCG_external_package(blas              20110419                                 )
LCG_external_package(Boost             1.50.0                                   )
LCG_external_package(CLHEP             1.9.4.7                   clhep          )
#LCG_external_package(cmake             2.8.9                                    )
LCG_external_package(cmaketools        1.0                                      )
#LCG_external_package(cmt               v1r20p20081118                           )
LCG_external_package(coin3d            3.1.3p2                                  )
LCG_external_package(coverage          3.5.2                                    )
LCG_external_package(CppUnit           1.12.1_p1                 author=1.12.1  )
LCG_external_package(cx_oracle         5.1.1                                    )
#LCG_external_package(dcache_client     2.47.6-1                                 ) deprecated due to Grid/dcap
#LCG_external_package(dcache_srm        1.9.5-23                                 ) deprecated due to Grid/dcap 
LCG_external_package(doxygen           1.8.2                                    ) 
LCG_external_package(Expat             2.0.1                     Expat          )
LCG_external_package(fastjet           3.0.3                                    )
LCG_external_package(fftw              3.1.2                     fftw3          )
LCG_external_package(Frontier_Client   2.8.5p1                   frontier_client)
LCG_external_package(GCCXML            0.9.0_20120309p1          gccxml         )
LCG_external_package(genshi            0.6                                      )
LCG_external_package(graphviz          2.28.0                                   )
LCG_external_package(GSL               1.10                                     )
LCG_external_package(HepMC             2.06.05                                  )
LCG_external_package(HepPDT            2.06.01                                  )
LCG_external_package(igprof            5.9.6                                    )
LCG_external_package(ipython           0.12.1                                   )
LCG_external_package(json              2.5.2                                    )
LCG_external_package(lapack            3.4.0                                    )
LCG_external_package(lcov              1.9                                      )
LCG_external_package(libsvm            2.86                                     )
LCG_external_package(libtool           1.5.26                                   )
LCG_external_package(libunwind         5c2cade                                  )
LCG_external_package(lxml              2.3                                      )
LCG_external_package(matplotlib        1.1.0                                    )
LCG_external_package(minuit            5.27.02                                  )
LCG_external_package(mock              0.8.0                                    )
LCG_external_package(multiprocessing   2.6.2.1                                  )
LCG_external_package(mysql             5.5.27                                   )
LCG_external_package(mysql_python      1.2.3                                    )
LCG_external_package(neurobayes        3.7.0                                    )
LCG_external_package(neurobayes_expert 3.7.0                                    )
LCG_external_package(nose              1.1.2                                    )
LCG_external_package(numpy             1.6.1                                    )
LCG_external_package(oracle            11.2.0.3.0                               )
LCG_external_package(processing        0.52                                     )
LCG_external_package(py                1.4.8                                    )
LCG_external_package(py2neo            1.4.6                                    )
LCG_external_package(pyanalysis        1.3                                      )
LCG_external_package(pydot             1.0.28                                   )
LCG_external_package(pygraphics        1.4                                      )
LCG_external_package(pygsi             0.5                                      )
LCG_external_package(pylint            0.26.0                                   )
LCG_external_package(pyminuit          0.0.1                                    )
LCG_external_package(pyparsing         1.5.6                                    )
LCG_external_package(pyqt              4.9.5                                    )
LCG_external_package(pytest            2.2.4                                    )
LCG_external_package(Python            2.7.3                                    )
LCG_external_package(pytools           1.8                                      )
LCG_external_package(pyxml             0.8.4p1                                  )
LCG_external_package(QMtest            2.4.1                                    )
LCG_external_package(Qt                4.8.4                     qt             )
LCG_external_package(qwt               6.0.1                                    )
LCG_external_package(scipy             0.10.0                                   )
LCG_external_package(setuptools        0.6c11                                   )
LCG_external_package(sip               4.14                                     )
LCG_external_package(soqt              1.5.0                                    )
LCG_external_package(sqlalchemy        0.7.7                                    )
LCG_external_package(sqlite            3070900                                  )
LCG_external_package(stomppy           3.1.3                                    )
LCG_external_package(storm             0.19                                     )
LCG_external_package(swig              1.3.40                                   )
LCG_external_package(sympy             0.7.1                                    )
LCG_external_package(tbb               41_20130116                              )
LCG_external_package(tcmalloc          1.7p3                                    )
if(NOT ${LCG_OS}${LCG_OS_VERS} STREQUAL slc6) # uuid is not distributed with SLC6
LCG_external_package(uuid              1.42                                     )
endif()
LCG_external_package(valgrind          3.8.0                                    )
LCG_external_package(vdt               0.3.2                                    )
LCG_external_package(XercesC           3.1.1p1        author=3.1.1              )
LCG_external_package(xqilla            2.2.4p1                                  )
LCG_external_package(xrootd            3.2.7                                    )

#---EMI-2 grid externals and other binary packages---------------------
if(NOT ${LCG_OS} STREQUAL mac)
  LCG_external_package(cream           1.14.0-4               Grid/cream        )
  LCG_external_package(dcap            2.47.7-1               Grid/dcap         )
  LCG_external_package(dm-util         1.15.0-0               Grid/dm-util      )
  LCG_external_package(dpm             1.8.5-1                Grid/DPM          )
  LCG_external_package(epel            20130408               Grid/epel         )
  LCG_external_package(FTS             2.2.8emi2              Grid/FTS          )
  LCG_external_package(FTS3            0.0.1-88               Grid/FTS3         )
  LCG_external_package(gfal            1.15.0-0               Grid/gfal         )
  LCG_external_package(gfal2           2.2.0-1                Grid/gfal2        )
  LCG_external_package(gridftp_ifce    2.3.1-0                Grid/gridftp-ifce )
  LCG_external_package(gridsite        1.7.25-1.emi2          Grid/gridsite     )
  LCG_external_package(is_ifce         1.15.0-0               Grid/is-ifce      )
  LCG_external_package(lb              3.2.9                  Grid/lb           )
  LCG_external_package(lcgdmcommon     1.8.5-1                Grid/lcg-dm-common)
  LCG_external_package(lcginfosites    3.1.0-3                Grid/lcg-infosites)
  LCG_external_package(lfc             1.8.5-1                Grid/LFC          )
  LCG_external_package(srm_ifce        1.15.2-1               Grid/srm-ifce     )
  LCG_external_package(voms            2.0.9-1                Grid/voms         )
  LCG_external_package(WMS             3.4.0                  Grid/WMS          )
endif()


#---Additional External packages------(Generators)-----------------
LCG_external_package(lhapdf            5.8.9          MCGenerators/lhapdf       )
LCG_external_package(pythia8           175            MCGenerators/pythia8      )
LCG_external_package(thepeg            1.8.2          MCGenerators/thepeg       )
LCG_external_package(herwig++          2.6.3          MCGenerators/herwig++     )
LCG_external_package(tauola++          1.1.1a         MCGenerators/tauola++     )
LCG_external_package(pythia6           427            MCGenerators/pythia6        author=6.4.27 hepevt=4000   )
LCG_external_package(pythia6           427.2          MCGenerators/pythia6        author=6.4.27 hepevt=10000  )
LCG_external_package(agile             1.4.0          MCGenerators/agile        )
LCG_external_package(photos++          3.52           MCGenerators/photos++     )
LCG_external_package(evtgen            1.1.0          MCGenerators/evtgen         tag=R01-01-00)
LCG_external_package(rivet             1.8.2          MCGenerators/rivet        )
LCG_external_package(sherpa            1.4.3          MCGenerators/sherpa         author=1.4.3 hepevt=4000  )
LCG_external_package(sherpa            1.4.3.2        MCGenerators/sherpa         author=1.4.3 hepevt=10000 )
LCG_external_package(hepmcanalysis     3.4.14         MCGenerators/hepmcanalysis  author=00-03-04-14        )
LCG_external_package(mctester          1.25.0         MCGenerators/mctester     )
LCG_external_package(hijing            1.383bs.2      MCGenerators/hijing       )
LCG_external_package(starlight         r43            MCGenerators/starlight    )
LCG_external_package(herwig            6.520          MCGenerators/herwig       )
LCG_external_package(herwig            6.520.2        MCGenerators/herwig       )
LCG_external_package(crmc              v3400          MCGenerators/crmc         )

# Prepare the search paths according to the versions above
LCG_prepare_paths()
