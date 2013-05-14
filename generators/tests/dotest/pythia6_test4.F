C #@# 1 Mean mult. in QCD jets events simulated by PYTHIA 
C #@# 2 Mean |Eta| in QCD jets events simulated by PYTHIA 
C #@# 3 Mean Pt    in QCD jets events simulated by PYTHIA 
C
*------------------------------------------------------------------------------
*
*==============================================================================
*
      PROGRAM PYTHIA6_TEST4
 
C Common blocks
C
      INCLUDE "general_pythia.inc"
C
cc      IMPLICIT DOUBLE PRECISION(A-H, O-Z)
cc      INTEGER PYK,PYCHGE,PYCOMP
cc      external pydata  
cc      common /pyjets/ n,npad,k(4000,5),p(4000,5),v(4000,5)
cc      common /pydat1/ mstu(200),paru(200),mstj(200),parj(200)         
cc      common /pysubs/ msel,mselpd,msub(500),kfin(2,-40:40),ckin(200)
cc      common /pypars/ mstp(200),parp(200),msti(200),pari(200)


cc      common /plfpar/ bgen
cc      common /pawc/ hmemor(100000)                
      real val,errval
      real rpt,rycm,reta,rphi   
      external pyp        
                    
* prepare hbook memory 
cc      call hlimit(100000)
* open hrout file to write histograms 
* prepare hbook histograms 
cc      call hbook1(1,'Pythia, dN/dy',100,-10.,10.,0.)      ! rapidity 
cc      call hbook1(2,'Pythia, dN/d|eta|',100,0.,10.,0.)    ! pseudorapidity 
cc      call hbook1(3,'Pythia, dN/dpt',100,0.,10.,0.)       ! transverse momentum  
cc      call hbook1(4,'Pythia, dN/dphi',100,-3.15,3.15,0.)  ! azimuthal angle 
cc      call hbarx(0)

* set initial beam parameters 
cc      A=207.d0                       ! atomic weigth         
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
cc       if( abs(float(ne)/50.-float(ne/50)) .lt. 0.0001 )
cc     &   write(6,*) 'Event #',ne,'    Impact parameter',bgen,'fm'      

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
      call testfileopen
      val=dnam
      errval=dnrms
      call testfile('pythia6_test4', 1, val, 2.5*errval)
      val=etam
      errval=etrms
      call testfile('pythia6_test4', 2, val, 2.5*errval)
      val=ptam
      errval=ptrms
      call testfile('pythia6_test4', 3, val, 2.5*errval)

* FIXME: seems that real stat. sigma of results is higher than calculated
* as sqrt(D/N). This is to be checked. For the moment errors increased by 2.5


      call testfileclose

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
