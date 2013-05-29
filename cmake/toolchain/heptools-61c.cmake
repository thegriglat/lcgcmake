cmake_minimum_required(VERSION 2.8.5)

# Declare the version of HEP Tools we use
# (must be done before including heptools-common to allow evolution of the
# structure)
set(heptools_version  61c)

include(${CMAKE_CURRENT_LIST_DIR}/heptools-common.cmake)

# please keep alphabetic order and the structure (tabbing).
# it makes it much easier to edit/read this file!


# Application Area Projects
LCG_AA_project(COOL  COOL_2_8_12a)
LCG_AA_project(CORAL CORAL_2_3_20a)
LCG_AA_project(RELAX RELAX_1_3_0d)
LCG_AA_project(ROOT  5.30.05)

# Compilers
#LCG_compiler(gcc43 gcc 4.3.5)
#LCG_compiler(gcc46 gcc 4.6.2)
#LCG_compiler(gcc47 gcc 4.7.2)
#LCG_compiler(clang30 clang 3.0)
#LCG_compiler(gccmax gcc 4.7.2)

# Externals

LCG_external_package(cmaketools        1.0                                      )
LCG_external_package(py2neo            1.4.6                                    )
LCG_external_package(pylint            0.26.0                                   )
LCG_external_package(nose              1.1.2                                    )
LCG_external_package(coverage          3.5.2                                    )  
LCG_external_package(swig              1.3.40                                   )
LCG_external_package(4suite            1.0.2p1                                  )
LCG_external_package(AIDA              3.2.1                                    )
LCG_external_package(bjam              3.1.13                                   )
LCG_external_package(blas              20070405                                 )
LCG_external_package(Boost             1.44.0                                   )
LCG_external_package(bz2lib            1.0.2                                    )
LCG_external_package(CASTOR            2.1.8-10                  castor         )
LCG_external_package(cernlib           2006a                                    )
LCG_external_package(cgsigsoap         1.3.3-1                                  )
LCG_external_package(CLHEP             1.9.4.7                   clhep          )
LCG_external_package(cmake             2.6.4                                    )
LCG_external_package(cmt               v1r20p20081118                           )
LCG_external_package(coin3d            3.1.3.p1                                 )
LCG_external_package(CppUnit           1.12.1_p1                                )
LCG_external_package(cx_oracle         5.1                                      )
LCG_external_package(Cygwin            1.5                                      )
LCG_external_package(david             1_36a                                    )
LCG_external_package(dawn              3_88a                                    )
LCG_external_package(dcache_client     1.9.3p1                                  )
LCG_external_package(doxygen           1.7.0                                    )
LCG_external_package(dpm               1.7.4-7sec                               )
LCG_external_package(Expat             2.0.1                                    )
LCG_external_package(fastjet           2.4.3                                    )
LCG_external_package(fftw              3.1.2                     fftw3          )
LCG_external_package(Frontier_Client   2.8.4                     frontier_client)
LCG_external_package(GCCXML            0.9.0_20100114            gccxml         )
LCG_external_package(genshi            0.6                                      )
LCG_external_package(gfal              1.11.8-2                                 )
LCG_external_package(globus            4.0.7-VDT-1.10.1                         )
LCG_external_package(graphviz          2.28.0                                   )
LCG_external_package(GSL               1.10                                     )
LCG_external_package(HepMC             2.06.05                                  )
LCG_external_package(HepPDT            2.06.01                                  )
LCG_external_package(igprof            5.9.2                                    )
LCG_external_package(ipython           0.10.2                                   )
LCG_external_package(javasdk           1.6.0                                    )
LCG_external_package(javajni           ${javasdk_config_version}                )
LCG_external_package(json              2.1.6                                    )
LCG_external_package(kcachegrind       0.4.6                                    )
LCG_external_package(lapack            3.1.1                                    )
LCG_external_package(lcgdmcommon       1.7.4-7sec                               )
LCG_external_package(lcginfosites      2.6.2-1                                  )
LCG_external_package(lcgutils          1.7.6-1                                  )
LCG_external_package(lcov              1.9                                      )
LCG_external_package(lfc               1.7.4-7sec                Grid/LFC       )
LCG_external_package(libsvm            2.86                                     )
LCG_external_package(libunwind         5c2cade                                  )
LCG_external_package(lxml              2.3                                      )
LCG_external_package(matplotlib        0.99.1.1                                 )
LCG_external_package(minuit            5.27.02                                  )
LCG_external_package(mock              0.7.2                                    )
LCG_external_package(multiprocessing   2.6.2.1                                  )
LCG_external_package(myproxy           4.2-VDT-1.10.1                           )
LCG_external_package(mysql             5.5.14                                   )
LCG_external_package(mysql_python      1.2.3                                    )
LCG_external_package(neurobayes        10.12                                    )
LCG_external_package(neurobayes_expert 10.12                                    )
LCG_external_package(numpy             1.3.0                                    )
LCG_external_package(oracle            11.2.0.1.0p3                             )
LCG_external_package(POOL              POOL_2_9_19                              )
LCG_external_package(processing        0.52                                     )
LCG_external_package(py                1.4.4                                    )
LCG_external_package(pyanalysis        1.2                                      )
LCG_external_package(pydot             1.0.2                                    )
LCG_external_package(pygraphics        1.1p1                                    )
LCG_external_package(pyminuit          0.0.1                                    )
LCG_external_package(pyparsing         1.5.1                                    )
LCG_external_package(pyqt              4.7                                      )
LCG_external_package(pytest            2.1.0                                    )
LCG_external_package(Python            2.6.5p2                                    )
LCG_external_package(pytools           1.6                                      )
LCG_external_package(pyxml             0.8.4p1                                  )
LCG_external_package(QMtest            2.4.1                                    )
LCG_external_package(Qt                4.6.3p2                   qt             )
LCG_external_package(qwt               5.2.1                                    )
LCG_external_package(readline          2.5.1p1                                  )
LCG_external_package(roofit            3.10p1                                   )
LCG_external_package(scipy             0.7.1                                    )
LCG_external_package(setuptools        0.6c11                                   )
LCG_external_package(sip               4.10                                     )
LCG_external_package(soqt              1.5.0.p1                                 )
LCG_external_package(sqlalchemy        0.7.1                                    )
LCG_external_package(sqlite            3.6.22                                   )
LCG_external_package(stomppy           3.0.4                                    )
LCG_external_package(storm             0.18                                     )
LCG_external_package(sympy             0.6.7                                    )
LCG_external_package(tcmalloc          1.7p1                                    )
if(NOT ${LCG_OS}${LCG_OS_VERS} STREQUAL slc6) # uuid is not distributed with SLC6
LCG_external_package(uuid              1.38p1                                   )
endif()
LCG_external_package(valgrind          3.6.0                                    )
LCG_external_package(vomsapi_noglobus  1.9.17-1                                 )
LCG_external_package(vomsapic          1.9.17-1                                 )
LCG_external_package(vomsapicpp        1.9.17-1                                 )
LCG_external_package(vomsclients       1.9.17-1                                 )
LCG_external_package(XercesC           3.1.1p1                                  )
LCG_external_package(xqilla            2.2.4                                    )
LCG_external_package(zlib              1.2.3p1                                  )
LCG_external_package(xrootd            3.2.7                                    )
LCG_external_package(dcap              2.47.6                                   )
LCG_external_package(expat             2.0.1                                    )
LCG_external_package(srm_ifce          1.13.0-0                                 )

