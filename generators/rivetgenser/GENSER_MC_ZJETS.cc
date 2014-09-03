// -*- C++ -*-
#include "Rivet/Analysis.hh"
#include "Rivet/Projections/FinalState.hh"
#include "Rivet/Projections/ZFinder.hh"
#include "Rivet/Projections/FastJets.hh"
/// @todo Include more projections as required, e.g. ChargedFinalState, FastJets, ZFinder...

namespace Rivet {


  class GENSER_MC_ZJETS : public Analysis {
  public:

    /// Constructor
    GENSER_MC_ZJETS()
      : Analysis("GENSER_MC_ZJETS")
    {    }


  public:

    /// @name Analysis methods
    //@{

    /// Book histograms and initialise projections before the run
    void init() {

      FinalState fs;
      ZFinder zfinder(fs, -2.4, 2.4, 25*GeV, PID::ELECTRON, 65*GeV, 115*GeV, 0.3, ZFinder::CLUSTERNODECAY, ZFinder::TRACK);
      addProjection(zfinder, "ZFinder");
      FastJets jetpro(zfinder.remainingFinalState(), FastJets::ANTIKT, 0.5);
      addProjection(jetpro, "Jets");


      _h_Z_pt = bookHisto1D("Z_pt", logspace(10, 10., 1000.));
      _h_jet_mult = bookHisto1D("jet_mult", 10, -0.5, 9.5);
      _h_jet_mult_norm = bookHisto1D("jet_mult_norm", 10, -0.5, 9.5);

    }


    /// Perform the per-event analysis
    void analyze(const Event& event) {
      const double weight = event.weight();

      const ZFinder& zfinder = applyProjection<ZFinder>(event, "ZFinder");
      if (zfinder.bosons().size() != 1) vetoEvent;
      const FourMomentum& zmom = zfinder.bosons()[0].momentum();

      _h_Z_pt->fill(zmom.pt(), weight);

      const Jets& jets = applyProjection<FastJets>(event, "Jets").jetsByPt(20*GeV);

      _h_jet_mult->fill((double)(jets.size()), weight);
      _h_jet_mult_norm->fill((double)(jets.size()), weight);

      if (jets.size() > 0) { 
        //_h_Z_jet1_deta->fill(zmom.eta()-jets[0].eta(), weight);
        //_h_Z_jet1_dR->fill(deltaR(zmom, jets[0].momentum()), weight);
      }

    }


    /// Normalise histograms etc., after the run
    void finalize() {

      scale(_h_jet_mult_norm, crossSection()/sumOfWeights());

      // normalize(_h_YYYY); // normalize to unity

    }

    //@}


  private:

    // Data members like post-cuts event weight counters go here


  private:

    /// @name Histograms
    //@{
    Histo1DPtr _h_Z_pt;
    Histo1DPtr _h_jet_mult;
    Histo1DPtr _h_jet_mult_norm;
    //@}


  };



  // The hook for the plugin system
  DECLARE_RIVET_PLUGIN(GENSER_MC_ZJETS);

}
