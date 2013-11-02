#include "AnalyserHepMC.h"

struct ParticlePtGreater {
  double operator () (const HepMC::GenParticle *v1,  
                                  const HepMC::GenParticle *v2)
  { return v1->momentum().perp() > v2->momentum().perp(); }
};


AnalyserHepMC::AnalyserHepMC()
{;}


void AnalyserHepMC::initialize()
{
  double Rparam = 0.5;
  strategy = fastjet::Best;
  recombScheme = fastjet::E_scheme;
  jetDef = new fastjet::JetDefinition(fastjet::antikt_algorithm, Rparam,
                                      recombScheme, strategy);

  for (int ind=0; ind < 6; ind++) {icategories[ind]=0;}
 
  return ;
}


void AnalyserHepMC::analyse(const HepMC::GenEvent* Evt)
{
  icategories[0]++;

  int nisolep = LA.nIsolatedLeptons(Evt);

  //std::cout << "Number of leptons = " << nisolep << std::endl;
  if(nisolep > 0) icategories[1]++;
  if(nisolep > 1) icategories[2]++;

  JetInputHepMC::ParticleVector jetInput = JetInput(Evt);
  std::sort(jetInput.begin(), jetInput.end(), ParticlePtGreater());

  //std::cout << "Size of jet input = " << jetInput.size() << std::endl;

  // Fastjet input
  std::vector <fastjet::PseudoJet> jfInput;
  jfInput.reserve(jetInput.size());
  for (JetInputHepMC::ParticleVector::const_iterator iter = jetInput.begin();
       iter != jetInput.end(); ++iter) {
    jfInput.push_back(fastjet::PseudoJet( (*iter)->momentum().px(),
                                          (*iter)->momentum().py(),
                                          (*iter)->momentum().pz(),
                                          (*iter)->momentum().e()  )  );
    jfInput.back().set_user_index(iter - jetInput.begin());
  }

  // Run Fastjet algorithm
  std::vector <fastjet::PseudoJet> inclusiveJets, sortedJets, cleanedJets;
  fastjet::ClusterSequence clustSeq(jfInput, *jetDef);
  
  // Extract inclusive jets sorted by pT (note minimum pT in GeV)
  inclusiveJets = clustSeq.inclusive_jets(20.0);
  sortedJets    = sorted_by_pt(inclusiveJets);
       
  //std::cout << "Size of jets = " << sortedJets.size() << std::endl;

  cleanedJets = LA.removeLeptonsFromJets(sortedJets, Evt);
                                          
  //std::cout << "Size of cleaned jets = " << cleanedJets.size() << std::endl;
  if(nisolep > 1) {
    if(cleanedJets.size() > 0) icategories[3]++;
    if(cleanedJets.size() > 1) icategories[4]++;
  }
  
  return ;

}


void AnalyserHepMC::endRun(double& outval, double& outerrval)
{
//  ofstream testi("testi.dat");
  double val, errval;

  std::cout << std::endl;
  std::cout << " Events with at least 1 isolated lepton  :                     "
            << ((double)icategories[1])/((double)icategories[0]) << std::endl;
  std::cout << " Events with at least 2 isolated leptons :                     "
            << ((double)icategories[2])/((double)icategories[0]) << std::endl;
  std::cout << " Events with at least 2 isolated leptons and at least 1 jet  : "
            << ((double)icategories[3])/((double)icategories[0]) << std::endl;
  std::cout << " Events with at least 2 isolated leptons and at least 2 jets : "
            << ((double)icategories[4])/((double)icategories[0]) << std::endl;
  std::cout << std::endl;
  
  val = ((double)icategories[4])/((double)icategories[0]);
  errval = 0.;
  if(icategories[4] > 0) errval = val/sqrt((double)icategories[4]);
  outval = val;
  outerrval = errval;
//  testi << "pythia8_test1  2   " << val << " " << errval << " " << std::endl;
  
}