set(MCGENPATH  MCGenerators_lcgcmt${heptools_version})

#---Additional External packages------(Generators)-----------------
LCG_external_package(powheg-box         r2092         ${MCGENPATH}/powheg-box       )
LCG_external_package(lhapdf            5.8.9          ${MCGENPATH}/lhapdf       )
LCG_external_package(lhapdfsets        5.8.9          ${MCGENPATH}/lhapdfsets   )

LCG_external_package(pythia8           175            ${MCGENPATH}/pythia8      )
LCG_external_package(pythia8           176            ${MCGENPATH}/pythia8      )

LCG_external_package(thepeg            1.8.2          ${MCGENPATH}/thepeg       )
LCG_external_package(herwig++          2.6.3          ${MCGENPATH}/herwig++     )
LCG_external_package(tauola++          1.1.1a         ${MCGENPATH}/tauola++     )
LCG_external_package(pythia6           427            ${MCGENPATH}/pythia6        author=6.4.27 hepevt=4000   )
LCG_external_package(pythia6           427.2          ${MCGENPATH}/pythia6        author=6.4.27 hepevt=10000  )
LCG_external_package(agile             1.4.0          ${MCGENPATH}/agile        )
LCG_external_package(photos++          3.52           ${MCGENPATH}/photos++     )
#LCG_external_package(photos            215.5         ${MCGENPATH}/photos     )
LCG_external_package(photos            215.4          ${MCGENPATH}/photos     ) 
#LCG_external_package(photos            215.3         ${MCGENPATH}/photos     ) 

