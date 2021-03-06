cmake_minimum_required(VERSION 2.8.5)

# Declare the version of HEP Tools we use
# (must be done before including heptools-common to allow evolution of the
# structure)
set(heptools_version  72a)

include(${CMAKE_CURRENT_LIST_DIR}/heptools-common.cmake)

# please keep alphabetic order and the structure (tabbing).
# it makes it much easier to edit/read this file!


# Application Area Projects
LCG_AA_project(COOL  COOL_2_9_5)
LCG_AA_project(CORAL CORAL_2_4_5)
LCG_AA_project(RELAX RELAX_1_3_0p)
LCG_AA_project(ROOT  5.34.25)
LCG_AA_project(LCGCMT LCGCMT_${heptools_version})
LCG_AA_project(HepMC 2.06.09)

# Externals
LCG_external_package(4suite            1.0.2p1                                  )
LCG_external_package(AIDA              3.2.1                                    )
LCG_external_package(blas              20110419                                 )
LCG_external_package(Boost             1.55.0                                   )
LCG_external_package(CLHEP             1.9.4.7                   clhep          )
LCG_external_package(cmaketools        1.1                                      )
LCG_external_package(cmt               v1r20p20090520                           )
LCG_external_package(coin3d            3.1.3p2                                  )
LCG_external_package(coverage          3.5.2                                    )
LCG_external_package(CppUnit           1.12.1_p1                 author=1.12.1  )
LCG_external_package(cx_oracle         5.1.1                                    )
if(NOT ${LCG_OS} STREQUAL mac)
  LCG_external_package(Davix             0.3.1                                  )
endif()
LCG_external_package(doxygen           1.8.2                                    ) 
LCG_external_package(expat             2.0.1                                    )
LCG_external_package(fastjet           3.1.1                                    )
LCG_external_package(fftw              3.1.2                     fftw3          )
LCG_external_package(Frontier_Client   2.8.10                     frontier_client)
LCG_external_package(GCCXML            0.9.0_20131026            gccxml         )
LCG_external_package(genshi            0.6                                      )
LCG_external_package(graphviz          2.28.0                                   )
LCG_external_package(GSL               1.10                                     )
LCG_external_package(HepPDT            2.06.01                                  )
LCG_external_package(ipython           0.12.1                                   )
LCG_external_package(json              2.5.2                                    )
LCG_external_package(lapack            3.5.0                                    )
LCG_external_package(lcov              1.9                                      )
LCG_external_package(libsvm            2.86                                     )
LCG_external_package(libtool           1.5.26                                   )
LCG_external_package(lxml              2.3                                      )
LCG_external_package(matplotlib        1.3.1                                    )
LCG_external_package(minuit            5.27.02                                  )
LCG_external_package(mock              0.8.0                                    )
LCG_external_package(multiprocessing   2.6.2.1                                  )
LCG_external_package(mysql             5.5.27                                   )
LCG_external_package(mysql_python      1.2.3                                    )
LCG_external_package(nose              1.1.2                                    )
LCG_external_package(numpy             1.8.0                                    )
LCG_external_package(oracle            11.2.0.3.0                               )
LCG_external_package(pacparser         1.3.1                                    )
LCG_external_package(pcre              8.34                                     )
LCG_external_package(processing        0.52                                     )
LCG_external_package(py                1.4.8                                    )
LCG_external_package(py2neo            1.4.6                                    )
LCG_external_package(pyanalysis        1.4                                      )
LCG_external_package(pydot             1.0.28                                   )
LCG_external_package(pygraphics        1.4                                      )
LCG_external_package(pygsi             0.5                                      )
LCG_external_package(pylint            1.2.1                                    )
LCG_external_package(pyminuit          0.0.1                                    )
LCG_external_package(pyparsing         1.5.6                                    )
LCG_external_package(pyqt              4.9.5                                    )
LCG_external_package(pytest            2.2.4                                    )
LCG_external_package(pytz              2014.7                                   )
LCG_external_package(Python            2.7.6                                    )
LCG_external_package(PythonFWK         2.7.6                  Python            )
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
LCG_external_package(swig              2.0.11           author=2.0.11           )
LCG_external_package(sympy             0.7.1                                    )
LCG_external_package(tbb               42_20140122                              )
LCG_external_package(tcmalloc          1.7p3                                    )
if(NOT ${LCG_OS}${LCG_OSVERS} STREQUAL slc6) # uuid is not distributed with SLC6
LCG_external_package(uuid              1.42                                     )
endif()
if(NOT ${LCG_OS}${LCG_OSVERS} STREQUAL mac109 AND NOT LCG_TARGET MATCHES "icc" ) # valgrind does not work yet with mac109 and icc
  LCG_external_package(valgrind          3.10.0                                    )
