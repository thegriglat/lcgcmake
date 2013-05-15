//#@# This example uses HepMC event interface.
//#@# 3: Z + jets total cross section [pb] at LHC 
//#@# 4: Fraction of events with >=2 charged leptons + >=2 jets
//
//////////////////////////////////////////////////////////////////////////
// Matt.Dobbs@Cern.CH, October 2002
// example of generating events with Herwig using HepMC/HerwigWrapper.h 
// Events are read into the HepMC event record from the FORTRAN HEPEVT 
// common block using the IO_HERWIG strategy.
//////////////////////////////////////////////////////////////////////////
//
// In this example the precision and number of entries for the HEPEVT 
// fortran common block are explicitly defined to correspond to those 
// used in the Herwig version of the HEPEVT common block. 
// If you get funny output from HEPEVT in your own code, probably you have
// set these values incorrectly!
//

#include<fstream>

#ifdef _WIN32
  // to be removed when this header will come to HepMC
  #include "HerwigWrapper6_4_WIN32.h"
#else
  #include "HepMC/HerwigWrapper.h"
#endif

#include "HepMC/IO_HERWIG.h"
#include "HepMC/GenEvent.h"
#include "HepMC/HEPEVT_Wrapper.h"

#include "ANHEPMC/JetableInputFromHepMC.h"
#include "ANHEPMC/JetFinderUA.h"
#include "ANHEPMC/LeptonAnalyserHepMC.h"

#ifdef _WIN32
  #define hwaend_          HWAEND
  #define hwgethepevtsize_ HWGETHEPEVTSIZE
  #define hwsetmodbos_     HWSETMODBOS
  #define hwgetcs_         HWGETCS
  #define hwgetcserr_      HWGETCSERR

  extern "C" void __stdcall hwaend_ (void); // a dummy routine called on the termination of the run
  extern "C" {
    int    __stdcall hwgethepevtsize_(void);
    void   __stdcall hwsetmodbos_(int* i, int* ivalue);
    double __stdcall hwgetcs_(void);
    double __stdcall hwgetcserr_(void);
  }

  // a dummy user-supplied subroutine called when the run terminates:
  void __stdcall hwaend_ (void) { return; }

#else
  extern "C" void hwaend_ (void); // a dummy routine called on the termination of the run
  extern "C" {
    int hwgethepevtsize_(void);
    void hwsetmodbos_(int* i, int* ivalue);
    double hwgetcs_(void);
    double hwgetcserr_(void);
  }

  // a dummy user-supplied subroutine called when the run terminates:
  void hwaend_ (void) { return; }

#endif


// The sccess to modbos like below is problematic since hepevt size is used
// in this common block, and it could be different
//extern "C"
//{
// Electroweak boson common
//      PARAMETER (MODMAX=50)
//      COMMON/HWBOSC/ALPFAC,BRHIG(12),ENHANC(12),GAMMAX,RHOHEP(3,NMXHEP),
//     & IOPHIG,MODBOS(MODMAX)
//extern struct {double ALPFAC, BRHIG[12], ENHANC[12], GAMMAX;
//               double RHOHEP[4000][3];
//               int IOPHIG, MODBOS[50];} hwbosc_;
//}
//#define hwbosc hwbosc_

using namespace std;

