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
*               at LHC with HYDJET-code, should be compiled with object files
*               obtained with hydjet1_2.f, pyquen1_2.f, latest pythia 
*               (pythia6401.f or later versions) and jetset_73.f with extended 
*               array size of common block LUJETS 
*
*==============================================================================

      double precision paru,parj,ckin,parp,pari
      double precision T0,tau0 
      external ludata,pydata 
      common /lujets/ n,k(150000,5),p(150000,5),v(150000,5)
      common /hyfpar/ bgen,nbcol,npart,npyt,nhyd
      common /hyflow/ ytfl,ylfl,Tf,fpart 
      common /hyjpar/ nhsel,ishad,ptmin,sigin,njet,sigjet        
      common /pydat1/ mstu(200),paru(200),mstj(200),parj(200)
      common /pysubs/ msel,mselpd,msub(500),kfin(2,-40:40),ckin(200) 
      common /pypars/ mstp(200),parp(200),msti(200),pari(200)
      common /pyqpar/ T0,tau0,nf,ienglu,ianglu 
      save /lujets/,/hyflow/,/hyjpar/,/hyfpar/
      save /pysubs/,/pypars/,/pydat1/ 

* prepare hbook memory 
c      call hlimit(20000)
* open hrout file to write histograms 
c      call HROPEN(1,'HISTO','hydjet.hrout','N',1024,ISTAT)
* prepare hbook histograms 
c      call hbook1(1,'dN/dy $',100,-10.,10.,0.)     ! rapidity 
c      call hbook1(2,'dN/deta $',100,-10.,10.,0.)   ! pseudorapidity 
c      call hbook1(3,'dN/dpt $',100,0.,10.,0.)      ! transverse momentum  
c      call hbook1(4,'dN/dphi $',100,-3.15,3.15,0.) ! azimuthal angle 
c      call hbarx(0)

* set initial beam parameters:  
      energy=5500.                  ! c.m.s energy per nucleon pair 
      A=207.                        ! atomic weigth        
      nh=20000                      ! mean soft multiplicity for central Pb+Pb 
      ifb=0                         ! fixed impact parameter
      bfix=0.                       ! in nucleus radius units
c      ifb=1                         ! distribution over impact parameter  
c      bmin=0.                       ! from 'bmin' 
c      bmax=2.                       ! to 'bmax'  

* set of input HYDJET parameters: 
* nhsel=0 - hydro (no jets), nhsel=1 - hydro + pythia jets, nhsel=2 - hydro + 
* pyquen jets, nhsel=3 - pythia jets (no hydro), nhsel=4 - pyquen jets (no hydro)
      nhsel=2                        ! flag to include hard scatterings 
      ylfl=5.                        ! maximum longitudinal flow rapidity
      ytfl=1.                        ! maximum transverse flow rapidity
      Tf=0.14                        ! freeze-out temperature in GeV
      fpart=1.                       ! fraction of soft multiplicity proportional 
                                     ! # of nucleons-participants
* set of input PYQUEN parameters: 
* ienglu=0 - radiative and collisional loss, ienglu=1 - only radiative loss, 
* ienglu=2 - only collisional loss;  
* ianglu=0 - small-angular radiation, ianglu=1 - wide angular radiation, 
* inanglu=2 - collinear radiation 
      ienglu=0                       ! set type of partonic energy loss
      ianglu=0                       ! set angular spectrum of gluon radiation        ishad=1                        ! flag to include "nuclear shadowing"
      T0=1.                          ! initial QGP temparature 
      tau0=0.1                       ! proper time of QGP formation 
      nf=0                           ! number of active quark flavours in QGP 
                                     
* set input PYTHIA parameters:
      msel=1                      ! QCD-dijet production 
      ckin(3)=10.                 ! minimum pt in initial hard scattering, GeV 
      mstp(51)=7                  ! CTEQ5M pdf 
      mstp(81)=0                  ! pp multiple scattering off 
      mstu(21)=1                  ! avoid stopping run 
      paru(14)=1.                 ! tolerance parameter to adjust fragmentation 

* set original (rounded) test values and its rms for current model parameters 
      pta0=0.56
      eta0=0.         
      dna0=26620.   
* set initial test values and its rms 
      ptam=0. 
      ptrms=0. 
      etam=0.  
      etrms=0.        
      dnam=0.  
      dnrms=0.  
       
* initialize HYDJET at given c.m.s. energy per nucleon pair 
      call hyinit(energy,A,ifb,bmin,bmax,bfix,nh)
cc      call hyinit(energy) 
       
* set number of generated events 
      ntot=100
cc      ntot=30
c
      do ne=1,ntot                        ! cycle on events 
c
        call hyevnt                         ! single event generation
cc       call hydro(A,ifb,bmin,bmax,bfix,nh)! single event generation    
       call luedit(2)                     ! remove unstable particles and partons                       
       do ip=1,n                          ! cycle on particles        
        pt=plu(ip,10)                     ! transverse momentum... 
        ycm=plu(ip,17)                    ! rapidity...  
        eta=plu(ip,19)                    ! pseudorapidity...  
        phi=plu(ip,15)                    ! azimuthal angle...
        charge=plu(ip,6)                  ! electric charge...

* add current test values of eta, pt and its rms 
        etam=etam+abs(eta) 
	etrms=etrms+(eta-eta0)**2 
	ptam=ptam+pt  
	ptrms=ptrms+(pt-pta0)**2
           	 
* fill histograms for charged particles 
c        if(abs(charge).gt.0.) then 
c         call hfill(1,ycm,0.,1.)          ! rapidity    
c         call hfill(2,eta,0.,1.)          ! pseudorapidity 
c         call hfill(3,pt,0.,1.)           ! transverse momentum 
c         call hfill(4,phi,0.,1.)          ! azimuthal angle  
c        end if 
       end do 
       write(6,*) 'Event #',ne
       write(6,*) 'Impact parameter',bgen,'*RA',' Total multiplicity',n 
       write(6,*) 'Pt hard min',ptmin,' GeV','   Ndijets',njet 
       write(6,*) '***************************************************'

* add current test value of event multiplicity and its rms 
       dnam=dnam+n          
       dnrms=dnrms+(n-dna0)**2 
      end do 

* test calculating and printing of original "true" (rounded) numbers 
* and generated one's (with statistical errors) 
      etam=etam/dnam
      etrms=sqrt(etrms)/dnam
      ptam=ptam/dnam 
      ptrms=sqrt(ptrms)/dnam
      dnam=dnam/float(ntot)
      dnrms=sqrt(dnrms)/float(ntot) 
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
      call testfileopen
      val=dnam
      errval=dnrms
      call testfile('hydjet_test1', 1, val, 2.5*errval)
      val=etam
      errval=etrms
      call testfile('hydjet_test1', 2, val, 2.5*errval)
      val=ptam
      errval=ptrms
      call testfile('hydjet_test1', 3, val, 2.5*errval)
      call testfileclose

 
* finish histograms writing procedure        
c      call hidopt(0,'ERRO')
c      call histdo
c      CALL HROUT(0,ICYCLE,' ')
c      CALL HREND('HISTO')
       
      end
*******************************************************************************
