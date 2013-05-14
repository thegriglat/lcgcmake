#include "HepMC/GenEvent.h"

#include "ANHEPMC/JetableInputFromHepMC.h"
#include "ANHEPMC/JetFinderUA.h"
#include "ANHEPMC/LeptonAnalyserHepMC.h"

#include <fstream>
using namespace std;

int main(int argc, char** argv)
{
  if (argc < 2) {
    cerr << "ERROR: input file is not specified" << endl;
    return 1;
  }
  
  // Specify HepMC input file
  ifstream is(argv[1]);
  
  if (!is) {
    cerr << "ERROR: failed to open input file: " << argv[1] << endl;
    return 1;
  }
  
  JetableInputFromHepMC JI;
  JetFinderUA JF;
  LeptonAnalyserHepMC LA;
  int nevtype[4] = {0};
  
  // create an empty event
  HepMC::GenEvent* hepmcevt = new HepMC::GenEvent;
  const int NEvents = 2000;
  
  for (int iEvent = 0; iEvent < NEvents; ++iEvent) {
    if (iEvent % 100 == 0) cout << "iEvent: " << iEvent << endl;
    hepmcevt->read(is);
    
    if (! is.good()) {
      cerr << "ERROR: failed to read event from the input stream" << endl;
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
    if( jets.size() >= 2) nevtype[1]++;
    if (nisolep == 2 && jets.size() >= 1) nevtype[2]++;
    if (nisolep == 2 && jets.size() >= 2) nevtype[3]++;
  }
  
  delete hepmcevt;

  cout << "Total events                    " << NEvents << endl;
  cout << "2 isolated leptons              " << nevtype[0] << endl;
  cout << "2+ (2 or more) jets             " << nevtype[1] << endl;
  cout << "2 isolated leptons and 1+ jets  " << nevtype[2] << endl;
  cout << "2 isolated leptons and 2+ jets  " << nevtype[3] << endl;

  ofstream testi("testi.dat");
  double val, errval;
  val = ((double)nevtype[3])/((double)NEvents);
  errval = 0.;
  if(nevtype[3] > 0) errval = val/sqrt((double)nevtype[3]);
  testi << "herwigpp_test1  2   " << val << " " << errval << " " << endl;

  return 0;
}
