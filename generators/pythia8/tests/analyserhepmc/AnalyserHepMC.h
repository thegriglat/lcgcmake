#include "HepMC/GenEvent.h"
#include "LeptonAnalyserHepMC.h"
#include "JetInputHepMC.h"
#include <fastjet/PseudoJet.hh>
#include <fastjet/JetDefinition.hh>
#include <fastjet/ClusterSequence.hh>

#include <vector>


class AnalyserHepMC {

public:
  AnalyserHepMC();
  void initialize();
  void analyse(const HepMC::GenEvent* pEv);
  void endRun(double &, double &);

private:
  LeptonAnalyserHepMC LA;
  JetInputHepMC JetInput;
  fastjet::Strategy strategy;
  fastjet::RecombinationScheme recombScheme;
  fastjet::JetDefinition* jetDef;

  int icategories[6];
};
