C #@# 1 Mean mult. in QCD jets events simulated by PYTHIA (no PYQUEN)
C #@# 2 Mean |Eta| in QCD jets events simulated by PYTHIA (no PYQUEN)
C #@# 3 Mean Pt in QCD jets events simulated by PYTHIA (no PYQUEN)
C #@# 4 Mean mult. in QCD jets events simulated by PYTHIA - PYQUEN
C #@# 5 Mean |Eta| in QCD jets events simulated by PYTHIA - PYQUEN
C #@# 6 Mean Pt in QCD jets events simulated by PYTHIA - PYQUEN
C
*------------------------------------------------------------------------------
*
* Filename             : TEST_PYQUEN.F
*
*==============================================================================
*
* Description : Example program to simulate partonic rescattering and energy
*               loss in quark-gluon plasma in AA collisions at LHC with 
*               PYQUEN-code (should be compiled with pyquen.f and pythia62.f)
*                
*==============================================================================
 
      IMPLICIT DOUBLE PRECISION(A-H, O-Z)
      IMPLICIT INTEGER(I-N)
      INTEGER PYK,PYCHGE,PYCOMP
      real rpt,rycm,reta,rphi   
      external pydata  
      external pyp,pyr,pyk         
      common /pyjets/ n,npad,k(4000,5),p(4000,5),v(4000,5)
      common /pydat1/ mstu(200),paru(200),mstj(200),parj(200)         
      common /pysubs/ msel,mselpd,msub(500),kfin(2,-40:40),ckin(200)
      common /pypars/ mstp(200),parp(200),msti(200),pari(200)
      common /plfpar/ bgen
      common /pawc/ hmemor(100000)                
      real val,errval
                    
* prepare hbook memory 
cc      call hlimit(100000)
* open hrout file to write histograms 
cc      call HROPEN(1,'HISTO','pyquen.hrout','N',1024,ISTAT)
* prepare hbook histograms 
cc      call hbook1(1,'Pythia, dN/dy',100,-10.,10.,0.)      ! rapidity 
cc      call hbook1(2,'Pythia, dN/d|eta|',100,0.,10.,0.)    ! pseudorapidity 
cc      call hbook1(3,'Pythia, dN/dpt',100,0.,10.,0.)       ! transverse momentum  
cc      call hbook1(4,'Pythia, dN/dphi',100,-3.15,3.15,0.)  ! azimuthal angle 
cc      call hbook1(11,'Pyquen, dN/dy',100,-10.,10.,0.)      ! rapidity
cc      call hbook1(12,'Pyquen, dN/d|eta|',100,0.,10.,0.)    ! pseudorapidity
cc      call hbook1(13,'Pyquen, dN/dpt',100,0.,10.,0.)       ! transverse momentum
cc      call hbook1(14,'Pyquen, dN/dphi',100,-3.15,3.15,0.)  ! azimuthal angle
cc      call hbarx(0)

* set initial beam parameters 
      A=207.d0                       ! atomic weigth         
      ifb=0                          ! flag for fixed impact parameter
      bfix=0.d0                      ! impact parameter in [fm] 
c      ifb=1                          ! flag for minimum bias choice  
 
* set of input PYTHIA parameters 
      msel=1                        ! QCD-dijet production 
      ckin(3)=50.d0                 ! minimum pt in initial hard sub-process 
      mstp(51)=7                    ! CTEQ5M pdf 
      mstp(81)=0                    ! pp multiple scattering off 

* set original (rounded) test values and its rms for current model parameters 
      pta0=0.68d0 
      ptrm0=1.32d0 
c      eta0=0.d0  
      eta0=2.33
      etrm0=3.1d0        
      dna0=228.d0  
      dnrm0=50.d0 
* set initial test values and its rms 
      ptam=0.d0 
      ptam2=0.d0
      ptrms=0.d0 
      etam=0.d0  
      etam2=0.d0
      etrms=0.d0        
      dnam=0.d0  
      dnam2=0.d0
      dnrms=0.d0  

* initialization of pythia configuration 
      call pyinit('CMS','p','p',5500.D0)     

      write(6,*)'Start Pythia run'

* set number of generated events 
      ntot=400
       
      do ne=1,ntot                  ! cycle on events 
cc       mstj(1)=0                    ! hadronization off  
c       mstj(41)=0                   ! vacuum showering off 
       call pyevnt                  ! generate single partonic jet event         
cc       call pyquen(A,ifb,bfix)      ! set parton rescattering and energy loss         
       mstj(1)=1                    ! hadronization on
       call pyexec                  ! hadronization done 
                
       call pyedit(2)               ! remove unstable particles and partons 
	 
       do ip=1,n                    ! cycle on n particles        
        pt=pyp(ip,10)               ! transverse momentum pt 
        ycm=pyp(ip,17)              ! rapidity y
        eta=abs(pyp(ip,19))              ! pseudorapidity eta  
        phi=pyp(ip,15)              ! azimuthal angle phi 

* add current test values of eta, pt and its rms 
        etam=etam+eta 
        etam2=etam2+eta**2
        etrms=etrms+(eta-eta0)**2  
        ptam=ptam+pt  
        ptam2=ptam2+pt**2
        ptrms=ptrms+(pt-pta0)**2

* fill histograms   
        rycm=ycm                    ! set real y for hbook   
        reta=eta                    ! set real eta for hbook 
        rpt=pt                      ! set real pt for hbook 
        rphi=phi                    ! set real phi for hbook  
