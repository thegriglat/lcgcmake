cmake_minimum_required(VERSION 2.8.5)

# Declare the version of HEP Tools we use
# (must be done before including heptools-common to allow evolution of the
# structure)
set(heptools_version  64b)

include(${CMAKE_CURRENT_LIST_DIR}/heptools-common.cmake)

# please keep alphabetic order and the structure (tabbing).
# it makes it much easier to edit/read this file!


# Application Area Projects
LCG_AA_project(COOL  COOL_2_8_15)
LCG_AA_project(CORAL CORAL_2_3_24)
LCG_AA_project(RELAX RELAX_1_3_0i)
LCG_AA_project(ROOT  5.34.05)

# Compilers
#LCG_compiler(gcc42 gcc 4.2.1)
#LCG_compiler(gcc43 gcc 4.3.6)
#LCG_compiler(gcc46 gcc 4.6.2)
#LCG_compiler(gcc47 gcc 4.7.2)
#LCG_compiler(clang30 clang 3.0)
#LCG_compiler(clang31 clang 3.1)
#LCG_compiler(gccmax gcc 4.7.2)

# Externals
LCG_external_package(4suite            1.0.2p1                                  )
LCG_external_package(AIDA              3.2.1                                    )
LCG_external_package(bjam              3.1.13                                   )
LCG_external_package(blas              20110419                                 )
if(${LCG_COMP}${LCG_COMPVERS} STREQUAL "gccmax" OR LCG_SYSTEM MATCHES "-slc6-")
LCG_external_package(Boost             1.48.0p1                                 )
else()
LCG_external_package(Boost             1.48.0                                   )
endif()
LCG_external_package(bz2lib            1.0.2                                    )
if(NOT APPLE)
LCG_external_package(CASTOR            2.1.9-9                   castor         )
else()
LCG_external_package(CASTOR            2.1.9-4                   castor         )
endif()
LCG_external_package(cernlib           2006a                                    )
LCG_external_package(cgsigsoap         1.3.3-1                                  )
LCG_external_package(CLHEP             1.9.4.7                   clhep          )
LCG_external_package(cmake             2.8.6                                    )
LCG_external_package(cmaketools        1.0                                      )
LCG_external_package(cmt               v1r20p20081118                           )
LCG_external_package(coin3d            3.1.3p2                                  )
LCG_external_package(coverage          3.5.2                                    )
LCG_external_package(CppUnit           1.12.1_p1                                )
LCG_external_package(cx_oracle         5.1.1                                    )
LCG_external_package(david             1_36a                                    )
LCG_external_package(dawn              3_88a                                    )
if(LCG_SYSTEM MATCHES "-slc5-")
LCG_external_package(dcache_client     2.47.5-0                                 )
else()
LCG_external_package(dcache_client     2.47.6-1                                 )
endif()
LCG_external_package(dcache_srm        1.9.5-23                                 )
LCG_external_package(doxygen           1.7.6                                    )
LCG_external_package(dpm               1.7.4-7sec                               )
LCG_external_package(Expat             2.0.1                                    )
LCG_external_package(fastjet           3.0.3                                    )
if(NOT APPLE)
LCG_external_package(fftw              3.1.2                     fftw3          )
else()
LCG_external_package(fftw              3.2.2                     fftw3          )
endif()
LCG_external_package(Frontier_Client   2.8.5p1                   frontier_client)
if(NOT LCG_COMP STREQUAL "gccmax")
LCG_external_package(GCCXML            0.9.0_20110825            gccxml         )
else()
LCG_external_package(GCCXML            0.9.0_20120309            gccxml         )
endif()
LCG_external_package(genshi            0.6                                      )
LCG_external_package(gfal              1.11.8-2                                 )
LCG_external_package(globus            4.0.7-VDT-1.10.1                         )
LCG_external_package(graphviz          2.28.0                                   )
LCG_external_package(GSL               1.10                                     )
LCG_external_package(HepMC             2.06.05                                  )
LCG_external_package(HepPDT            2.06.01                                  )
LCG_external_package(igprof            5.9.2                                    )
LCG_external_package(ipython           0.12.1                                   )
LCG_external_package(javasdk           1.6.0                                    )
LCG_external_package(javajni           ${javasdk_config_version}                )
LCG_external_package(json              2.5.2                                    )
LCG_external_package(kcachegrind       0.4.6                                    )
LCG_external_package(lapack            3.4.0                                    )
LCG_external_package(lcgdmcommon       1.7.4-7sec                               )
LCG_external_package(lcginfosites      2.6.2-1                                  )
LCG_external_package(lcgutils          1.7.6-1                                  )
LCG_external_package(lcov              1.9                                      )
LCG_external_package(lfc               1.7.4-7sec                Grid/LFC       )
LCG_external_package(libsvm            2.86                                     )
LCG_external_package(libunwind         5c2cade                                  )
LCG_external_package(lxml              2.3                                      )
LCG_external_package(matplotlib        1.1.0                                    )
LCG_external_package(minuit            5.27.02                                  )
LCG_external_package(mock              0.8.0                                    )
LCG_external_package(multiprocessing   2.6.2.1                                  )
LCG_external_package(myproxy           4.2-VDT-1.10.1                           )
LCG_external_package(mysql             5.5.14                                   )
LCG_external_package(mysql_python      1.2.3                                    )
LCG_external_package(neurobayes        3.7.0                                    )
LCG_external_package(neurobayes_expert 3.7.0                                    )
LCG_external_package(nose              1.1.2                                    )
LCG_external_package(numpy             1.6.1                                    )
LCG_external_package(oracle            11.2.0.3.0                               )
LCG_external_package(processing        0.52                                     )
LCG_external_package(py                1.4.8                                    )
if(LCG_SYSTEM MATCHES "-slc6-")
LCG_external_package(pyanalysis        1.3p1                                    )
else()
LCG_external_package(pyanalysis        1.3                                      )
endif()
LCG_external_package(pydot             1.0.28                                   )
LCG_external_package(pygraphics        1.3                                      )
LCG_external_package(pylint            0.25.1                                   )
LCG_external_package(pyminuit          0.0.1                                    )
LCG_external_package(pyparsing         1.5.6                                    )
LCG_external_package(pyqt              4.9.3                                    )
LCG_external_package(pytest            2.2.4                                    )
if(NOT LCG_SYSTEM MATCHES "-mac106-")
LCG_external_package(Python            2.7.3                                    )
else()
LCG_external_package(Python            2.7.3                                    )
endif()
LCG_external_package(pytools           1.7p1                                    )
LCG_external_package(pyxml             0.8.4p1                                  )
LCG_external_package(QMtest            2.4.1                                    )
LCG_external_package(Qt                4.7.4                     qt             )
LCG_external_package(qwt               6.0.1                                    )
LCG_external_package(readline          2.5.1p1                                  )
LCG_external_package(roofit            3.10p1                                   )
LCG_external_package(scipy             0.10.0                                   )
LCG_external_package(setuptools        0.6c11                                   )
LCG_external_package(sip               4.13.3                                   )
LCG_external_package(soqt              1.5.0                                    )
LCG_external_package(sqlalchemy        0.7.7                                    )
LCG_external_package(sqlite            3070900                                  )
LCG_external_package(stomppy           3.1.3                                    )
LCG_external_package(storm             0.19                                     )
LCG_external_package(sympy             0.7.1                                    )
LCG_external_package(swig              1.3.40                                   )
LCG_external_package(TBB               41_20130116               tbb            )
LCG_external_package(tcmalloc          1.7p3                                    )
if(NOT LCG_SYSTEM MATCHES "-slc6-") # uuid is not distributed with SLC6
LCG_external_package(uuid              1.42                                     )
endif()
LCG_external_package(valgrind          3.7.0p1                                  )
LCG_external_package(vomsapi_noglobus  1.9.17-1                                 )
LCG_external_package(vomsapic          1.9.17-1                                 )
LCG_external_package(vomsapicpp        1.9.17-1                                 )
LCG_external_package(vomsclients       1.9.17-1                                 )
LCG_external_package(XercesC           3.1.1                                    )
if(NOT ${LCG_COMP}${LCG_COMPVERS} STREQUAL "gcc46")
LCG_external_package(xqilla            2.2.4                                    )
else()
LCG_external_package(xqilla            2.2.4p1                                  )
endif()
LCG_external_package(xrootd            3.1.0p2                                  )