LCG_external_package(evtgen            1.1.0          ${MCGENPATH}/evtgen         tag=R01-01-00 p8vers=175 )
LCG_external_package(evtgen            1.1.0-176      ${MCGENPATH}/evtgen         tag=R01-01-00 p8vers=176 )
LCG_external_package(evtgen            1.2.0          ${MCGENPATH}/evtgen         tag=R01-02-00 p8vers=176 )
LCG_external_package(evtgen            1.2.0-175      ${MCGENPATH}/evtgen         tag=R01-02-00 p8vers=175 )

LCG_external_package(rivet             1.8.3          ${MCGENPATH}/rivet        )
LCG_external_package(rivet2            2.0.0b1        ${MCGENPATH}/rivet2       )
LCG_external_package(sherpa            1.4.3          ${MCGENPATH}/sherpa         author=1.4.3 hepevt=4000  )
LCG_external_package(sherpa            1.4.3.2        ${MCGENPATH}/sherpa         author=1.4.3 hepevt=10000 )
LCG_external_package(hepmcanalysis     3.4.14         ${MCGENPATH}/hepmcanalysis  author=00-03-04-14        )
LCG_external_package(mctester          1.25.0         ${MCGENPATH}/mctester     )
LCG_external_package(hijing            1.383bs.2      ${MCGENPATH}/hijing       )
LCG_external_package(starlight         r43            ${MCGENPATH}/starlight    )
#LCG_external_package(herwig            6.520         ${MCGENPATH}/herwig       )
LCG_external_package(herwig            6.520.2        ${MCGENPATH}/herwig       )
LCG_external_package(crmc              v3400          ${MCGENPATH}/crmc         )
LCG_external_package(cython            0.19           ${MCGENPATH}/cython       )
LCG_external_package(yaml_cpp          0.3.0          ${MCGENPATH}/yaml_cpp     )
LCG_external_package(yoda              1.0.0          ${MCGENPATH}/yoda         )
LCG_external_package(hydjet              1.8          ${MCGENPATH}/hydjet         )  
LCG_external_package(tauola              28.121.2     ${MCGENPATH}/tauola         )
LCG_external_package(jimmy              4.31.3        ${MCGENPATH}/jimmy         )
LCG_external_package(hydjet++           2_1           ${MCGENPATH}/hydjet++     )
LCG_external_package(alpgen            2.1.4          ${MCGENPATH}/alpgen author=214 )
LCG_external_package(pyquen           1.5             ${MCGENPATH}/pyquen     )


# Prepare the search paths according to the versions above
LCG_prepare_paths()
