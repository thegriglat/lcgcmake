// File: pythia8_test2.cc
// This is a simple test program. 
// It illustrates how Pythia6 processes can be used in Pythia8.
// All input is specified in the pythia8_test2.cmnd file.
// Copyright © 2005 Torbjörn Sjöstrand
//
//#@# 1: p p --> (Z,gamma* -> l+ l-) + jets cross section [mb] at LHC
//#@# 2: A fraction of events with 2 isolated leptons plus >=2 jets
//#@# This test reads LHE file Zg.lhe created by pythia8_test1
//#@# and hadronizes it
//#@# The file with parameters pythia8_test2.cmnd is used
//
#include "Pythia.h"

#include "HepMCInterface.h"

#include "HepMC/GenEvent.h"
// Following line to be used with HepMC 2.04 onwards.
#ifdef HEPMC_HAS_UNITS
#include "HepMC/Units.h"
#endif

#include "ANHEPMC/JetableInputFromHepMC.h"
#include "ANHEPMC/JetFinderUA.h"
#include "ANHEPMC/LeptonAnalyserHepMC.h"

using namespace Pythia8; 

//**************************************************************************

int main() {

  HepMC::I_Pythia8 ToHepMC;
#ifndef HEPMC_HAS_UNITS
  // To have HepMC record in GeV with HepMC 2.03.11.
  // Will work for pythia8 > 165
  ToHepMC.set_convert_to_mev(false);
#endif
  JetableInputFromHepMC JI;
  JetFinderUA JF;
  LeptonAnalyserHepMC LA;
  int nevtype[4] = {0,0,0,0};

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
    // (damned ATLAS standard), though default HepMC units are GeV. For
    // this reason, if the first line below is used, in pythia8
    // versions > 165 HepMC record will be in MeV
    // and we will have incorrect results
#ifdef HEPMC_HAS_UNITS   
    //HepMC::GenEvent* hepmcevt = new HepMC::GenEvent();
    HepMC::GenEvent* hepmcevt =
      new HepMC::GenEvent(HepMC::Units::GEV, HepMC::Units::MM);
#else
    HepMC::GenEvent* hepmcevt = new HepMC::GenEvent();
#endif

    ToHepMC.fill_next_event( event, hepmcevt );
    vector<JetableObject> objects = JI.readFromHepMC(hepmcevt);
//    cout << "size of jetable objects = " << objects.size() << endl;
    vector<Jet> alljets = JF.findJets(objects);
//    cout << "size of all jets = " << alljets.size() << endl;
    int nisolep = LA.nIsolatedLeptons(hepmcevt);
//    cout << "size of isolated leptons = " << nisolep << endl;
    if (nisolep == 2) nevtype[0]++;
    vector<Jet> jets = LA.removeLeptonsFromJets(alljets, hepmcevt);
//    cout << "size of jets = " << jets.size() << endl;
    if( jets.size() >= 2) nevtype[1]++;
    if (nisolep == 2 && jets.size() >= 1) nevtype[2]++;
    if (nisolep == 2 && jets.size() >= 2) nevtype[3]++;
    delete hepmcevt;

  // End of event loop.
  }

  // Final statistics.
  pythia.statistics();

  cout << "2 isolated leptons              " << nevtype[0] << endl;
  cout << "2+ (2 or more) jets             " << nevtype[1] << endl;
  cout << "2 isolated leptons and 1+ jets  " << nevtype[2] << endl;
  cout << "2 isolated leptons and 2+ jets  " << nevtype[3] << endl;

  ofstream testi("testi.dat");
  double val, errval;
  val = pythia.info.sigmaGen();
  errval = 0.;
  if(nEvent > 0) errval = val/sqrt( (double)(nEvent) );
  testi << "pythia8_test2  1   " << val << " " << errval << " " << endl;

  val = ((double)nevtype[3])/((double)nEvent);
  errval = 0.;
  if(nevtype[3] > 0) errval = val/sqrt((double)nevtype[3]);
  testi << "pythia8_test2  2   " << val << " " << errval << " " << endl;

  // Done.
  return 0;
}
