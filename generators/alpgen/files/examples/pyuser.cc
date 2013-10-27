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

using namespace std;
 
int main() { 

unsigned int Nevt = 1000;
unsigned int i, N_2lep_X, N_2jet_X, N_2lep_1jet, N_2lep_2jet, nold;

JetableInputFromHepMC JI;
JetFinderUA JF;
LeptonAnalyserHepMC LA;

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
//
// Instantiate an IO strategy to write the data to file - it uses the 
//  same ParticleDataTable
//HepMC::IO_Ascii ascii_io("test_pythia_hepmc.dat",std::ios::out);

//.......EVENT LOOP:

N_2lep_X = 0;
N_2jet_X = 0;
N_2lep_1jet = 0;
N_2lep_2jet = 0;
nold=0;
for (i = 1; i <= Nevt; i++) {
    if (i % 50 == 1)
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
// write the event out to the ascii file
//    ascii_io << evt;

// Analysing the event:
    vector<JetableObject> objects = JI.readFromHepMC (evt);
    vector<Jet> alljets = JF.findJets (objects);
    vector<Jet>    jets = LA.removeLeptonsFromJets (alljets, evt);
    if (jets.size() >= 2) N_2jet_X ++;
    if (LA.nIsolatedLeptons (evt) >= 2) {
       N_2lep_X ++;
       if (jets.size() >= 1)
           N_2lep_1jet ++;
       if (jets.size() >= 2)
           N_2lep_2jet ++;
      }
// we also need to delete the created event from memory
    delete evt;
  } // end of event loop

// write out some information from Pythia to the screen
call_pystat(1);    

// Now making output for a comparison with a reference file test0.dat:
double sigma = pyint5.xsec[2][0],
   err_sigma = pyint5.ngen[2][0] > 0 ? sigma/sqrt((double)(pyint5.ngen[2][0]))
                                     : 0.;
double fr_2lep = (double)N_2lep_X / (double)pyint5.ngen[2][0],
   err_fr_2lep = fr_2lep / sqrt((double)N_2lep_X);

double fr_2lep_2jet = (double)N_2lep_2jet / (double)pyint5.ngen[2][0],
   err_fr_2lep_2jet = fr_2lep_2jet / sqrt((double)N_2lep_2jet);

cout << "Nev two isolated leptons:                     " << N_2lep_X << endl;
cout << "Nev two or more jets:                         " << N_2jet_X << endl;
cout << "Nev two isolated leptons and jet(s):          " << N_2lep_1jet << endl;
cout << "Nev two isolated leptons and two or more jets " << N_2lep_2jet << endl;

ofstream testi("testi.dat");

testi << "alpgen  1   " << sigma   << "    " << err_sigma   << " " << std::endl;
testi << "alpgen  2   " << fr_2lep_2jet << "          " 
                        << err_fr_2lep_2jet << " " << std::endl;

testi.close();

return 0;
}
