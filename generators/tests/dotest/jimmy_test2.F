C#@# 1: Z + jets  total cross section [nb] at LHC
C#@# 2: >=2 charged leptons + >=2 jets event fraction.

      PROGRAM HRW_JIMMY
c     -----------------
c     HERWIG/JIMMY COMMONS. HERWIG COMMON INCLUDES AN IMPLICIT NONE.
      INCLUDE 'HERWIG65.INC'
      INCLUDE 'jimmy.inc'             !cpol
      INCLUDE 'pyt_strongtyp_short.inc'  ! not #include: preprocessor crashes on
      common/mkpars/nev            ! long names. Hence, no dependencies
      integer nev
      INTEGER IEV, ITIME(10)
      REAL TOLD, TNEW
      EXTERNAL HWUDAT

      LOGICAL ABORT
      INTEGER LOOP
      DOUBLE PRECISION HWRSET


      call pyckbd
      CALL COLLIDERINI

      CALL ANZJETSINI

c     Set beam energies
      PART1='P  '
      PART2='P  '
      PBEAM1=7000.0
      PBEAM2=7000.0
      
       IPROC=2150
C     HERWIG initialization
      CALL HWIGIN
C     JIMMY initialization
      CALL JIMMIN                     !cpol

C---USER CAN RESET PARAMETERS AT
C   THIS POINT, OTHERWISE DEFAULT
C   VALUES IN HWIGIN WILL BE USED.
cc      PTMIN=20.
      MODBOS(1)=5


c      MODPDF(1)=46
c      AUTPDF(1)='CTEQ'
c      MODPDF(2)=46
c      AUTPDF(2)='CTEQ'

c     Minimum PT of the hardest scatter
c      PTMIN=100.

c     Minimum PT of secondary scatters
c      PTJIM=2.5


C---  Turn MI on(1) or off(0)
c      MSFLAG=1                      !cpol 

C     More initialization.
      CALL HWUINC
      CALL HWEINI            
      CALL JMINIT                   

      MAXEV=1000
      MAXER=MAXEV/5
      nev = MAXEV
C     Initialise your histograms here.
      CALL HWABEG

C...Start time
      CALL PYTIME(ITIME)
      TOLD=3600D0*ITIME(4)+60D0*ITIME(5)+ITIME(6)

C     Loop over events.
      DO LOOP=1,MAXEV
 50      CONTINUE
         
C---  INITIALISE EVENT
         CALL HWUINE
C---  GENERATE HARD SUBPROCESS
         CALL HWEPRO
C---  GENERATE PARTON CASCADES
         CALL HWBGEN
C---  GENERATE MULTIPARTON INTERACTIONS
         IF (MSFLAG.EQ.1) THEN   
            CALL HWMSCT(ABORT)   
            IF (ABORT) GOTO 50   
         ENDIF                   
C---  DO HEAVY QUARK DECAYS
         CALL HWDHOB
C---  DO CLUSTER HADRONIZATION
         CALL HWCFOR
C---  DO CLUSTER DECAY
         CALL HWCDEC
C---  DO UNSTABLE PARTICLE DECAYS
         CALL HWDHAD
C---  DO HEAVY FLAVOUR DECAYS
         CALL HWDHVY
C---  ADD SOFT UNDERLYING EVENT IF NEEDED
         CALL HWMEVT
C---  FINALISE EVENT
         CALL HWUFNE
         
         IF (IERROR.NE.0) GOTO 50
         
         IF (mod(LOOP,1000).eq.0) THEN
            PRINT*,"Event ",LOOP
         ENDIF

c     Fill your histograms here.
      CALL HWANAL(LOOP)

      ENDDO
      
C     Finish off Herwig Routines
      CALL HWEFIN
C...Finishing time
      CALL PYTIME(ITIME)
      TNEW=3600D0*ITIME(4)+60D0*ITIME(5)+ITIME(6)

      write(6,666) MAXEV, AVWGT

661   format(/I6, ' Events, will take about ', f8.1,
     &       ' seconds on P4-1600'/)

cc666   format(/ I6, ' Events generated in ', f10.4,
cc     &       ' seconds, cross section (nb) = ', f8.4)
666   format(/ I6, ' Events generated, cross section (nb) = ', f8.4)


C     Finish off JIMMY
      CALL JMEFIN                          

C---USER'S TERMINAL CALCULATIONS
      CALL HWAEND
      END
      SUBROUTINE HWABEG
