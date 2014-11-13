// #@# 1: Produce z+jets events, convert to HepMC and write to text file 
//
// A test for event generation with Pythia6 using HepMC/PythiaWrapper.h
// Adopted from: 
//
//* Matt.Dobbs@Cern.CH, December 1999
//* November 2000, updated to use Pythia 6.1
//* example of generating events with Pythia
//* using HepMC/PythiaWrapper.h 
//* Events are read into the HepMC event record from the FORTRAN HEPEVT 
//* common block using the IO_HEPEVT strategy and then output to file in
//* ascii format using the IO_Ascii strategy.
//*
//* In this example the precision and number of entries for the HEPEVT 
//* fortran common block are explicitly defined to correspond to those 
//* used in the Pythia version of the HEPEVT common block. 
//*
//* If you get funny output from HEPEVT in your own code, probably you have
//* set these values incorrectly!
//

#include <iostream>
#include <fstream>

#include "HepMC/PythiaWrapper.h"
#include "HepMC/IO_HEPEVT.h"
#include "HepMC/GenEvent.h"
//#include "HepMC/IO_Ascii.h"
#include "HepMC/IO_GenEvent.h"

using namespace std;
 
int main() { 

  unsigned int Nevt = 1000;
  unsigned int i;

  //........................................HEPEVT
  //  Standard Pythia >6.1 uses HEPEVT with NMXHEP=4000 entries and 8-byte
  //  floating point numbers. We need to explicitly pass this information
  //  to the HEPEVT_Wrapper.
  // AR: next 3 lines are used for Pythia6 >=409 
  pyjets.n=0;                                              // ensure dummyness of the next call
  call_pyhepc(1);                                          // mstu(8) is set to NMXHEP in this dummy call
  unsigned int HEPEVT_SIZE = pydat1.mstu[8-1];             // AR: for Pythia6 >= 409
  // unsigned int HEPEVT_SIZE = 10000;                     // AR: for Pythia6 <  409, can be 4000 also
  HepMC::HEPEVT_Wrapper::set_max_number_entries(HEPEVT_SIZE);
  HepMC::HEPEVT_Wrapper::set_sizeof_real(8);
    
  // Specify file where HepMC events will be stored.
  HepMC::IO_GenEvent ascii_io("hepmcoutzjets_pythia6.dat", std::ios::out);

  //........................................PYTHIA INITIALIZATIONS
  // (Some platforms may require the initialization of pythia PYDATA block 
  //  data as external - if you get pythia initialization errors try 
  //  commenting in/out the below call to initpydata() )
  // initpydata();
  //..............................................................


  // Selecting jet + gamma*/Z process (number 13):
  pysubs.msel = 13;

  // pT > 10 GeV cut:
  pysubs.ckin[3-1] = 20.;

  for ( int idc = pydat3.mdcy[2-1][23-1] ;
        idc < pydat3.mdcy[2-1][23-1] + pydat3.mdcy[3-1][23-1]; idc++ ) {
    if ( abs(pydat3.kfdp[1-1][idc-1]) != 11 &&
         abs(pydat3.kfdp[1-1][idc-1]) != 13 && // only lepton decay modes
         abs(pydat3.kfdp[1-1][idc-1]) != 15 )
      pydat3.mdme[1-1][idc-1] = min(0, pydat3.mdme[1-1][idc-1]);
  }

  // set random number seed (mandatory!)
  pydatr.mrpy[0] = 55122 ;

  // Tell Pythia not to write multiple copies of particles in event record.
  pypars.mstp[128-1] = 2;

  // Top mass = 174.3:
  //pydat2.pmas[1-1][6-1]= 174.3;  

  // Call pythia initialization
  call_pyinit("CMS", "p", "p", 13000.);

  //........................................HepMC INITIALIZATIONS
  //
  // Instantiate an IO strategy for reading from HEPEVT.
  HepMC::IO_HEPEVT hepevtio;
  //
  // Instantiate an IO strategy to write the data to file - it uses the 
  //  same ParticleDataTable
  //HepMC::IO_Ascii ascii_io("test_pythia_hepmc.dat",std::ios::out);

  //.......EVENT LOOP:

  for (i = 1; i <= Nevt; i++) {
    if (i % 50 == 1) std::cout << "Processing event number " << i << std::endl;
    call_pyevnt();      // generate one event with Pythia
    // pythia pyhepc routine converts common PYJETS in common HEPEVT
    call_pyhepc(1);
    HepMC::GenEvent* evt =
      new HepMC::GenEvent(HepMC::Units::GEV, HepMC::Units::MM);
    evt = hepevtio.read_next_event();
    // add some information to the event
    evt->set_event_number(i);
    evt->set_signal_process_id(20);
    HepMC::GenCrossSection xsec;
    double cs = pypars.pari[0]; // cross section in mb
    cs *= 1.0e9; // translate to pb
    double cserr = cs / sqrt(pypars.msti[4]);
    xsec.set_cross_section(cs, cserr);
    evt->set_cross_section(xsec);

    // write the event out to the ascii file
    ascii_io << evt;

    // we also need to delete the created event from memory
    delete evt;
  } // end of event loop

  // write out some information from Pythia to the screen
  call_pystat(1);    

  return 0;
}