#---Additional External packages------(Generators)-----------------
LCG_external_package(lhapdf            5.8.8          MCGenerators/lhapdf       )
LCG_external_package(pythia8           165            MCGenerators/pythia8      )
LCG_external_package(pythia8           175            MCGenerators/pythia8      )
LCG_external_package(thepeg            1.8.2          MCGenerators/thepeg       )
LCG_external_package(herwig++          2.6.2          MCGenerators/herwig++     )
LCG_external_package(tauola++          1.1.1a         MCGenerators/tauola++     )
LCG_external_package(pythia6           427            MCGenerators/pythia6        author=6.4.27 hepevt=4000   )
LCG_external_package(pythia6           427.2          MCGenerators/pythia6        author=6.4.27 hepevt=10000  )
LCG_external_package(agile             1.4.0          MCGenerators/agile        )
LCG_external_package(photos++          3.52           MCGenerators/photos++     )
LCG_external_package(evtgen            1.1.0          MCGenerators/evtgen       )
LCG_external_package(rivet             1.8.2          MCGenerators/rivet        )
LCG_external_package(sherpa            1.4.3          MCGenerators/sherpa       )
LCG_external_package(hepmcanalysis     3.4.14         MCGenerators/hepmcanalysis  author=00-03-04-14        )
LCG_external_package(mctester          1.25.0         MCGenerators/mctester     )
LCG_external_package(hijing            1.383bs.2      MCGenerators/hijing       )
LCG_external_package(starlight         r43            MCGenerators/starlight    )
LCG_external_package(herwig            6.520          MCGenerators/herwig       )
LCG_external_package(herwig            6.520.2        MCGenerators/herwig       )
LCG_external_package(crmc              v3400          MCGenerators/crmc         )


# Prepare the search paths according to the versions above
LCG_prepare_paths()
