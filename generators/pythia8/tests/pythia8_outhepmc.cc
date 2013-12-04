// File: pythia8_outhepmc.cc
//
//#@# 1: p p --> (Z,gamma* -> l+ l-) is simulated, converted to hepmc and written in a file
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
#include "HepMC/IO_GenEvent.h"   

using namespace Pythia8; 

//**************************************************************************

int main() {

#ifdef PYTHIA8NEWVERS   
  HepMC::Pythia8ToHepMC ToHepMC;
#else
  HepMC::I_Pythia8 ToHepMC;
#endif

  // Specify file where HepMC events will be stored.
  HepMC::IO_GenEvent ascii_io("hepmcoutzjets_pythia8.dat", std::ios::out);

  // Generator. Process selection.
  Pythia pythia;
  pythia.readString("Main:numberOfEvents = 1000");
  pythia.readString("WeakBosonAndParton:qqbar2gmZg = on");
  pythia.readString("WeakBosonAndParton:qg2gmZq = on");
  pythia.readString("PhaseSpace:pTHatMin = 20.");

  // suppress full listing of first events in pythia8 > 160
  pythia.readString("Next:numberShowEvent = 0");

  //LHC initialization.
  pythia.init( 2212, 2212, 14000.);

  // Choose decay modes for Z0 : switch off everything but Z0 -> leptons.
  pythia.readString("23:onMode = off");
  pythia.readString("23:onIfAny = 11 13 15");

  // Shorthand for the event and for settings.
  Event& event = pythia.event;
  Settings& settings = pythia.settings;

  // Extract settings to be used in the main program.
  int nEvent = settings.mode("Main:numberOfEvents");
  int nList = settings.mode("Main:numberToList");
  int nShow = settings.mode("Main:timesToShow");
  int nAbort = settings.mode("Main:timesAllowErrors");
  bool showChangedSettings = settings.flag("Main:showChangedSettings");
  bool showAllSettings = settings.flag("Main:showAllSettings");
  bool showAllParticleData = settings.flag("Main:showAllParticleData");

  // List changed data.
  if (showChangedSettings) settings.listChanged();
  if (showAllSettings) settings.listAll();

  // List particle data.  
//  if (showAllParticleData) ParticleDataTable::listAll();
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
//      pythia.process.list();
//      event.list();
    }

    // HepMC installed on CERN AFS by default have MeV as energy units
    // (ATLAS standard...), though default HepMC units are GeV. For 
    // this reason, if the first line below is used, in pythia8
    // versions > 165 HepMC record will be in MeV
    // and we will have incorrect results

    //HepMC::GenEvent* hepmcevt = new HepMC::GenEvent();
    HepMC::GenEvent* hepmcevt =
      new HepMC::GenEvent(HepMC::Units::GEV, HepMC::Units::MM);

    //ToHepMC.fill_next_event( event, hepmcevt );
    ToHepMC.fill_next_event( pythia, hepmcevt ); // this fills PDF etc.

    ascii_io << hepmcevt;

    delete hepmcevt;

  // End of event loop.
  }

  // Final statistics.
  pythia.statistics();

  // Done.
  return 0;
}
