#include "HepMC/GenEvent.h"
#include "HepMC/IO_GenEvent.h"
//#include "HepMC/IO_AsciiParticles.h"

#include "ANHEPMC/Jet.h"
#include "ANHEPMC/JetableInputFromHepMC.h"
#include "ANHEPMC/JetFinderUA.h"
#include "ANHEPMC/LeptonAnalyserHepMC.h"

using namespace std;

int main(int argc, char** argv)
{
  if (argc < 2) {
    cerr << "readsherpa: Input file not specified! Exit." << endl;
    return 1;
  }

  // Specify HepMC input file
  HepMC::IO_GenEvent genevent_io(argv[1], std::ios::in);
  


  JetableInputFromHepMC JI;
  JetFinderUA JF;
  LeptonAnalyserHepMC LA;
  int nevtype[5] = {0};
  const int NEvents = 2000;

  double ET;
  
  for (int iEvent = 0; iEvent < NEvents; ++iEvent) {
    if (iEvent % 100 == 0) std::cout << "iEvent: " << iEvent << std::endl;
    HepMC::GenEvent* hepmcevt = new HepMC::GenEvent();
    genevent_io >> hepmcevt;
    
    if (genevent_io.rdstate()) {
      cerr << "readsherpa: error reading event " << iEvent << "! Exit" << endl;
      return 1;
    }



    vector<JetableObject> objects = JI.readFromHepMC(hepmcevt);
    // cout << "size of jetable objects = " << objects.size() << endl;
    vector<Jet> alljets = JF.findJets(objects);
    // cout << "size of all jets = " << alljets.size() << endl;
    int nisolep = LA.nIsolatedLeptons(hepmcevt);
    // cout << "size of isolated leptons = " << nisolep << endl;
    if (nisolep == 2) nevtype[0]++;
    vector<Jet> jets = LA.removeLeptonsFromJets(alljets, hepmcevt);
    // cout << "size of jets = " << jets.size() << endl;

    ET = JI.getETMissMod();

 
    if( jets.size() >= 2) nevtype[1]++;
    if (nisolep == 2 && jets.size() >= 1) nevtype[2]++;
    if (nisolep == 1 && jets.size() >= 2) nevtype[3]++;
    if (nisolep == 1 && jets.size() >= 2 && ET>20) nevtype[4]++;
    delete hepmcevt;
  }

  cout << "2 isolated leptons              " << nevtype[0] << endl;
  cout << "2+ (2 or more) jets             " << nevtype[1] << endl;
  cout << "2 isolated leptons and 1+ jets  " << nevtype[2] << endl;
  cout << "1 isolated lepton and 2+ jets  " << nevtype[3] << endl;
  cout << "1 isolated lepton and 2+ jets with ET>20  " << nevtype[4] << endl;

  //reading cross section from external file
  ifstream xsec("Sherpa/xsec.out");
  double x_tot, err_x_tot;
  xsec >> x_tot >> err_x_tot;
  cout <<"cross section and error from file  " << x_tot <<"  " << err_x_tot << endl;

  ofstream testi("testi.dat");
  double val, errval;
  val = ((double)nevtype[4])/((double)NEvents);
  errval = 0.;
  if(nevtype[4] > 0) errval = val/sqrt((double)nevtype[4]);
  testi << "sherpa_test2  2   " << val << " " << errval << endl;
  testi << "sherpa_test2  3   " << val*x_tot << " " << val*x_tot*pow( (errval/val*errval/val + err_x_tot/x_tot*err_x_tot/x_tot),0.5) << " " << endl;

  return 0;
}