int main() { 

unsigned int i, N_2lep_X, N_2lep_1jet, N_2lep_2jet;

JetableInputFromHepMC JI;
JetFinderUA JF;
LeptonAnalyserHepMC LA;

//
//........................................HEPEVT
// herwig-6510-0 uses HEPEVT with 10000 entries and 8-byte floating point
//  numbers. We need to explicitly pass this information to the 
//  HEPEVT_Wrapper.
//
HepMC::HEPEVT_Wrapper::set_max_number_entries(hwgethepevtsize_());
HepMC::HEPEVT_Wrapper::set_sizeof_real(8);
//
//.......................................INITIALIZATIONS

hwproc.PBEAM1 = 7000.; // energy of beam1
hwproc.PBEAM2 = 7000.; // energy of beam2
hwproc.IPROC  = 2150; // Z + jet production

// Assuming default PTMIN = 10 GeV

hwproc.MAXEV  = 1000; // number of events

// tell it what the beam particles are:
for (i = 0; i < 8; ++i ) {
    hwbmch.PART1[i] = (i < 1) ? 'P' : ' ';
    hwbmch.PART2[i] = (i < 1) ? 'P' : ' ';
}
hwigin();    // INITIALISE OTHER COMMON BLOCKS
//     Z decay modes, 5 e,mu, 15 e,mu,tau
//hwbosc.MODBOS[1-1] = 5;
//int imode=1, ivalue=15;
int imode=1, ivalue=15; // Z --> e+ e- + mu+ mu-
hwsetmodbos_(&imode, &ivalue); // should be after hwigin
hwevnt.MAXPR = 0; // number of events to print
hwuinc(); // compute parameter-dependent constants
hweini(); // initialise elementary process

//........................................HepMC INITIALIZATIONS
//
// Instantiate an IO strategy for reading from HEPEVT.
HepMC::IO_HERWIG hepevtio;
//
//........................................EVENT LOOP
for (i = 1,  N_2lep_X = N_2lep_1jet = N_2lep_2jet = 0; i <= hwproc.MAXEV; i++) {
    if (i % 50 == 1) 
        std::cout << "Processing Event Number " << i << std::endl;
// initialise event
    hwuine();
// generate hard subproces
    hwepro();
// generate parton cascades
    hwbgen();
// do heavy object decays
    hwdhob();
// do cluster formation
    hwcfor();
// do cluster decays
    hwcdec();
// do unstable particle decays
    hwdhad();
// do heavy flavour hadron decays
    hwdhvy();
// add soft underlying event if needed
    hwmevt();
// finish event
    hwufne();

    HepMC::GenEvent* evt = hepevtio.read_next_event();

// add some information to the event
    evt->set_event_number(i);
    evt->set_signal_process_id(20);

// Analysing the event:
    vector<JetableObject> objects = JI.readFromHepMC (evt);
    vector<Jet> alljets = JF.findJets (objects);
    vector<Jet>    jets = LA.removeLeptonsFromJets (alljets, evt);
    if (LA.nIsolatedLeptons (evt) >= 2) {
       N_2lep_X ++;
       if (jets.size() >= 1)
           N_2lep_1jet ++;
       if (jets.size() >= 2)
           N_2lep_2jet ++;
      }
    if (i <= hwevnt.MAXPR) {
       std::cout << "\n\n This is the FIXED version of HEPEVT as "
  	         << "coded in IO_HERWIG " << std::endl;
       HepMC::HEPEVT_Wrapper::print_hepevt();
       evt->print();
      }

	// we also need to delete the created event from memory
    delete evt;
 } // End of event loop

//........................................TERMINATION

double fr_2lep = (double)N_2lep_X / (double)hwproc.MAXEV;
double err_fr_2lep = fr_2lep / sqrt((double)N_2lep_X);
double fr_2lep_2jet = (double)N_2lep_2jet / (double)hwproc.MAXEV;
double err_fr_2lep_2jet=0.;
if(N_2lep_2jet) err_fr_2lep_2jet = fr_2lep_2jet / sqrt((double)N_2lep_2jet);

ofstream testi("testi.dat");

hwefin();

//sigma is the total cross section in pb:
double sigma = hwevnt.AVWGT;
double RNWGT = 1./(double)hwevnt.NWGTS;
double SPWGT = sqrt(max(hwevnt.WSQSUM*RNWGT - hwevnt.AVWGT*hwevnt.AVWGT , 0.));
double err_sigma = SPWGT*sqrt(RNWGT);

testi << "herwig_hepmc  3   " << hwgetcs_()  << "  " << hwgetcserr_() << endl
      << "herwig_hepmc  4   " << fr_2lep_2jet << "  " << err_fr_2lep_2jet << endl;

testi.close();
return 0;
}