endif()
LCG_external_package(vdt               0.3.6                                    )
LCG_external_package(XercesC           3.1.1p1        author=3.1.1              )
LCG_external_package(xqilla            2.2.4p1                                  )
LCG_external_package(xrootd            3.3.6                                    )
if(NOT ${LCG_OS} STREQUAL mac)
  LCG_external_package(xrootd_python     0.1.3                                    )
endif()

LCG_external_package(mpich2            1.5                                      )

#---EMI-2 grid externals and other binary packages---------------------
if(NOT ${LCG_OS} STREQUAL mac)
  LCG_external_package(libunwind       5c2cade                                  )
  LCG_external_package(igprof          5.9.11                                    )
  if (NOT ${LCG_HOST_ARCH} STREQUAL i686)
   LCG_external_package(CASTOR          2.1.13-6               castor            )
   LCG_external_package(cream           1.14.0-4               Grid/cream        )
   LCG_external_package(dcap            2.47.7-1               Grid/dcap         )
   LCG_external_package(dm-util         1.15.0-0               Grid/dm-util      )
   LCG_external_package(dpm             1.8.5-1                Grid/DPM          )
   LCG_external_package(epel            20130408               Grid/epel         )
   LCG_external_package(FTS             2.2.8emi2              Grid/FTS          )
   if(${LCG_OS}${LCG_OSVERS} STREQUAL slc6)
    LCG_external_package(FTS3            0.0.1-88             Grid/FTS3         )
   endif()
   LCG_external_package(gfal            1.13.0-0               Grid/gfal         )
   LCG_external_package(gfal2           2.2.0-1                Grid/gfal2        )
   LCG_external_package(gridftp_ifce    2.3.1-0                Grid/gridftp-ifce )
   LCG_external_package(gridsite        1.7.25-1.emi2          Grid/gridsite     )
   LCG_external_package(is_ifce         1.15.0-0               Grid/is-ifce      )
   LCG_external_package(lb              3.2.9                  Grid/lb           )
   LCG_external_package(lcgdmcommon     1.8.5-1                Grid/lcg-dm-common)
   LCG_external_package(lcginfosites    3.1.0-3                Grid/lcg-infosites)
   LCG_external_package(lfc             1.8.5-1                Grid/LFC          )
   LCG_external_package(srm_ifce        1.13.0-0               Grid/srm-ifce     )
   LCG_external_package(voms            2.0.9-1                Grid/voms         )
   LCG_external_package(WMS             3.4.0                  Grid/WMS          )
   LCG_external_package(neurobayes        3.7.0                                    )
   LCG_external_package(neurobayes_expert 3.7.0                                    )
  endif()
endif()

#---Additional External packages------(Generators)-----------------

set(MCGENPATH  MCGenerators)

LCG_external_package(heputils       1.0.6          ${MCGENPATH}/heputils )
LCG_external_package(mcutils        1.1.1          ${MCGENPATH}/mcutils )

LCG_external_package(heputils       1.0.0          ${MCGENPATH}/heputils )
LCG_external_package(mcutils        1.1.0          ${MCGENPATH}/mcutils )

LCG_external_package(madgraph5amc       2.2.1          ${MCGENPATH}/madgraph5amc )
LCG_external_package(madgraph5amc       2.1.2          ${MCGENPATH}/madgraph5amc )

LCG_external_package(lhapdf            5.8.8          ${MCGENPATH}/lhapdf       )
LCG_external_package(lhapdf            5.9.1          ${MCGENPATH}/lhapdf       )
LCG_external_package(lhapdf            6.1.5          ${MCGENPATH}/lhapdf       )
LCG_external_package(lhapdf            6.1.4          ${MCGENPATH}/lhapdf       )

LCG_external_package(lhapdfsets        5.8.8          lhapdfsets   )
LCG_external_package(lhapdfsets        5.9.1          lhapdfsets   )

LCG_external_package(powheg-box         r2092         ${MCGENPATH}/powheg-box       )

LCG_external_package(pythia8           175            ${MCGENPATH}/pythia8 )
LCG_external_package(pythia8           185            ${MCGENPATH}/pythia8 )
LCG_external_package(pythia8           201            ${MCGENPATH}/pythia8 )
LCG_external_package(pythia8           209            ${MCGENPATH}/pythia8 )
LCG_external_package(pythia8           210            ${MCGENPATH}/pythia8 )
LCG_external_package(pythia8           186            ${MCGENPATH}/pythia8 )

LCG_external_package(sacrifice         0.9.9          ${MCGENPATH}/sacrifice pythia8=186)

LCG_external_package(thepeg            1.9.2p1          ${MCGENPATH}/thepeg author=1.9.2 )

LCG_external_package(herwig++          2.7.1           ${MCGENPATH}/herwig++  thepeg=1.9.2p1 )

LCG_external_package(tauola++          1.1.1a         ${MCGENPATH}/tauola++     )
LCG_external_package(tauola++          1.1.4          ${MCGENPATH}/tauola++     )
LCG_external_package(tauola++          1.1.5          ${MCGENPATH}/tauola++     )

