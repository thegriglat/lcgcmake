//
//* In this example the precision and number of entries for the HEPEVT 
//* fortran common block are explicitly defined to correspond to those 
//* used in the Pythia version of the HEPEVT common block. 
//*
//* If you get funny output from HEPEVT in your own code, probably you have
//* set these values incorrectly!
//


#include <iostream>
#include "HepMC/PythiaWrapper.h"
#include "HepMC/IO_HEPEVT.h"
#include "HepMC/IO_Ascii.h"
#include "HepMC/GenEvent.h"

#include "ANHEPMC/JetableInputFromHepMC.h"
#include "ANHEPMC/JetFinderUA.h"
#include "ANHEPMC/LeptonAnalyserHepMC.h"

//........................

#include "pt_W_analysis.h"

//........................
 
int main() { 

unsigned int Nevt = 1000;
unsigned int i,  nold;

//........................................HEPEVT
// Pythia >6.1 uses HEPEVT with 4000 entries and 8-byte floating point
//  numbers. We need to explicitly pass this information to the 
//  HEPEVT_Wrapper.

HepMC::HEPEVT_Wrapper::set_max_number_entries(4000);
HepMC::HEPEVT_Wrapper::set_sizeof_real(8);
    
//........................................PYTHIA INITIALIZATIONS
// (Some platforms may require the initialization of pythia PYDATA block 
//  data as external - if you get pythia initialization errors try 
//  commenting in/out the below call to initpydata() )
// initpydata();
//..............................................................

// set random number seed (mandatory!)
pydatr.mrpy[0] = 55122 ;

// Tell Pythia not to write multiple copies of particles in event record.
pypars.mstp[128-1] = 2;

// Call pythia initialization
call_pyinit("USER", " ", " ", 0.);

//........................................HepMC INITIALIZATIONS
//
// Instantiate an IO strategy for reading from HEPEVT.
HepMC::IO_HEPEVT hepevtio;

init_hist ("pt_W_hist.bins");

//.......EVENT LOOP:

nold=0;
for (i = 1; i <= Nevt; i++) {
    if (i % 50 == 0)
      std::cout << "Processing event number " << i << std::endl;
    call_pyevnt();      // generate one event with Pythia
    if(pyint5.ngen[2][0] == nold) break;
    nold = pyint5.ngen[2][0];
// pythia pyhepc routine converts common PYJETS in common HEPEVT
    call_pyhepc(1);
    HepMC::GenEvent* evt = hepevtio.read_next_event();
// add some information to the event
    evt->set_event_number(i);
    evt->set_signal_process_id(20);
// Analysing the event:
    event_analysis (evt);
// we also need to delete the created event from memory
    delete evt;
  } // end of event loop

//Total cross section:
double sigma = pyint5.xsec[2][0],
   err_sigma = pyint5.ngen[2][0] > 0 ? sigma/sqrt((double)(pyint5.ngen[2][0])) : 0.;

// writing histograms to the *.root file:
store_analysis ("alpgen_pt_W.root","alpgen_pt_W.sig", sigma, err_sigma, pyint5.ngen[2][0]);

std::cout << "****** sigma_tot: " << sigma << " +- " << err_sigma << "[mb]" << std::endl;
	
return 0;
}