cc        call hfill(1,rycm,0.,1.)    ! fill y    
cc        call hfill(2,reta,0.,1.)    ! fill eta 
cc        call hfill(3,rpt,0.,1.)     ! fill pt 
cc        call hfill(4,rphi,0.,1.)    ! fill phi   
       end do 
       if( abs(float(ne)/50.-float(ne/50)) .lt. 0.0001 )
     &   write(6,*) 'Event #',ne,'    Impact parameter',bgen,'fm'      

* add current test value of event multiplicity and its rms 
       dnam=dnam+n
       dnam2=dnam2+n**2
       dnrms=dnrms+(n-dna0)**2 
      end do 

* test calculating and printing of original "true" (rounded) numbers 
* and generated one's (with statistical errors) 
      etam=etam/dnam
      etam2=etam2/dnam
      etrms = dsqrt(etam2-etam**2)/dsqrt(dnam)
      ptam=ptam/dnam 
      ptam2=ptam2/dnam
      ptrms = dsqrt(ptam2-ptam**2)/dsqrt(dnam)
      dnam=dnam/ntot
      dnam2=dnam2/ntot
      dnrms = dsqrt(dnam2-dnam**2)/sqrt(float(ntot))
*
      write(6,4) dna0, dnam, dnrms
4     format('Mult,  Pyquen reference = ',f5.1,2x,' gen = ',f5.1,
     &       ' +- ',f5.1)
      write(6,5) eta0, etam, etrms
5     format('|Eta|, Pyquen reference = ',f5.3,2x,' gen = ',f5.3,
     &       ' +- ',f5.3)
      write(6,6) pta0, ptam, ptrms
6     format('Pt,    Pyquen reference = ',f5.3,2x,' gen = ',f5.3,
     &       ' +- ',f5.3)
*        
c     test results
      print *,'pyquen_test1   1   ', dnam, 2.5*dnrms
      print *,'pyquen_test1   2   ', etam, 2.5*etrms
      print *,'pyquen_test1   3   ', ptam, 2.5*ptrms

* FIXME: seems that real stat. sigma of results is higher than calculated
* as sqrt(D/N). This is to be checked. For the moment errors increased by 2.5


* Second run, with pyquen --------------------------------------------


* set initial test values and its rms 
      ptam=0.d0 
      ptam2=0.d0
      ptrms=0.d0 
      etam=0.d0  
      etam2=0.d0
      etrms=0.d0        
      dnam=0.d0  
      dnam2=0.d0
      dnrms=0.d0  

      write(6,*)'Start Pyquen run'

* set number of generated events 
      ntot=400
       
      do ne=1,ntot                  ! cycle on events 
       mstj(1)=0                    ! hadronization off  
c       mstj(41)=0                   ! vacuum showering off 
       call pyevnt                  ! generate single partonic jet event         
       call pyquen(A,ifb,bfix)      ! set parton rescattering and energy loss         
       mstj(1)=1                    ! hadronization on
       call pyexec                  ! hadronization done 
                
       call pyedit(2)               ! remove unstable particles and partons 
	 
       do ip=1,n                    ! cycle on n particles        
        pt=pyp(ip,10)               ! transverse momentum pt 
        ycm=pyp(ip,17)              ! rapidity y
        eta=abs(pyp(ip,19))              ! pseudorapidity eta  
        phi=pyp(ip,15)              ! azimuthal angle phi 

* add current test values of eta, pt and its rms 
        etam=etam+eta 
        etam2=etam2+eta**2
        etrms=etrms+(eta-eta0)**2  
        ptam=ptam+pt  
        ptam2=ptam2+pt**2
        ptrms=ptrms+(pt-pta0)**2

* fill histograms   
        rycm=ycm                    ! set real y for hbook   
        reta=eta                    ! set real eta for hbook 
        rpt=pt                      ! set real pt for hbook 
        rphi=phi                    ! set real phi for hbook  
cc        call hfill(11,rycm,0.,1.)    ! fill y    
cc        call hfill(12,reta,0.,1.)    ! fill eta 
cc        call hfill(13,rpt,0.,1.)     ! fill pt 
cc        call hfill(14,rphi,0.,1.)    ! fill phi   
       end do 
       if( abs(float(ne)/50.-float(ne/50)) .lt. 0.0001 )
     &   write(6,*) 'Event #',ne,'    Impact parameter',bgen,'fm'      

* add current test value of event multiplicity and its rms 
       dnam=dnam+n
       dnam2=dnam2+n**2
       dnrms=dnrms+(n-dna0)**2 
      end do 

* test calculating and printing of original "true" (rounded) numbers 
* and generated one's (with statistical errors) 
      etam=etam/dnam
      etam2=etam2/dnam
      etrms = dsqrt(etam2-etam**2)/dsqrt(dnam)
      ptam=ptam/dnam 
      ptam2=ptam2/dnam
      ptrms = dsqrt(ptam2-ptam**2)/dsqrt(dnam)
      dnam=dnam/ntot
      dnam2=dnam2/ntot
      dnrms = dsqrt(dnam2-dnam**2)/sqrt(float(ntot))
*
      write(6,4) dna0, dnam, dnrms
      write(6,5) eta0, etam, etrms
      write(6,6) pta0, ptam, ptrms
*        
c     test results
      print *,'pyquen_test1   4   ', dnam, 2.5*dnrms
      print *,'pyquen_test1   5   ', etam, 2.5*etrms
      print *,'pyquen_test1   6   ', ptam, 2.5*ptrms

* FIXME: seems that real stat. sigma of results is higher than calculated
* as sqrt(D/N). This is to be checked. For the moment errors increased by 2.5

*
* finish histograms writing procedure        
c      call hidopt(0,'ERRO')
c      call histdo
cc      CALL HROUT(0,ICYCLE,' ')
cc      CALL HREND('HISTO')
*       
      end
*******************************************************************************
