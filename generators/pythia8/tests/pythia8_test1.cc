// File: pythia8_test1.cc
//
//#@# 1: p p --> (Z,gamma* -> l+ l-) + jets cross section [mb] at LHC
//#@# 2: A fraction of events with 2 isolated leptons plus >=2 jets
//#@# 3: 1+(max. pz nonconservation, GeV). The error is fixed 
//#@# 4: 0.01+(max. px, py nonconservation, GeV). The error is fixed
//#@# 5: Average final state particles multiplicity
//#@# 6: Average final state charged particles multiplicity
//#@# This test creates LHE file Zg_pythia8.lhe
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

  // Generator. Process selection.
  Pythia pythia;
  pythia.readString("Main:numberOfEvents = 1000");
  pythia.readString("WeakBosonAndParton:qqbar2gmZg = on");
  pythia.readString("WeakBosonAndParton:qg2gmZq = on");
  pythia.readString("PhaseSpace:pTHatMin = 20.");

  // suppress full listing of first events in pythia8 > 160
  pythia.readString("Next:numberShowEvent = 0");

  // Create an LHAup object that can access relevant information in pythia.
  LHAupFromPYTHIA8 myLHA(&pythia.process, &pythia.info);
  // Open a file on which LHEF events should be stored, and write header.
  myLHA.openLHEF("Zg_pythia8.lhe");

  //LHC initialization.
  pythia.init( 2212, 2212, 14000.);

  // Choose decay modes for Z0 : switch off everything but Z0 -> leptons.
  pythia.readString("23:onMode = off");
  pythia.readString("23:onIfAny = 11 13 15");

  // Store initialization info in the LHAup object.
  myLHA.setInit();
  // Write out this initialization info on the file.
  myLHA.initLHEF();

  // Shorthand for the event and for settings.
  Event& event = pythia.event;
  Settings& settings = pythia.settings;

  // Read in commands from external file.
  //pythia.readFile("pythia8_test1.cmnd");

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
  double pdevmaxz=0.;
  double pdevmaxxy=0.;
  double nFinAverage = 0.;
  double nChAverage = 0.;
  double nFinSqAverage = 0.;
  double nChSqAverage = 0.;
  for (int iEvent = 0; iEvent < nEvent; ++iEvent) {
    if (iEvent%nShowPace == 0) cout << " Now begin event " 
      << iEvent << endl;

    // Generate events. Quit if too many failures.
    if (!pythia.next()) {
      if (++iAbort < nAbort) continue;
      cout << " Event generation aborted prematurely, owing to error!\n"; 
      break;
    }
 
    // Store event info in the LHAup object.
    myLHA.setEvent();
    // Write out this event info on the file.
    myLHA.eventLHEF();

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

    ToHepMC.fill_next_event( event, hepmcevt );
    AHMC.analyse(hepmcevt);

    delete hepmcevt;

    // Reset quantities to be summed over event.
    int nfin = 0;
    int nch = 0;
    Vec4 pSum = - (event[1].p() + event[2].p());

    // Loop over particles in the event.
    for (int i = 0; i < event.size(); ++i) {
      // Specialize to final particles. Total multiplicity and momentum.
      if (event[i].status() > 0) {
        ++nfin;
        if (event[i].isCharged()) ++nch;
        pSum += event[i].p();
      // End of loop over (final/all) particles.
      }
    }
    if(fabs(pSum.pz()) > pdevmaxz) pdevmaxz = fabs(pSum.pz());
    if(fabs(pSum.px()) > pdevmaxxy) pdevmaxxy = fabs(pSum.px());
    if(fabs(pSum.py()) > pdevmaxxy) pdevmaxxy = fabs(pSum.py());

    nFinAverage += (double)nfin;
    nChAverage += (double)nch;
    nFinSqAverage += (double)(nfin*nfin);
    nChSqAverage += (double)(nch*nch);

  // End of event loop.
  }

  // Final statistics.
  pythia.statistics();

  // Update the cross section info based on Monte Carlo integration during run.
  myLHA.updateSigma();
  // Write endtag. Overwrite initialization info with new cross sections.
  myLHA.closeLHEF(true);

  cout << endl;
  cout << " max nonconservation of pz = " << pdevmaxz << endl;
  cout << " max nonconservation of pxy = " << pdevmaxxy << endl;

  nFinAverage /= ((double)nEvent);
  nChAverage /= ((double)nEvent);
  nFinSqAverage /= ((double)nEvent);
  nChSqAverage /= ((double)nEvent);

  ofstream testi("testi_pythia8.dat");
  double val, errval;

  val = pythia.info.sigmaGen();

  errval = 0.;
  if(nEvent > 0) errval = val/sqrt( (double)(nEvent) );
  testi << "pythia8_test1  1   " << val << " " << errval << " " << endl;

  AHMC.endRun(val, errval);

  testi << "pythia8_test1  2   " << val << " " << errval << " " << endl;

  val = 1.+pdevmaxz;
  errval = 0.0001;
  testi << "pythia8_test1  3   " << val << " " << errval << " " << endl;

  val = 0.01+pdevmaxxy;
  errval = 0.000005;
  testi << "pythia8_test1  4   " << val << " " << errval << " " << endl;

  val = nFinAverage;
  errval = sqrt(nFinSqAverage - nFinAverage*nFinAverage) / sqrt((double)nEvent);
  testi << "pythia8_test1  5   " << val << " " << 2.5*errval << " " << endl;

  val = nChAverage;
  errval = sqrt(nChSqAverage - nChAverage*nChAverage) / sqrt((double)nEvent);
  testi << "pythia8_test1  6   " << val << " " << 2.5*errval << " " << endl;

  // Done.
  return 0;
}
