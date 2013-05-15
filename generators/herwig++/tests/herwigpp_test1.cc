//#@#  1: p p --> (gamma*,Z -> l+ l-) X total cross-section [mb] at LHC
//#@#  2: Event fraction for: 2 isolated leptons + >=2 jets
// -*- C++ -*-
//
// Herwig++ is licenced under version 2 of the GPL, see COPYING for details.
// Please respect the MCnet academic guidelines, see GUIDELINES for details.
//
//
// This is the implementation of the non-inlined, non-templated member
// functions of the GTestAnalysis class.
//

#include "herwigpp_test1.h"
#include "ThePEG/Interface/ParVector.h"
#include "ThePEG/Interface/Switch.h"
#include "ThePEG/Interface/ClassDocumentation.h"
#include "ThePEG/EventRecord/StandardSelectors.h"
#include "ThePEG/EventRecord/Event.h"
#include "ThePEG/Persistency/PersistentOStream.h"
#include "ThePEG/Persistency/PersistentIStream.h"
#include "Herwig++/Utilities/EnumParticles.h"
#include "Herwig++/Hadronization/Cluster.h"

#include "ThePEG/Vectors/HepMCConverter.h"

#include <iostream>
#include <sstream>
#include <fstream>

/**/
namespace ThePEG {
template<>
struct HepMCTraits<HepMC::GenEvent>
  : public HepMCTraitsBase<     HepMC::GenEvent,
				HepMC::GenParticle,
				HepMC::GenVertex,
				HepMC::Polarization 
#if HERWIGPP_VERSION >= 230
				, HepMC::PdfInfo      
#endif
			  >
{};
}
/**/

using namespace Herwig;
using namespace ThePEG;

using namespace GTest;


GTestAnalysis::GTestAnalysis() : fhepmc(0)
{
//  nevtype[0]=0;
//  nevtype[1]=0;
//  nevtype[2]=0;
//  nevtype[3]=0;
//  JI = new JetableInputFromHepMC;
//  JF = new JetFinderUA;
//  LA = new LeptonAnalyserHepMC;
}


namespace {
  bool isLastCluster(tcPPtr p) {
    if ( p->id() != ExtraParticleID::Cluster ) 
      return false;
    for ( size_t i = 0, end = p->children().size();
	  i < end; ++i ) {
      if ( p->children()[i]->id() == ExtraParticleID::Cluster )
	return false;
    }
    return true;
  }

  Energy parentClusterMass(tcPPtr p) {
    if (p->parents().empty()) 
      return -1.0*MeV;

    tcPPtr parent = p->parents()[0];
    if (parent->id() == ExtraParticleID::Cluster) {
      if ( isLastCluster(parent) )
	return parent->mass();
      else
	return p->mass();
    }
    else
      return parentClusterMass(parent);
  }

  bool isPrimaryCluster(tcPPtr p) {
    if ( p->id() != ExtraParticleID::Cluster ) 
      return false;
    if( p->parents().empty())
      return false;
    for ( size_t i = 0, end = p->parents().size();
	  i < end; ++i ) {
      if ( !(p->parents()[i]->dataPtr()->coloured()) )
	return false;
    }
    return true;
  }
}


void GTestAnalysis::analyze(tEventPtr event, long, int, int) {

  if(!fhepmc) fhepmc = new HepMC::IO_Ascii("hepmcout.dat",std::ios::out);

  HepMC::GenEvent* hepmcevt = HepMCConverter<HepMC::GenEvent>::convert(*event);

  *fhepmc << hepmcevt;

#if 0
  vector<JetableObject> objects = JI->readFromHepMC(hepmcevt);
//  cout << "size of jetable objects = " << objects.size() << endl;
  vector<Jet> alljets = JF->findJets(objects);
//  cout << "size of all jets = " << alljets.size() << endl;
  int nisolep = LA->nIsolatedLeptons(hepmcevt);
//  cout << "size of isolated leptons = " << nisolep << endl;
  if (nisolep == 2) nevtype[0]++;
  vector<Jet> jets = LA->removeLeptonsFromJets(alljets, hepmcevt);
//  cout << "size of jets = " << jets.size() << endl;

  if (jets.size() >= 2) nevtype[1]++;
  if (nisolep == 2 && jets.size() >= 1) nevtype[2]++;
  if (nisolep == 2 && jets.size() >= 2) nevtype[3]++;
#endif

  delete hepmcevt;

}

void GTestAnalysis::analyze(const tPVector & ) {}

void GTestAnalysis::dofinish() {

  delete fhepmc;

#if 0
  cout << "2 isolated leptons              " << nevtype[0] << endl;
  cout << "2+ (2 or more) jets             " << nevtype[1] << endl;
  cout << "2 isolated leptons and 1+ jets  " << nevtype[2] << endl;
  cout << "2 isolated leptons and 2+ jets  " << nevtype[3] << endl;

  ofstream testi("testi.dat");
  double val, errval;
  val = ((double)nevtype[3])/1000.;
  errval = 0.;
  if(nevtype[3] > 0) errval = val/sqrt((double)nevtype[3]);
  testi << "herwigpp_test1  2   " << val << " " << errval << " " << endl;
#endif

  AnalysisHandler::dofinish();
}

ClassDescription<GTestAnalysis> GTestAnalysis::initGTestAnalysis;
// Definition of the static class description member.

void GTestAnalysis::Init() {

  static ClassDocumentation<GTestAnalysis> documentation
    ("The GTestAnalysis class produces HepMC IO_Ascii output.");
}

void GTestAnalysis::persistentOutput(PersistentOStream & os) const {
  os << " ";
}

void GTestAnalysis::persistentInput(PersistentIStream & is, int) {
//  is >>;
}