C     USER'S ROUTINE FOR INITIALIZATION
C----------------------------------------------------------------------

      END
      SUBROUTINE HWANAL(IEV)

C     USER'S ROUTINE TO ANALYSE DATA FROM EVENT
C----------------------------------------------------------------------

      integer IEV
c      INCLUDE "pyt_cms_short.inc"
      include 'pyt_strongtyp_short.inc'
cc      if(IEV.le.1) call pylist(5)
      call pyhepc(2)
      if(IEV.le.1) call pylist(1)

        CALL ANZJETS

      END
      SUBROUTINE HWAEND
#include "HERWIG65.INC"
      COMMON/EVPROFILE/NEVTYPE(10)
      INTEGER NEVTYPE
      common/mkpars/nev
      integer nev
      INTEGER lun
      real val, errval
      DOUBLE PRECISION RNWGT,SPWGT,ERWGT

      CALL ANZJETSOUT

      lun = 36
      OPEN(lun, file='testi.dat', status='UNKNOWN', form='formatted')
*
      val = AVWGT ! total cross section (nb)
      RNWGT=1./FLOAT(NWGTS)
      SPWGT=SQRT(MAX(WSQSUM*RNWGT-AVWGT**2,ZERO))
      ERWGT=SPWGT*SQRT(RNWGT)
      errval = ERWGT
      call testfile('jimmy_test2', 1, val, errval)
*
      val = float(nevtype(4))/float(nev) ! fraction with > 1 lept. and > 1 jets
      errval = 0.
      if(nevtype(4).gt.0) then
        errval = val*sqrt(float(nevtype(4)))/float(nevtype(4))
      endif
      call testfile('jimmy_test2', 2, val, errval)
*
      close(lun)


      END


* MK: two HERWIG routine below are modified to allow the decay in e, mu, tau
* instead of only e, mu

CDECK  ID>, HWDBOZ.
*CMZ :-        -29/04/91  18.00.03  by  Federico Carminati
*-- Author :    Mike Seymour
C-----------------------------------------------------------------------
      SUBROUTINE HWDBOZ(IDBOS,IFER,IANT,CV,CA,BR,IOPT)
C-----------------------------------------------------------------------
C     CHOOSE DECAY MODE OF BOSON
C     IOPT=2 TO RESET COUNTERS, 1 FOR BOSON PAIR, 0 FOR ANY OTHERS
C-----------------------------------------------------------------------
      INCLUDE 'HERWIG65.INC'
      DOUBLE PRECISION HWRGEN,BRMODE(12,3),CV,CA,BR,BRLST,BRCOM,FACZ,
     & FACW
      INTEGER HWRINT,IDBOS,IDEC,IDMODE(2,12,3),IFER,IANT,IOPT,I1,I2,
     & I1LST,I2LST,NWGLST,NUMDEC,NPAIR,MODTMP,JFER
      LOGICAL GENLST
      EXTERNAL HWRGEN,HWRINT
      SAVE FACW,FACZ,NWGLST,GENLST,NUMDEC,NPAIR,I1LST,I2LST,BRLST
      SAVE IDMODE,BRMODE
      DATA NWGLST,GENLST,NPAIR/-1,.FALSE.,0/
C---STORE THE DECAY MODES (FERMION FIRST)
      DATA IDMODE/  2,  7,  4,  9,  6, 11,  2,  9,  4,  7,
     &            122,127,124,129,126,131,8*0,
     &              1,  8,  3, 10,  5, 12,  3,  8,  1, 10,
     &            121,128,123,130,125,132,8*0,
     &              1,  7,  2,  8,  3,  9,  4, 10,  5, 11,  6, 12,
     &            121,127,123,129,125,131,122,128,124,130,126,132/
C---STORE THE BRANCHING RATIOS TO THESE MODES
      DATA BRMODE/0.321D0,0.321D0,0.000D0,0.017D0,0.017D0,0.108D0,
     &            0.108D0,0.108D0,4*0.0D0,
     &            0.321D0,0.321D0,0.000D0,0.017D0,0.017D0,0.108D0,
     &            0.108D0,0.108D0,4*0.0D0,
     &            0.154D0,0.120D0,0.154D0,0.120D0,0.152D0,0.000D0,
     &            0.033D0,0.033D0,0.033D0,0.067D0,0.067D0,0.067D0/
