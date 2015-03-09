// File: lhapdf6_pyt8.cc
//
//#@# 1: p p --> (Z,gamma* -> l+ l-) + jets cross section [mb] at LHC
//#@#
//#@# Tune is fixed to the default tune in pythia8 1XX: Tune:ee = 3 Tune:pp = 5
//
#include "Pythia8/Pythia.h"

using namespace Pythia8; 

//**************************************************************************

int main() {

  // Generator. Process selection.
  Pythia pythia;
  pythia.readString("Main:numberOfEvents = 1000");
  pythia.readString("WeakBosonAndParton:qqbar2gmZg = on");
  pythia.readString("WeakBosonAndParton:qg2gmZq = on");
  pythia.readString("PhaseSpace:pTHatMin = 20.");
  pythia.readString("Tune:ee = 3");
  pythia.readString("Tune:pp = 5");

#ifdef PYTHIA8200
  pythia.readString("PDF:pSet = LHAPDF6:CT10");
#else
  pythia.readString("PDF:useLHAPDF = on");
  pythia.readString("PDF:LHAPDFset = CT10");
#endif

  // suppress full listing of first events in pythia8 > 160
  pythia.readString("Next:numberShowEvent = 0");

  //LHC initialization.
#ifdef PYTHIA8200
  pythia.readString("Beams:eCM = 14000.");
  pythia.init();
#else
  pythia.init( 2212, 2212, 14000.);
#endif

  // Choose decay modes for Z0 : switch off everything but Z0 -> leptons.
  pythia.readString("23:onMode = off");
  pythia.readString("23:onIfAny = 11 13 15");

  // Shorthand for the event and for settings.
  Event& event = pythia.event;
  Settings& settings = pythia.settings;

  // Read in commands from external file.
  //pythia.readFile("pythia8_test1.cmnd");

  // Extract settings to be used in the main program.
  int nEvent = settings.mode("Main:numberOfEvents");
  int nList = settings.mode("Next:numberShowEvent");
  int nShow = settings.mode("Next:numberCount");
  int nAbort = settings.mode("Main:timesAllowErrors");
  bool showChangedSettings = settings.flag("Init:showChangedSettings");
  bool showAllSettings = settings.flag("Main:showAllSettings");
  bool showAllParticleData = settings.flag("Main:showAllParticleData");

  // List changed data.
  if (showChangedSettings) settings.listChanged();
  if (showAllSettings) settings.listAll();

  // List particle data.  
  if (showAllParticleData) pythia.particleData.listAll();

  // Begin event loop.
  int nShowPace = max(1,nShow);
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
 
    // List first few events, both hard process and complete events.
    if (iEvent < nList) { 
//      pythia.process.list();
//      event.list();
    }

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
#ifdef PYTHIA8200
  pythia.stat();
#else
  pythia.statistics();
#endif

  nFinAverage /= ((double)nEvent);
  nChAverage /= ((double)nEvent);
  nFinSqAverage /= ((double)nEvent);
  nChSqAverage /= ((double)nEvent);

  ofstream testi("testi_lhapdf6.dat");
  double val, errval;

  val = pythia.info.sigmaGen();

  errval = 0.;
  if(nEvent > 0) errval = val/sqrt( (double)(nEvent) );
  testi << "lhapdf6_pyt8 1   " << val << " " << errval << " " << endl;

  // Done.
  return 0;
}
