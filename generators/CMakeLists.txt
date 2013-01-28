
#---pythia8------------------------------------------------------------------------------------------
LCGPackage_Add(
  pythia8
  URL http://home.thep.lu.se/~torbjorn/pythia8/pythia8${pythia8_native_version}.tgz
  CONFIGURE_COMMAND ./configure --prefix <INSTALL_DIR> --lcgplatform=${LCG_TARGET} --enable-shared --with-hepmc=${HepMC-home}
  BUILD_IN_SOURCE 1
  INSTALL_COMMAND cmake -E copy_directory <SOURCE_DIR>/include  <INSTALL_DIR>/include
          COMMAND cmake -E copy_directory <SOURCE_DIR>/lib  <INSTALL_DIR>/lib
          COMMAND cmake -E copy_directory <SOURCE_DIR>/xmldoc  <INSTALL_DIR>/xmldoc
  DEPENDS HepMC
)