C---FACTORS FOR CV AND CA FOR W AND Z
      DATA FACW,FACZ/2*0.0D0/
      IF (FACZ.EQ.ZERO) FACZ=SQRT(SWEIN)
      IF (FACW.EQ.ZERO) FACW=0.5/SQRT(2D0)
      IF (IDBOS.LT.198.OR.IDBOS.GT.200) THEN
        CALL HWWARN('HWDBOZ',101)
        GOTO 999
      ENDIF
C---IF THIS IS A NEW EVENT SINCE LAST TIME, ZERO COUNTERS
      IF (NWGTS.NE.NWGLST .OR.(GENEV.NEQV.GENLST).OR. IOPT.EQ.2) THEN
        NPAIR=0
        NUMDEC=0
        NWGLST=NWGTS
        GENLST=GENEV
        IF (IOPT.EQ.2) RETURN
      ENDIF
      NUMDEC=NUMDEC+1
      IF (NUMDEC.GT.MODMAX) THEN
        CALL HWWARN('HWDBOZ',102)
        GOTO 999
      ENDIF
C---IF PAIR OPTION SPECIFIED FOR THE FIRST TIME, MAKE CHOICE
      IF (IOPT.EQ.1) THEN
        IF (NUMDEC.GT.MODMAX-1) THEN
          CALL HWWARN('HWDBOZ',103)
          GOTO 999
        ENDIF
        IF (NPAIR.EQ.0) THEN
          IF (HWRGEN(1).GT.HALF) THEN
            MODTMP=MODBOS(NUMDEC+1)
            MODBOS(NUMDEC+1)=MODBOS(NUMDEC)
            MODBOS(NUMDEC)=MODTMP
          ENDIF
          NPAIR=NUMDEC
        ELSE
          NPAIR=0
        ENDIF
      ENDIF
C---SELECT USER'S CHOICE
      IF (IDBOS.EQ.200) THEN
        IF (MODBOS(NUMDEC).EQ.1) THEN
          I1=1
          I2=6
        ELSEIF (MODBOS(NUMDEC).EQ.2) THEN
          I1=7
          I2=7
        ELSEIF (MODBOS(NUMDEC).EQ.3) THEN
          I1=8
          I2=8
        ELSEIF (MODBOS(NUMDEC).EQ.4) THEN
          I1=9
          I2=9
        ELSEIF (MODBOS(NUMDEC).EQ.5) THEN
          I1=7
          I2=9
        ELSEIF (MODBOS(NUMDEC).EQ.6) THEN
          I1=10
          I2=12
        ELSEIF (MODBOS(NUMDEC).EQ.7) THEN
          I1=5
          I2=5
        ELSE
          I1=1
          I2=12
        ENDIF
      ELSE
        IF (MODBOS(NUMDEC).EQ.1) THEN
          I1=1
          I2=5
        ELSEIF (MODBOS(NUMDEC).EQ.2) THEN
          I1=6
          I2=6
        ELSEIF (MODBOS(NUMDEC).EQ.3) THEN
          I1=7
          I2=7
        ELSEIF (MODBOS(NUMDEC).EQ.4) THEN
          I1=8
          I2=8
        ELSEIF (MODBOS(NUMDEC).EQ.5) THEN
          I1=6
          I2=8
        ELSE
          I1=1
          I2=8
        ENDIF
      ENDIF
 10   IDEC=HWRINT(I1,I2)
      IF (HWRGEN(0).GT.BRMODE(IDEC,IDBOS-197).AND.I1.NE.I2) GOTO 10
      IFER=IDMODE(1,IDEC,IDBOS-197)
      IANT=IDMODE(2,IDEC,IDBOS-197)
C---CALCULATE BRANCHING RATIO
C   (RESULT IS NOT WELL-DEFINED AFTER THE FIRST CALL OF A PAIR)
      BR=0
      DO 20 IDEC=I1,I2
 20     BR=BR+BRMODE(IDEC,IDBOS-197)
      IF (IOPT.EQ.1) THEN
        IF (NPAIR.NE.0) THEN
          I1LST=I1
          I2LST=I2
          BRLST=BR
        ELSE
          BRCOM=0
          DO 30 IDEC=MAX(I1,I1LST),MIN(I2,I2LST)
 30         BRCOM=BRCOM+BRMODE(IDEC,IDBOS-197)
          BR=2*BR*BRLST - BRCOM**2
        ENDIF
      ENDIF
