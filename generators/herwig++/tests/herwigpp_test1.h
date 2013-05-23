// -*- C++ -*-
//
// Herwig++ is licenced under version 2 of the GPL, see COPYING for details.
// Please respect the MCnet academic guidelines, see GUIDELINES for details.
//
#ifndef HERWIG_herwigpp_test1_H
#define HERWIG_herwigpp_test1_H
//
// This is the declaration of the GTestAnalysis class.
//

#include "ThePEG/Analysis/HepMCFile.h"
#include "ThePEG/Handlers/AnalysisHandler.h"
#include "ThePEG/Repository/Repository.h"
#include "ThePEG/PDT/ParticleData.h"
#include "Herwig++/Utilities/Histogram.h"
#include "Herwig++/Utilities/Statistic.h"

#include "HepMC/GenEvent.h"
#include "IO_Ascii.h"

//#include "ANHEPMC/JetableInputFromHepMC.h"
//#include "ANHEPMC/JetFinderUA.h"
//#include "ANHEPMC/LeptonAnalyserHepMC.h"

#include "ThePEG/Config/Pointers.h"

namespace GTest {

class GTestAnalysis;

}

namespace ThePEG {

ThePEG_DECLARE_POINTERS(GTest::GTestAnalysis,GTestAnalysisPtr);

}


namespace GTest {

using namespace ThePEG;
using namespace Herwig;

/**
 * The GTestAnalysis class is designed to count particle multiplicities and
 * compare them to LEP data.
 *
 */
class GTestAnalysis: public AnalysisHandler {

public:

  /**
   * The default constructor.
   */
  GTestAnalysis();

public:

  /** @name Virtual functions required by the AnalysisHandler class. */
  //@{
  /**
   * Analyze a given Event. Note that a fully generated event
   * may be presented several times, if it has been manipulated in
   * between. The default version of this function will call transform
   * to make a lorentz transformation of the whole event, then extract
   * all final state particles and call analyze(tPVector) of this
   * analysis object and those of all associated analysis objects. The
   * default version will not, however, do anything on events which
   * have not been fully generated, or have been manipulated in any
   * way.
   * @param event pointer to the Event to be analyzed.
   * @param ieve the event number.
   * @param loop the number of times this event has been presented.
   * If negative the event is now fully generated.
   * @param state a number different from zero if the event has been
   * manipulated in some way since it was last presented.
   */
  virtual void analyze(tEventPtr event, long ieve, int loop, int state);

  /**
   * Analyze the given vector of particles. The default version calls
   * analyze(tPPtr) for each of the particles.
   * @param particles the vector of pointers to particles to be analyzed
   */
  virtual void analyze(const tPVector & particles);

  using AnalysisHandler::analyze;
  //@}

public:

  /** @name Functions used by the persistent I/O system. */
  //@{
  /**
   * Function used to write out object persistently.
   * @param os the persistent output stream written to.
   */
  void persistentOutput(PersistentOStream & os) const;

  /**
   * Function used to read in object persistently.
   * @param is the persistent input stream read from.
   * @param version the version number of the object when written.
   */
  void persistentInput(PersistentIStream & is, int version);
  //@}

  /**
   * The standard Init function used to initialize the interfaces.
   * Called exactly once for each class by the class description system
   * before the main function starts or
   * when this class is dynamically loaded.
   */
  static void Init();

protected:

  /** @name Clone Methods. */
  //@{
  /**
   * Make a simple clone of this object.
   * @return a pointer to the new object.
   */
  inline virtual IBPtr clone() const;

  /** Make a clone of this object, possibly modifying the cloned object
   * to make it sane.
   * @return a pointer to the new object.
   */
  inline virtual IBPtr fullclone() const;
  //@}

protected:

  /** @name Standard Interfaced functions. */
  //@{
  /**
   * Finalize this object. Called in the run phase just after a
   * run has ended. Used eg. to write out statistics.
   */
  virtual void dofinish();
  //@}

private:

  /**
   * The static object used to initialize the description of this class.
   * Indicates that this is a concrete class with persistent data.
   */
  static ClassDescription<GTestAnalysis> initGTestAnalysis;

  /**
   * The assignment operator is private and must never be called.
   * In fact, it should not even be implemented.
   */
  GTestAnalysis & operator=(const GTestAnalysis &);

private:

//  JetableInputFromHepMC* JI;
//  JetFinderUA* JF;
//  LeptonAnalyserHepMC* LA;
//  int nevtype[4];

  HepMC::IO_Ascii* fhepmc;

};

}

#include "ThePEG/Utilities/ClassTraits.h"

namespace ThePEG {

/** @cond TRAITSPECIALIZATIONS */

/** This template specialization informs ThePEG about the
 *  base classes of GTestAnalysis. */
template <>
struct BaseClassTrait<GTest::GTestAnalysis,1> {
  /** Typedef of the first base class of GTestAnalysis. */
  typedef AnalysisHandler NthBase;
};

/** This template specialization informs ThePEG about the name of
 *  the GTestAnalysis class and the shared object where it is defined. */
template <>
struct ClassTraits<GTest::GTestAnalysis>
  : public ClassTraitsBase<GTest::GTestAnalysis> {
  /** Return a platform-independent class name */
  static string className() { return "GTest::GTestAnalysis"; }
  /** Return the name(s) of the shared library (or libraries) be loaded to get
   *  access to the GTestAnalysis class and any other class on which it depends
   *  (except the base class). */
  static string library() { return "herwigpp_test1.so"; }
};

/** @endcond */

}

namespace GTest {

inline IBPtr GTestAnalysis::clone() const {
  return new_ptr(*this);
}

inline IBPtr GTestAnalysis::fullclone() const {
  return new_ptr(*this);
}

}


#endif /* HERWIG_herwigpp_test1_H */
