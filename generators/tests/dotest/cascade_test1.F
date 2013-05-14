C #@# <a href=http://svnweb.cern.ch/world/wsvn/GENSER/GENSER2/tests/trunk/examples/Cascade/steer_pp><h3>input_file</h3></a>
C #@# 1 cross-section [nb] (sigma visible)
C #@# 2 Mean multiplicity
C #@# 3 Mean |Eta| pseudorapidity
C #@# 4 Mean Pt transverse momentum
*------------------------------------------------------------------------------
*
* Filename             : TEST_CASCADE.F
*
*==============================================================================
*
* Description : Example program *
*==============================================================================

      IMPLICIT None
      INTEGER K1,K2,LUX
      INTEGER l,j
#include "casluco.inc"
#include "casparas.inc"
#include "casvalues.inc"
#include "caslujets.inc"
#include "caseffic.inc"
      EXTERNAL pydata
      INTEGER IGLU
      REAL pta0, eta0, dna0, ptam, ptrms, etam, etrms, dnam, dnrms
      REAL ptrm0, etrm0, dnrm0
      REAL av, etas, pts, cost, eta, pt 
      REAL sec0, secrm0, sec, secrms

      REAL val, errval 
c
      COMMON/CAGLUON/Iglu
      INTEGER ISEED,I
	
      INTEGER Nevent
      COMMON/steer1/Nevent
	
      REAL timeleft
      INTEGER Minuts
      EXTERNAL Minuts
      INTEGER irr
      LOGICAL ex
c	
C initialize random number generator	
      ISEED = 47034466
      LUX   = 4
      K1    = 0
      K2    = 0
      CALL RLUXGO(LUX,ISEED,K1,K2)
C initialise PYTHIA 6 parameters, now done via block data
C initialise CASCADE parameters
      CALL CASINI
      CALL STEER	
C-- change standard parameters of CASCADE
      CALL CASCHA
c
C-- change standard parameters of JETSET/PYTHIA
      CALL pytcha
      CALL pylogo
c
c Start integration of x-section
c
      CALL CASCADE
c
c Print out result of integration of x-section
c
CC      CALL CAEND(1)
c	
cc      inquire(FILE='Cascade/pythia62.dat',EXIST=ex)
cc      IF (ex) THEN
cc         open(3,FILE='Cascade/pythia62.dat', FORM='formatted',
cc     +   STATUS='OLD',
cc     +   IOSTAT=IRR,ERR=220)
cc         WRITE(6,*) ' updating PYTHIA particle data with file ' 
cc	   CALL pyupda(3,3)
cc      ELSE 
cc         write(6,*) '  PYTHIA particle data file not existing ' 
cc         open(3,FILE='Cascade/pythia62.dat', FORM='formatted',
cc     +   STATUS='NEW',
cc     +   IOSTAT=IRR,ERR=220)
cc	   CALL pyupda(1,3)
cc      END IF
c
c Start event loop
c
* set original (rounded) test values and its rms for current model parameters 
      sec0   = 395017.0
c      secrm0 = 1619.29
      pta0=0.4185319
c      ptrm0=0.00222985 
      eta0=12.19237
c      etrm0=0.066886
      dna0=155.938
c      dnrm0=0.668860
* set initial test values and its rms 
      ptam=0. 
      ptrms=0. 
      etam=0.  
      etrms=0.        
      dnam=0.  
      dnrms=0.  
c
      Nevent = 1000
c
      DO I=1,Nevent
        av = 0.
        etas = 0.
        pts = 0.
c
c  generate an event
        CALL EVENT
C--- user analysis routine (hztool)
c        CALL hzcaana
c 
        IF (N .LE. 0) WRITE(6,*) "N=0  !!!!!"
        IF (N .GT. 0) THEN
           DO j = 1,N
              IF (K(j,1) .EQ. 1) THEN
                 av = av + 1.
                 cost = P(j,3)/sqrt(P(j,1)**2+P(j,2)**2+P(j,3)**2)
                 IF (abs(cost) .LT. 0.999999) THEN
                    eta = 0.5*alog((1.+ cost)/(1.- cost))
                 ELSE
                    eta = 100.
                 END IF
                 etas = etas + abs(eta)                   
                 pt   = sqrt(P(j,1)**2+P(j,2)**2)
                 pts  = pts + pt
              END IF
           END DO
        END IF
        IF (av .GT. 0) THEN
           etas = etas/av
           pts  = pts/av
        END IF
        etam  = etam  + etas
        etrms = etrms + (etas-eta0)**2
        ptam  = ptam  + pts
        ptrms = ptrms + (pts-pta0)**2
        dnam  = dnam  + av
        dnrms = dnrms + (av-dna0)**2
      END DO
C123   CONTINUE
c
C--- user terminate routine (hztool)
cc     CALL hzcaend

* test calculating and printing of original "true" (rounded) numbers 
* and generated one's (with statistical errors) 
      etam  = etam/float(Nevent)
      etrms = sqrt(etrms/(float(Nevent)-1.))
      ptam  = ptam/float(Nevent)
      ptrms = sqrt(ptrms/(float(Nevent)-1.))
      dnam  = dnam/float(Nevent)
      dnrms = sqrt(dnrms/(float(Nevent)-1.)) 
c
10000 FORMAT('  sigma  = ',f26.1,' nb   +/- ',f26.1)
      sec    = AVGI
      secrms = SD
      WRITE(6,10000) sec, secrms
      WRITE(6,1) dna0
1     FORMAT(2x,'True mean multiplicity =',f19.10) 
      WRITE(6,2) dnam, dnrms 
2     FORMAT(2x,'Generated mean multiplicity      =',f19.10,3x,
     > '+-  ',f19.10) 
      WRITE(6,3) eta0
3     FORMAT(2x,'True mean pseudorapidity =',f19.10) 
      WRITE(6,4) etam, etrms 
4     FORMAT(2x,'Generated mean pseudorapidity      =',f19.10,3x,
     > '+-  ',f19.10) 
      WRITE(6,5) pta0
5     FORMAT(2x,'True mean transverse momentum =',f19.10)   
      WRITE(6,6) ptam, ptrms 
6     FORMAT(2x,'Generated mean transverse momentum      =',f19.10,3x,
     > '+-  ',f19.10)    
c
c            test output
c
      CALL testfileopen
      val    = sec
      errval = secrms
      CALL testfile('cascade_test1', 1, val, errval)
      val    = dnam
      errval = dnrms/sqrt(float(Nevent))
      CALL testfile('cascade_test1', 2, val, errval)
      val    = etam
      errval = etrms/sqrt(float(Nevent))
      CALL testfile('cascade_test1', 3, val, errval)
      val    = ptam
      errval = ptrms/sqrt(float(Nevent))
      CALL testfile('cascade_test1', 4, val, errval)
      CALL testfileclose
c
      STOP	
  220 WRITE(6,*) ' error opening  file for PYTHIA update '
      END