C---SET UP VECTOR AND AXIAL VECTOR COUPLINGS (NORMALIZED TO THE
C   CONVENTION WHERE THE WEAK CURRENT IS G*(CV-CA*GAM5) )
      IF (IDBOS.EQ.200) THEN
        IF (IFER.LE.6) THEN
C Quark couplings
           CV=VFCH(IFER,1)
           CA=AFCH(IFER,1)
        ELSE
C lepton couplings
           JFER=IFER-110
           CV=VFCH(JFER,1)
           CA=AFCH(JFER,1)
        ENDIF
        CV=CV * FACZ
        CA=CA * FACZ
      ELSE
        CV=FACW
        CA=FACW
      ENDIF
 999  RETURN
      END
CDECK  ID>, HWDBZ2.
*CMZ :-        -02/04/01  12.11.55  by  Peter Richardson
*-- Author :    Peter Richardson based on Mike Seymour's HWDBOZ
C-----------------------------------------------------------------------
      SUBROUTINE HWDBZ2(IDBOS,IFER,IANT,CV,CA,BR,IOPT,MASS)
C-----------------------------------------------------------------------
C     CHOOSE DECAY MODE OF BOSON
C     IOPT=2 TO RESET COUNTERS, 1 FOR BOSON PAIR, 0 FOR ANY OTHERS
C     IDENTICAL TO HWDBOZ BUT REQUIRES DECAY MODE ACCESSIBLE FOR GIVEN
C     MASS
C-----------------------------------------------------------------------
      INCLUDE 'HERWIG65.INC'
      DOUBLE PRECISION HWRGEN,BRMODE(12,3),CV,CA,BR,BRLST,BRCOM,FACZ,
     & FACW,MSMODE(12,3),MASS
      INTEGER HWRINT,IDBOS,IDEC,IDMODE(2,12,3),IFER,IANT,IOPT,I1,I2,
     & I1LST,I2LST,NWGLST,NUMDEC,NPAIR,MODTMP,JFER,NTRY
      LOGICAL GENLST
      EXTERNAL HWRGEN,HWRINT
      SAVE FACW,FACZ,MSMODE,NWGLST,GENLST,NUMDEC,NPAIR,I1LST,I2LST,BRLST
      SAVE IDMODE,BRMODE
      DATA NWGLST,GENLST,NPAIR/-1,.FALSE.,0/
C---STORE THE DECAY MODES (FERMION FIRST)
      DATA IDMODE/  2,  7,  4,  9,  6, 11,  2,  9,  4,  7,
     &            122,127,124,129,126,131,8*0,
     &              1,  8,  3, 10,  5, 12,  3,  8,  1, 10,
     &            121,128,123,130,125,132,8*0,
     &              1,  7,  2,  8,  3,  9,  4, 10,  5, 11,  6, 12,
     &            121,127,123,129,125,131,122,128,124,130,126,132/
C---STORE THE BRANCHING RATIOS TO THESE MODES
      DATA BRMODE/0.321D0,0.321D0,0.000D0,0.017D0,0.017D0,0.108D0,
     &            0.108D0,0.108D0,4*0.0D0,
     &            0.321D0,0.321D0,0.000D0,0.017D0,0.017D0,0.108D0,
     &            0.108D0,0.108D0,4*0.0D0,
     &            0.154D0,0.120D0,0.154D0,0.120D0,0.152D0,0.000D0,
     &            0.033D0,0.033D0,0.033D0,0.067D0,0.067D0,0.067D0/
      DATA MSMODE/36*0.0D0/
C---FACTORS FOR CV AND CA FOR W AND Z
      DATA FACW,FACZ/2*0.0D0/
      IF (FACZ.EQ.ZERO) FACZ=SQRT(SWEIN)
      IF (FACW.EQ.ZERO) FACW=0.5/SQRT(2D0)
      IF (IDBOS.LT.198.OR.IDBOS.GT.200) THEN
        CALL HWWARN('HWDBZ2',101)
        GOTO 999
      ENDIF
      IF(MSMODE(1,1).EQ.ZERO) THEN
        DO I1=1,12
          DO I2=1,3
            MSMODE(I1,I2)=RMASS(IDMODE(1,I1,I2))+RMASS(IDMODE(2,I1,I2))
          ENDDO
        ENDDO
      ENDIF