LCG_external_package(pythia6           429.2          ${MCGENPATH}/pythia6    author=6.4.28 hepevt=10000  )
LCG_external_package(pythia6           427.2          ${MCGENPATH}/pythia6    author=6.4.27 hepevt=10000  )
LCG_external_package(pythia6           428.2          ${MCGENPATH}/pythia6    author=6.4.28 hepevt=10000  )

LCG_external_package(agile             1.4.1          ${MCGENPATH}/agile        )

LCG_external_package(photos++          3.52           ${MCGENPATH}/photos++     )
LCG_external_package(photos++          3.56           ${MCGENPATH}/photos++     )

LCG_external_package(photos            215.4          ${MCGENPATH}/photos       )

LCG_external_package(evtgen            1.2.0          ${MCGENPATH}/evtgen         tag=R01-02-00 pythia8=175 tauola++=1.1.1a)
LCG_external_package(evtgen            1.4.0          ${MCGENPATH}/evtgen         tag=R01-04-00 pythia8=186 tauola++=1.1.4)
LCG_external_package(evtgen            1.3.0          ${MCGENPATH}/evtgen         tag=R01-03-00 pythia8=186 tauola++=1.1.4)


LCG_external_package(rivet             1.9.0          ${MCGENPATH}/rivet        yoda=1.1.0      )
LCG_external_package(rivet             2.2.1          ${MCGENPATH}/rivet        yoda=1.3.1      )
LCG_external_package(rivet             2.2.0          ${MCGENPATH}/rivet        yoda=1.3.0      )

LCG_external_package(sherpa            2.1.1          ${MCGENPATH}/sherpa         author=2.1.1 hepevt=10000)

LCG_external_package(qd                2.3.13          ${MCGENPATH}/qd         )

if (NOT ${LCG_HOST_ARCH} STREQUAL i686)
LCG_external_package(blackhat           0.9.9          ${MCGENPATH}/blackhat         )
LCG_external_package(sherpa-mpich2     2.1.1          ${MCGENPATH}/sherpa-mpich2  author=2.1.1 hepevt=10000)
endif()

LCG_external_package(hepmcanalysis     3.4.14         ${MCGENPATH}/hepmcanalysis  author=00-03-04-14  CLHEP=1.9.4.7      )
LCG_external_package(mctester          1.25.0         ${MCGENPATH}/mctester     )
LCG_external_package(hijing            1.383bs.2      ${MCGENPATH}/hijing       )
LCG_external_package(starlight         r43            ${MCGENPATH}/starlight    )

LCG_external_package(herwig            6.520.2        ${MCGENPATH}/herwig       )
LCG_external_package(herwig            6.521.2        ${MCGENPATH}/herwig       )

LCG_external_package(crmcold           v3400          ${MCGENPATH}/crmc         )
LCG_external_package(crmc              1.5.4          ${MCGENPATH}/crmc         )
LCG_external_package(crmc              1.4            ${MCGENPATH}/crmc         )
LCG_external_package(cython            0.22           ${MCGENPATH}/cython       )
LCG_external_package(cython            0.19.1         ${MCGENPATH}/cython       )
LCG_external_package(yamlcpp           0.3.0          ${MCGENPATH}/yamlcpp      )

LCG_external_package(yoda              1.1.0          ${MCGENPATH}/yoda cython=0.19.1         )
LCG_external_package(yoda              1.3.1          ${MCGENPATH}/yoda cython=0.22         )
LCG_external_package(yoda              1.3.0          ${MCGENPATH}/yoda cython=0.19.1         )

LCG_external_package(hydjet            1.6            ${MCGENPATH}/hydjet author=1_6 )
LCG_external_package(hydjet            1.8            ${MCGENPATH}/hydjet author=1_8 )
LCG_external_package(tauola            28.121.2       ${MCGENPATH}/tauola       )
LCG_external_package(jimmy             4.31.3         ${MCGENPATH}/jimmy        )
LCG_external_package(hydjet++          2.1            ${MCGENPATH}/hydjet++ author=2_1)
LCG_external_package(alpgen            2.1.4          ${MCGENPATH}/alpgen author=214 )
LCG_external_package(pyquen            1.5.1          ${MCGENPATH}/pyquen author=1_5)
LCG_external_package(baurmc            1.0            ${MCGENPATH}/baurmc       )
LCG_external_package(professor         1.3.3          ${MCGENPATH}/professor       )

LCG_external_package(jhu               3.1.8          ${MCGENPATH}/jhu       )

#LCG_external_package(vincia            HEAD          ${MCGENPATH}/vincia       )
LCG_external_package(fastnlo_toolkit   2.3.1pre-1871  ${MCGENPATH}/fastnlo_toolkit )


# Prepare the search paths according to the versions above
LCG_prepare_paths()
