//#@# 1: p p --> (Z,gamma* -> l+ l-) + jets cross section [mb] at LHC
//#@# 2: A ratio N(50 < P_T < 120)/N(20 < P_T < 30) 
//#@# Ratio obtained with pythia8 (version 153) is 0.42+-0.01 (100K events)
//#@# This test reads LHE file z-events.lhe created by powheg-box
//#@# and hadronizes it
//#@# The file with parameters powhegbox.cmnd is used
//
#include "Pythia.h"

#include "HepMCInterface.h"

#include "HepMC/GenEvent.h"

#include "ANHEPMC/JetableInputFromHepMC.h"
#include "ANHEPMC/JetFinderUA.h"
#include "ANHEPMC/LeptonAnalyserHepMC.h"

using namespace Pythia8; 

//**************************************************************************

int main() {

  double pt[2], pt_abs, num, denom, ratio, err_ratio; 
  double MaxEta = 5.;

  HepMC::I_Pythia8 ToHepMC;
  JetableInputFromHepMC JI;
  JetFinderUA JF;
  LeptonAnalyserHepMC LA;
  int nevtype[4] = {0,0,0,0};


  // Generator. Shorthand for the event and for settings.
  Pythia8::Pythia pythia;
  Event& event = pythia.event;
  Settings& settings = pythia.settings;

  // Read in commands from external file.
  pythia.readFile("powhegbox.cmnd");

  // Extract settings to be used in the main program.
  int nEvent = settings.mode("Main:numberOfEvents");
  int nList = settings.mode("Main:numberToList");
  int nShow = settings.mode("Main:timesToShow");
  int nAbort = settings.mode("Main:timesAllowErrors");
  bool showChangedSettings = settings.flag("Main:showChangedSettings");
  bool showAllSettings = settings.flag("Main:showAllSettings");
  bool showAllParticleData = settings.flag("Main:showAllParticleData");

  pythia.init("z-events.lhe");

  // List changed data.
  if (showChangedSettings) settings.listChanged();
  if (showAllSettings) settings.listAll();

  // List particle data.  
  if (showAllParticleData) pythia.particleData.listAll();



  //variables for GENSER test  
  num = 0.;
  denom = 0;
  err_ratio = 0.;



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

    HepMC::GenEvent* hepmcevt = new HepMC::GenEvent();
    ToHepMC.fill_next_event( event, hepmcevt );
    vector<JetableObject> objects = JI.readFromHepMC(hepmcevt);
    //cout << "size of jetable objects = " << objects.size() << endl;
    vector<Jet> alljets = JF.findJets(objects);
    //cout << "size of all jets = " << alljets.size() << endl;
    int nisolep = LA.nIsolatedLeptons(hepmcevt);
    //cout << "size of isolated leptons = " << nisolep << endl;
    if (nisolep == 2) nevtype[0]++;
    vector<Jet> jets = LA.removeLeptonsFromJets(alljets, hepmcevt);
    //cout << "size of jets = " << jets.size() << endl;
    if( jets.size() >= 2) nevtype[1]++;
    if (nisolep == 2 && jets.size() >= 1) nevtype[2]++;
    if (nisolep == 2 && jets.size() >= 2) nevtype[3]++;


    //calculate PT

    for(HepMC::GenEvent::particle_iterator part = hepmcevt->particles_begin();
      part != hepmcevt->particles_end(); ++part ) {

      if ( fabs((*part)->momentum().eta()) > MaxEta ) continue;
    
      pt_abs = 0.;
      if ( abs((*part)->pdg_id()) == 23) {

        pt[0] = (*part)->momentum().px();
        pt[1] = (*part)->momentum().py();
	pt_abs = pow( (pt[0]*pt[0] + pt[1]*pt[1]), 0.5 );
	
	//calculate ratio for GENSER test
	//ratio = N(50 < PT < 120) / N(20 < PT < 30)
	if(pt_abs > 50 && pt_abs < 120) num++;
	if(pt_abs > 20 && pt_abs < 30) denom++;

	if(pt_abs > 0) break;
      }

    }

    delete hepmcevt;

  // End of event loop.
  }



  //calculate ratio for GENSER test
  //ratio = N(50 < PT < 120) / N(20 < PT < 30)
  ratio = num /denom;
  err_ratio = ratio * pow( (1./num + 1./denom), 0.5);
  cout << "ratio = " << ratio << " error: " <<err_ratio << endl;




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
  testi << "powhegbox_test1  1   " << val << " " << errval << " " << endl;

  val = ratio;
  errval = err_ratio;
  testi << "powhegbox_test1  2   " << val << " " << errval << " " << endl;







  // Done.
  return 0;
}