C---IF THIS IS A NEW EVENT SINCE LAST TIME, ZERO COUNTERS
      IF (NWGTS.NE.NWGLST .OR.(GENEV.NEQV.GENLST).OR. IOPT.EQ.2) THEN
        NPAIR=0
        NUMDEC=0
        NWGLST=NWGTS
        GENLST=GENEV
        IF (IOPT.EQ.2) RETURN
      ENDIF
      NUMDEC=NUMDEC+1
      IF (NUMDEC.GT.MODMAX) THEN
        CALL HWWARN('HWDBZ2',102)
        GOTO 999
      ENDIF
C---IF PAIR OPTION SPECIFIED FOR THE FIRST TIME, MAKE CHOICE
      IF (IOPT.EQ.1) THEN
        IF (NUMDEC.GT.MODMAX-1) THEN
          CALL HWWARN('HWDBZ2',103)
          GOTO 999
        ENDIF
        IF (NPAIR.EQ.0) THEN
          IF (HWRGEN(1).GT.HALF) THEN
            MODTMP=MODBOS(NUMDEC+1)
            MODBOS(NUMDEC+1)=MODBOS(NUMDEC)
            MODBOS(NUMDEC)=MODTMP
          ENDIF
          NPAIR=NUMDEC
        ELSE
          NPAIR=0
        ENDIF
      ENDIF
C---SELECT USER'S CHOICE
      IF (IDBOS.EQ.200) THEN
        IF (MODBOS(NUMDEC).EQ.1) THEN
          I1=1
          I2=6
        ELSEIF (MODBOS(NUMDEC).EQ.2) THEN
          I1=7
          I2=7
        ELSEIF (MODBOS(NUMDEC).EQ.3) THEN
          I1=8
          I2=8
        ELSEIF (MODBOS(NUMDEC).EQ.4) THEN
          I1=9
          I2=9
        ELSEIF (MODBOS(NUMDEC).EQ.5) THEN
          I1=7
          I2=9
        ELSEIF (MODBOS(NUMDEC).EQ.6) THEN
          I1=10
          I2=12
        ELSEIF (MODBOS(NUMDEC).EQ.7) THEN
          I1=5
          I2=5
        ELSE
          I1=1
          I2=12
        ENDIF
      ELSE
        IF (MODBOS(NUMDEC).EQ.1) THEN
          I1=1
          I2=5
        ELSEIF (MODBOS(NUMDEC).EQ.2) THEN
          I1=6
          I2=6
        ELSEIF (MODBOS(NUMDEC).EQ.3) THEN
          I1=7
          I2=7
        ELSEIF (MODBOS(NUMDEC).EQ.4) THEN
          I1=8
          I2=8
        ELSEIF (MODBOS(NUMDEC).EQ.5) THEN
          I1=6
          I2=8
        ELSE
          I1=1
          I2=8
        ENDIF
      ENDIF
      NTRY = 0
 10   IDEC=HWRINT(I1,I2)
      NTRY = NTRY+1
      IF (HWRGEN(0).GT.BRMODE(IDEC,IDBOS-197).AND.I1.NE.I2) GOTO 10
      IF(MASS.LT.MSMODE(IDEC,IDBOS-197).AND.NTRY.LT.NBTRY) GOTO 10
      IF(NTRY.GE.NBTRY) THEN
        BR = ZERO
        RETURN
      ENDIF
      IFER=IDMODE(1,IDEC,IDBOS-197)
      IANT=IDMODE(2,IDEC,IDBOS-197)
C---CALCULATE BRANCHING RATIO
C   (RESULT IS NOT WELL-DEFINED AFTER THE FIRST CALL OF A PAIR)
      BR=0
      DO 20 IDEC=I1,I2
 20     IF(MSMODE(IDEC,IDBOS-197).LT.MASS) BR=BR+BRMODE(IDEC,IDBOS-197)
      IF (IOPT.EQ.1) THEN
        IF (NPAIR.NE.0) THEN
          I1LST=I1
          I2LST=I2
          BRLST=BR
        ELSE
          BRCOM=0
          DO 30 IDEC=MAX(I1,I1LST),MIN(I2,I2LST)
 30         IF(MSMODE(IDEC,IDBOS-197).LT.MASS)
     &            BRCOM=BRCOM+BRMODE(IDEC,IDBOS-197)
          BR=2*BR*BRLST - BRCOM**2
        ENDIF
      ENDIF
