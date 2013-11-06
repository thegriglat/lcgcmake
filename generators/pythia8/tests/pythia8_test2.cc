// File: pythia8_test2.cc
//
//#@# 1: p p --> (Z,gamma* -> l+ l-) + jets cross section [mb] at LHC
//#@# 2: A fraction of events with 2 isolated leptons plus >=2 jets
//#@# This test reads LHE file Zg.lhe created by pythia8_test1
//#@# and hadronizes it
//#@# The file with parameters pythia8_test2.cmnd is used
//
#ifdef PYTHIA8NEWVERS
  #include "Pythia8/Pythia.h"
  #include "Pythia8/Pythia8ToHepMC.h"
#else
  #include "Pythia.h"
  #include "HepMCInterface.h"
#endif

#include "HepMC/GenEvent.h"
// Following line to be used with HepMC 2.04 onwards.
#include "HepMC/Units.h"

#include "AnalyserHepMC.h"

using namespace Pythia8;

//**************************************************************************

int main() {

#ifdef PYTHIA8NEWVERS
  HepMC::Pythia8ToHepMC ToHepMC;
#else
  HepMC::I_Pythia8 ToHepMC;
#endif

  AnalyserHepMC AHMC;
  AHMC.initialize();

  // Generator. Shorthand for the event and for settings.
  Pythia8::Pythia pythia;
  Event& event = pythia.event;
  Settings& settings = pythia.settings;

  // Read in commands from external file.
  pythia.readFile("pythia8_test2.cmnd");

  // Extract settings to be used in the main program.
  int nEvent = settings.mode("Main:numberOfEvents");
  int nList = settings.mode("Main:numberToList");
  int nShow = settings.mode("Main:timesToShow");
  int nAbort = settings.mode("Main:timesAllowErrors");
  bool showChangedSettings = settings.flag("Main:showChangedSettings");
  bool showAllSettings = settings.flag("Main:showAllSettings");
  bool showAllParticleData = settings.flag("Main:showAllParticleData");

  pythia.init("Zg.lhe");

  // Choose decay modes for Z0 : switch off everything but Z0 -> leptons.
  pythia.readString("23:onMode = off");
  pythia.readString("23:onIfAny = 11 13 15");

  // List changed data.
  if (showChangedSettings) settings.listChanged();
  if (showAllSettings) settings.listAll();

  // List particle data.  
  if (showAllParticleData) pythia.particleData.listAll();

  // Begin event loop.
  int nShowPace = max(1,nEvent/nShow); 
  int iAbort = 0; 
  for (int iEvent = 0; iEvent < nEvent; ++iEvent) {
    if (iEvent%nShowPace == 0) cout << " Now begin event " 
      << iEvent << endl;

    // Generate events. Quit if too many failures.
    if (!pythia.next()) {
      if (++iAbort < nAbort) continue;
      cout << " Event generation aborted prematurely, owing to error!\n"; 
      break;
    }
 
    // List first few events, both hard process and complete events.
    if (iEvent < nList) { 
      pythia.LHAeventList();
      pythia.info.list();
      pythia.process.list();
      event.list();
    }

    // HepMC installed on CERN AFS by default have MeV as energy units
    // (ATLAS standard...), though default HepMC units are GeV. For
    // this reason, if the first line below is used, in pythia8
    // versions > 165 HepMC record will be in MeV
    // and we will have incorrect results
    
    //HepMC::GenEvent* hepmcevt = new HepMC::GenEvent();
    HepMC::GenEvent* hepmcevt =
      new HepMC::GenEvent(HepMC::Units::GEV, HepMC::Units::MM);
        
    ToHepMC.fill_next_event( event, hepmcevt );
    AHMC.analyse(hepmcevt);  

    delete hepmcevt;

  // End of event loop.
  }

  // Final statistics.
  pythia.statistics();

  ofstream testi("testi.dat");
  double val, errval;
  val = pythia.info.sigmaGen();
  errval = 0.;
  if(nEvent > 0) errval = val/sqrt( (double)(nEvent) );
  testi << "pythia8_test2  1   " << val << " " << errval << " " << endl;

  AHMC.endRun(val, errval);

  testi << "pythia8_test2  2   " << val << " " << errval << " " << endl;

  // Done.
  return 0;
}
