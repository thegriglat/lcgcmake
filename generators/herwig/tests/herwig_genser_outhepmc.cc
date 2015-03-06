//#@# This example uses HepMC event interface.
//#@# It simulates Z+jets and writes events in a file in HepMC format
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
#include "HepMC/IO_GenEvent.h"

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


// The access to modbos like below is problematic since hepevt size is used
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

int main(int argc, char* argv[]) {

  // Check that correct number of command-line arguments
  if (argc != 3) {
    cerr << " Unexpected number of command-line arguments. \n You are"
         << " expected to provide Nevents and output file name. \n"
         << " Program stopped! " << endl;
    return 1;
  }

  unsigned int i, N_2lep_X, N_2lep_1jet, N_2lep_2jet;

//
//  ........................................HEPEVT
//  herwig-6510-0 uses HEPEVT with 10000 entries and 8-byte floating point
//  numbers. We need to explicitly pass this information to the 
//  HEPEVT_Wrapper.
//
  HepMC::HEPEVT_Wrapper::set_max_number_entries(hwgethepevtsize_());
  HepMC::HEPEVT_Wrapper::set_sizeof_real(8);

  // Specify file where HepMC events will be stored.
  HepMC::IO_GenEvent ascii_io(argv[2], std::ios::out);

//
//.......................................INITIALIZATIONS

  hwproc.PBEAM1 = 6500.; // energy of beam1
  hwproc.PBEAM2 = 6500.; // energy of beam2
  hwproc.IPROC  = 2150; // Z + jet production

// Assuming default PTMIN = 10 GeV

  hwproc.MAXEV  = atoi(argv[1]); // number of events

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

// Make this call for the last event to have correct cross section in the output file:
    if(i == hwproc.MAXEV) hwefin();

    HepMC::GenEvent* evt = hepevtio.read_next_event();

// add some information to the event
    evt->set_event_number(i);
    evt->set_signal_process_id(20);
    HepMC::GenCrossSection xsec;
    //double cs = hwevnt.AVWGT; // cross section in pb
    //double RNWGT = 1./(double)hwevnt.NWGTS;
    //double SPWGT = sqrt(max(hwevnt.WSQSUM*RNWGT - hwevnt.AVWGT*hwevnt.AVWGT , 0.));
    //double cserr = SPWGT*sqrt(RNWGT);
    double cs = 1000.*hwgetcs_();
    double cserr = 1000.*hwgetcserr_();
    xsec.set_cross_section(cs, cserr);
    evt->set_cross_section(xsec);

    // write the event out to the ascii file
    ascii_io << evt;

// Printout:
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

  hwefin();

  cout << endl << "cs [pb] = " << 1000.*hwgetcs_()  << " +- " << 1000.*hwgetcserr_() << endl << endl;

  return 0;
}