C---SET UP VECTOR AND AXIAL VECTOR COUPLINGS (NORMALIZED TO THE
C   CONVENTION WHERE THE WEAK CURRENT IS G*(CV-CA*GAM5) )
      IF (IDBOS.EQ.200) THEN
        IF (IFER.LE.6) THEN
C Quark couplings
           CV=VFCH(IFER,1)
           CA=AFCH(IFER,1)
        ELSE
C lepton couplings
           JFER=IFER-110
           CV=VFCH(JFER,1)
           CA=AFCH(JFER,1)
        ENDIF
        CV=CV * FACZ
        CA=CA * FACZ
      ELSE
        CV=FACW
        CA=FACW
      ENDIF
 999  RETURN
      END

* MK: this routine is modified in order to understand some additional
* HERWIG status codes when converting HEPEVT to PYTHIA record.

C*********************************************************************
 
C...PYHEPC
C...Converts PYTHIA event record contents to or from
C...the standard event record commonblock.
 
      SUBROUTINE PYHEPC(MCONV)
 
C...Double precision and integer declarations.
      IMPLICIT DOUBLE PRECISION(A-H, O-Z)
      IMPLICIT INTEGER(I-N)
      INTEGER PYK,PYCHGE,PYCOMP
C...Commonblocks.
      COMMON/PYJETS/N,NPAD,K(4000,5),P(4000,5),V(4000,5)
      COMMON/PYDAT1/MSTU(200),PARU(200),MSTJ(200),PARJ(200)
      COMMON/PYDAT2/KCHG(500,4),PMAS(500,4),PARF(2000),VCKM(4,4)
      SAVE /PYJETS/,/PYDAT1/,/PYDAT2/
C...HEPEVT
#include "hepevt.inc"
 
C...Conversion from PYTHIA to standard, the easy part.
      IF(MCONV.EQ.1) THEN
        NEVHEP=0
        IF(N.GT.NMXHEP) CALL PYERRM(8,
     &  '(PYHEPC:) no more space in /HEPEVT/')
        NHEP=MIN(N,NMXHEP)
        DO 150 I=1,NHEP
          ISTHEP(I)=0
          IF(K(I,1).GE.1.AND.K(I,1).LE.10) ISTHEP(I)=1
          IF(K(I,1).GE.11.AND.K(I,1).LE.20) ISTHEP(I)=2
          IF(K(I,1).GE.21.AND.K(I,1).LE.30) ISTHEP(I)=3
          IF(K(I,1).GE.31.AND.K(I,1).LE.100) ISTHEP(I)=K(I,1)
          IDHEP(I)=K(I,2)
          JMOHEP(1,I)=K(I,3)
          JMOHEP(2,I)=0
          IF(K(I,1).NE.3.AND.K(I,1).NE.13.AND.K(I,1).NE.14) THEN
            JDAHEP(1,I)=K(I,4)
            JDAHEP(2,I)=K(I,5)
          ELSE
            JDAHEP(1,I)=0
            JDAHEP(2,I)=0
          ENDIF
          DO 100 J=1,5
            PHEP(J,I)=P(I,J)
  100     CONTINUE
          DO 110 J=1,4
            VHEP(J,I)=V(I,J)
  110     CONTINUE
 
C...Check if new event (from pileup).
          IF(I.EQ.1) THEN
            INEW=1
          ELSE
            IF(K(I,1).EQ.21.AND.K(I-1,1).NE.21) INEW=I
          ENDIF
 
C...Fill in missing mother information.
          IF(I.GE.INEW+2.AND.K(I,1).EQ.21.AND.K(I,3).EQ.0) THEN
            IMO1=I-2
  120       IF(IMO1.GT.INEW.AND.K(IMO1+1,1).EQ.21.AND.K(IMO1+1,3).EQ.0)
     &      THEN
              IMO1=IMO1-1
              GOTO 120
            ENDIF
            JMOHEP(1,I)=IMO1
            JMOHEP(2,I)=IMO1+1
          ELSEIF(K(I,2).GE.91.AND.K(I,2).LE.93) THEN
            I1=K(I,3)-1
  130       I1=I1+1
            IF(I1.GE.I) CALL PYERRM(8,
     &      '(PYHEPC:) translation of inconsistent event history')
            IF(I1.LT.I.AND.K(I1,1).NE.1.AND.K(I1,1).NE.11) GOTO 130
            KC=PYCOMP(K(I1,2))
            IF(I1.LT.I.AND.KC.EQ.0) GOTO 130
            IF(I1.LT.I.AND.KCHG(KC,2).EQ.0) GOTO 130
            JMOHEP(2,I)=I1
          ELSEIF(K(I,2).EQ.94) THEN
            NJET=2
            IF(NHEP.GE.I+3.AND.K(I+3,3).LE.I) NJET=3
            IF(NHEP.GE.I+4.AND.K(I+4,3).LE.I) NJET=4
            JMOHEP(2,I)=MOD(K(I+NJET,4)/MSTU(5),MSTU(5))
            IF(JMOHEP(2,I).EQ.JMOHEP(1,I)) JMOHEP(2,I)=
     &      MOD(K(I+1,4)/MSTU(5),MSTU(5))
          ENDIF
 
