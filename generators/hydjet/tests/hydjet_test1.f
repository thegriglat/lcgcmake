C #@# 1 Mean multiplicity
C #@# 2 Mean |Eta| pseudorapidity
C #@# 3 Mean Pt transverse momentum
*------------------------------------------------------------------------------
*
* Filename             : TEST_HYDJET.F
*
*==============================================================================
*
* Description : Example program to simulate hadron spectra in AA collisions 
*               with HYDJET generator. It should be compiled with hydjet1_4.f, 
*               pyquen1_4.f and latest pythia (pythia6401.f or later version), 
*               and also jetset_73.f with the extended array size of common 
*               block LUJETS (if using the standard JETSET subroutines and 
*               functions to manipulate with the event record and to provide 
*               various event data is needed).
*
*==============================================================================

      IMPLICIT DOUBLE PRECISION(A-H, O-Z)
      double precision nbcol,npart
      real p,v,plu, val, errval
      external ludata,pydata
      common /lujets/ n,k(150000,5),p(150000,5),v(150000,5)
      common /hyjets/ nhj,nhp,khj(150000,5),phj(150000,5),vhj(150000,5) 
      common /hyfpar/ bgen,nbcol,npart,npyt,nhyd
      common /hyflow/ ytfl,ylfl,Tf,fpart 
      common /hyjpar/ ptmin,sigin,sigjet,nhsel,ishad,njet        
      common /pydat1/ mstu(200),paru(200),mstj(200),parj(200)
C...Decay information.
      COMMON/PYDAT3/MDCY(500,3),MDME(8000,2),BRAT(8000),KFDP(8000,5)
      common /pysubs/ msel,mselpd,msub(500),kfin(2,-40:40),ckin(200) 
      common /pypars/ mstp(200),parp(200),msti(200),pari(200)
      common /pyqpar/ T0,tau0,nf,ienglu,ianglu 
      save /lujets/,/hyjets/,/hyflow/,/hyjpar/,/hyfpar/,/pyqpar/,
     >     /pysubs/,/pypars/,/pydat1/
      integer pycomp

* set beam parameters:  

      energy=5500.d0                  ! c.m.s energy per nucleon pair 
      A=207.d0                        ! atomic weigth        
      nh=20000                      ! mean soft multiplicity for central Pb+Pb 
cccc      nh=30000           ! mean soft multiplicity for central Pb+Pb 
      ifb=0                         ! fixed impact parameter
      bfix=0.d0                       ! in nucleus radius units
c      ifb=1                         ! distribution over impact parameter  
c      bmin=0.d0                     ! from 'bmin' 
c      bmax=3.d0                     ! to 'bmax'  

* set of input HYDJET parameters: 
* nhsel=0 - hydro (no jets), nhsel=1 - hydro + pythia jets, nhsel=2 - hydro + 
* pyquen jets, nhsel=3 - pythia jets (no hydro), nhsel=4 - pyquen jets (no hydro)
      nhsel=2                        ! flag to include hard scatterings 
* ishad=0 - no shadowing, ishad=1 - shadowing is included       
      ishad=1                        ! flag to include "nuclear shadowing" 
      ylfl=5.d0                        ! maximum longitudinal flow rapidity
      ytfl=1.d0                        ! maximum transverse flow rapidity
      Tf=0.14d0                        ! freeze-out temperature in GeV
cc     ylfl=4.d0                      ! maximum longitudinal flow rapidity
cc     ytfl=1.5d0                     ! maximum transverse flow rapidity
cc     Tf=0.1d0                       ! freeze-out temperature in GeV
      fpart=1.d0                  ! fraction of soft multiplicity proportional 
                                     ! # of nucleons-participants
* set of input PYQUEN parameters: 
* ienglu=0 - radiative and collisional loss, ienglu=1 - only radiative loss, 
* ienglu=2 - only collisional loss;  
* ianglu=0 - small-angular radiation, ianglu=1 - wide angular radiation, 
* inanglu=2 - collinear radiation 
      ienglu=0                       ! set type of partonic energy loss
      ianglu=0                       ! set angular spectrum of gluon radiation 
      T0=1.d0                          ! initial QGP temparature 
      tau0=0.1d0                       ! proper time of QGP formation 
      nf=0                           ! number of active quark flavours in QGP 
                                     