C...Fill in missing daughter information.
          IF(K(I,2).EQ.94.AND.MSTU(16).NE.2) THEN
            DO 140 I1=JDAHEP(1,I),JDAHEP(2,I)
              I2=MOD(K(I1,4)/MSTU(5),MSTU(5))
              JDAHEP(1,I2)=I
  140       CONTINUE
          ENDIF
          IF(K(I,2).GE.91.AND.K(I,2).LE.94) GOTO 150
          I1=JMOHEP(1,I)
          IF(I1.LE.0.OR.I1.GT.NHEP) GOTO 150
          IF(K(I1,1).NE.13.AND.K(I1,1).NE.14) GOTO 150
          IF(JDAHEP(1,I1).EQ.0) THEN
            JDAHEP(1,I1)=I
          ELSE
            JDAHEP(2,I1)=I
          ENDIF
  150   CONTINUE
        DO 160 I=1,NHEP
          IF(K(I,1).NE.13.AND.K(I,1).NE.14) GOTO 160
          IF(JDAHEP(2,I).EQ.0) JDAHEP(2,I)=JDAHEP(1,I)
  160   CONTINUE
 
C...Conversion from standard to PYTHIA, the easy part.
      ELSE
        IF(NHEP.GT.MSTU(4)) CALL PYERRM(8,
     &  '(PYHEPC:) no more space in /PYJETS/')
        N=MIN(NHEP,MSTU(4))
        NKQ=0
        KQSUM=0
        DO 190 I=1,N
          K(I,1)=0
          IF(ISTHEP(I).EQ.1) K(I,1)=1
          IF(ISTHEP(I).EQ.2) K(I,1)=11
          IF(ISTHEP(I).EQ.3) K(I,1)=21
          IF(ISTHEP(I).GE.120.and.ISTHEP(I).LE.125) K(I,1)=21  ! HERWIG
          IF(ISTHEP(I).GE.195.and.ISTHEP(I).LE.195) K(I,1)=11  ! HERWIG
          K(I,2)=IDHEP(I)
          K(I,3)=JMOHEP(1,I)
          K(I,4)=JDAHEP(1,I)
          K(I,5)=JDAHEP(2,I)
          DO 170 J=1,5
            P(I,J)=PHEP(J,I)
  170     CONTINUE
          DO 180 J=1,4
            V(I,J)=VHEP(J,I)
  180     CONTINUE
          V(I,5)=0D0
          IF(ISTHEP(I).EQ.2.AND.PHEP(4,I).GT.PHEP(5,I)) THEN
            I1=JDAHEP(1,I)
            IF(I1.GT.0.AND.I1.LE.NHEP) V(I,5)=(VHEP(4,I1)-VHEP(4,I))*
     &      PHEP(5,I)/PHEP(4,I)
          ENDIF
 
C...Fill in missing information on colour connection in jet systems.
          IF(ISTHEP(I).EQ.1) THEN
            KC=PYCOMP(K(I,2))
            KQ=0
            IF(KC.NE.0) KQ=KCHG(KC,2)*ISIGN(1,K(I,2))
            IF(KQ.NE.0) NKQ=NKQ+1
            IF(KQ.NE.2) KQSUM=KQSUM+KQ
            IF(KQ.NE.0.AND.KQSUM.NE.0) THEN
              K(I,1)=2
            ELSEIF(KQ.EQ.2.AND.I.LT.N) THEN
              IF(K(I+1,2).EQ.21) K(I,1)=2
            ENDIF
          ENDIF
  190   CONTINUE
        IF(NKQ.EQ.1.OR.KQSUM.NE.0) CALL PYERRM(8,
     &  '(PYHEPC:) input parton configuration not colour singlet')
      ENDIF
 
      END