* set input PYTHIA parameters:
      msel=1                      ! QCD-dijet production 
      ckin(3)=10.d0               ! minimum pt in initial hard scattering, GeV 
      mstp(51)=7                  ! CTEQ5M pdf 
      mstp(81)=0                  ! pp multiple scattering off 
      mstu(21)=1                  ! avoid stopping run 
      paru(14)=1.d0               ! tolerance parameter to adjust fragmentation 

cc      mdcy(pycomp(111),1)=0 ! turn off pi0 decays
cc      mdcy(pycomp(311),1)=0 ! turn off K0 decays
cc      mdcy(pycomp(310),1)=0 ! turn off K0S decays
cc      mdcy(pycomp(130),1)=0 ! turn off K0L decays

* set original (rounded) test values and its rms for current model parameters 
      pta0=0.56d0
      eta0=0.d0         
      dna0=26620.d0   
ccc      pta0=0.69d0
ccc      dna0=35700.d0             
* set initial test values and its rms 
      ptam=0.d0 
      ptrms=0.d0 
      etam=0.d0  
      etrms=0.d0        
      dnam=0.d0  
      dnrms=0.d0  
       
* initialize HYDJET at given c.m.s. energy per nucleon pair 
      call hyinit(energy,A,ifb,bmin,bmax,bfix,nh)
       
* set number of generated events 
      ntot=10
c
      do ne=1,ntot                        ! cycle on events 
c
        call hyevnt                         ! single event generation
       call luedit(2)                  ! remove unstable particles and partons 

* reset current test value of pt 
       ptamc=0.d0     
       
       if(n.ge.1) then 
       do ip=1,n                          ! cycle on particles        
        pt=plu(ip,10)                     ! transverse momentum... 
        eta=plu(ip,19)                    ! pseudorapidity...  

* add current test values of eta, pt and its rms 
        etam=etam+abs(eta) 
	etrms=etrms+(eta-eta0)**2 
	 ptamc=ptamc+pt  
	ptrms=ptrms+(pt-pta0)**2           	 
       end do 
* add current test values of mean pt and event multiplicity and their rms
        ptam=ptam+ptamc/n 
       end if  
       dnam=dnam+n          
       dnrms=dnrms+(n-dna0)**2 

       write(6,*) 'Event #',ne
       write(6,*) 'Impact parameter',bgen,'*RA',' Total multiplicity',n 
       write(6,*) 'Pt hard min',ptmin,' GeV','   Ndijets',njet 
       write(6,*) '***************************************************'
      end do 

* test calculating and printing of original "true" (rounded) numbers 
* and generated one's (with statistical errors) 
      etam=etam/dnam
      etrms=sqrt(etrms)/dnam
      ptam=ptam/ntot 
      ptrms=dsqrt(ptrms)/dnam
      dnam=dnam/ntot
      dnrms=dsqrt(dnrms)/ntot 
      write(6,1) dna0
1     format(2x,'True (rounded) mean multiplicity =',f7.0) 
      write(6,2) dnam, dnrms 
2     format(2x,'Generated mean multiplicity      =',f7.0,3x,
     > '+-  ',f6.0) 
      write(6,3) eta0
3     format(2x,'True (rounded) mean pseudorapidity =',f5.2) 
       write(6,4) etam, etrms 
4     format(2x,'Generated mean pseudorapidity      =',f5.2,3x,
     > '+-  ',f5.2) 
      write(6,5) pta0
5     format(2x,'True (rounded) mean transverse momentum =',f5.2)   
      write(6,6) ptam, ptrms 
6     format(2x,'Generated mean transverse momentum      =',f5.2,3x,
     > '+-  ',f5.2)    

c            test output
c     output value and error
      print *,'hydjet_test1   1   ', dnam, 2.5*dnrms
      print *,'hydjet_test1   2   ', etam, 2.5*etrms
      print *,'hydjet_test1   3   ', ptam, 2.5*ptrms
      
      end
*******************************************************************************
