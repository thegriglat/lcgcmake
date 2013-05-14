C#@# QCD 2->2 hard parton scattering cross section [nb] at LHC
      PROGRAM HRW_JIMMY
c     -----------------
c     Example main program to run JIMMY at LHC with
c     100 GeV jets plus MI underlying event. Change IPROC
c     do do other stuff.
c     Jon Butterworth 18/03/04
c     --------------------------------
c     HERWIG/JIMMY COMMONS. HERWIG COMMON INCLUDES AN IMPLICIT NONE.
      INCLUDE 'HERWIG65.INC'
      INCLUDE 'pyt_strongtyp_short.inc'
      INCLUDE 'jimmy.inc'

      LOGICAL ABORT
      INTEGER LOOP
      DOUBLE PRECISION HWRSET
      integer jimmy_flag

c     =============================================================
      
      jimmy_flag=0  
C---  Turn MI on(1) or off(0)
      MSFLAG=1
      if(jimmy_flag.ne.1) MSFLAG=0
      OPEN(38, file='jim38.out', status='UNKNOWN', form='formatted')
      call pyckbd
      print*,'pyckbd'

      CALL COLLIDERINI
      print*,'COLLIDERINI'

c     Set beam energies
      PART1='P  '
      PART2='P  '
      PBEAM1=7000.0
      PBEAM2=7000.0
      
c     QCD 2->2 with S.U.E suppressed
c      IPROC=11500           !cpol
c     QCD 2->2 hard parton scattering
       IPROC=1500


C     HERWIG initialization
      CALL HWIGIN
C     JIMMY initialization
      if(jimmy_flag.eq.1) CALL JIMMIN

c      MODPDF(1)=46
c      AUTPDF(1)='CTEQ'
c      MODPDF(2)=46
c      AUTPDF(2)='CTEQ'


c     Minimum PT of the hardest scatter
cpol      PTMIN=100.
      PTMIN=3.0

c     Minimum PT of secondary scatters
cpol      PTJIM=2.5
cpol      PTJIM=1.0
cpol       jmrad(73) = 2.0D-00
c      JMUEO=0
C     More initialization.
      CALL HWUINC
      CALL HWEINI            
      if(jimmy_flag.eq.1)   CALL JMINIT

      MAXEV=1000
      MAXER=MAXEV/5

C     Initialise your histograms here.
      CALL HWABEG

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
c         IF (ABORT)  write(38, 210) loop    
c 210  format(2x,'abort',i4)   !cpol
            IF (ABORT) GOTO 50
c      write(38, 211) loop          !cpol
c 211  format(2x,'loop',i4)         !cpol
      
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
C     Finish off JIMMY
      if(jimmy_flag.eq.1)       CALL JMEFIN
      
C     Close & ouput histograms.here
      CALL HWAEND
      END


C----------------------------------------------------------------------
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

       CALL HWGHEP(1)   !cpol
      END
c-----------------------------------------------------------------------
      SUBROUTINE HWAEND
#include "HERWIG65.INC"
      INCLUDE 'jimmy.inc'
      COMMON/EVPROFILE/NEVTYPE(10)
      INTEGER NEVTYPE
      common/mkpars/nev
      integer nev
      INTEGER lun
      real val, errval
      DOUBLE PRECISION RNWGT,SPWGT,ERWGT

      lun = 36
      OPEN(lun, file='testi.dat', status='UNKNOWN', form='formatted')
*
      val = AVWGT                  ! total cross section (nb)
      RNWGT=1./FLOAT(NWGTS)
      SPWGT=SQRT(MAX(WSQSUM*RNWGT-AVWGT**2,ZERO))
      ERWGT=SPWGT*SQRT(RNWGT)
      errval = ERWGT
      call testfile('jimmy_test1', 1, val, errval)
*
c
      val = float(nevtype(4))/float(nev) ! fraction with > 1 lept. and > 1 jets
      errval = 0.
      if(nevtype(4).gt.0) then
        errval = val*sqrt(float(nevtype(4)))/float(nevtype(4))
      endif
c      call testfile('jimmy_test1', 2, val, errval) !cpol
*
      close(lun)


      END


* MK: this routine is modified in order to understand some additional
* HERWIG status codes when converting HEPEVT to PYTHIA record.

C*********************************************************************

      subroutine HWGHEP(mconv)

C...Purpose: to convert HERWIG event record contents to or from
C...the standard event record common block.
C...convert (mconv=1) from HERWIG numbering scheme to PDG numbering scheme
C...     or (mconv=2) from PDG numbering scheme to HERWIG numbering scheme

C...Only IDHEP needs to be changed
C   1/28/98 - Overwrite particle ID as used in Herwig

cpol#include "CLHEP/StdHep/include/herwig64.inc"
      INCLUDE 'HERWIG65.INC'

      integer itmp,hwtran,mconv,I,J

C...Conversion from HERWIG to standard.
      if(mconv.EQ.1) then
        do 140 I=1,NHEP
          if(IDHEP(I).NE.0)then
            itmp=IDHEP(I)
            IDHEP(I) = hwtran(itmp,1)
          elseif(IDHW(I).EQ.20)then
C...????
            IDHEP(I)=89
          elseif(IDHW(I).LE.18)then
C...the oddball intermediate states
            IDHEP(I)=IDHW(I)+67
          else
C...undefined
            IDHEP(I)=0
          endif
 140    CONTINUE
C...Conversion from standard to HERWIG.
      elseif(mconv.EQ.2)then
        do 180 I=1,NHEP
          itmp=IDHEP(I)
          IDHEP(I) = hwtran(itmp,2)
 180    CONTINUE
      endif
      return
      end

      integer function hwtran(ID,mconv)
C...convert (mconv=1) from HERWIG numbering scheme to PDG numbering scheme
C...     or (mconv=2) from PDG numbering scheme to HERWIG numbering scheme
C
C           ID = particle identification number

C -------------------------------------------------------------
C
      integer LNHWRT,LNHRD,LNHOUT,LNHDCY,LNHRDM
      common/HEPLUN/LNHWRT,LNHRD,LNHOUT,LNHDCY,LNHRDM(15)
      save /HEPLUN/
C
C -------------------------------------------------------------
C... ITABJ(I) converts miscellaneous HERWIG particle ID's to a standard scheme
      integer ITABJ(99,2), NOANT(4)
      data ITABJ/1,2,3,4,5,6,7,8,0,0,
     1           11,12,13,14,15,16,0,0,0,0,
     2           21,22,23,24,25,0,0,0,0,0,
     3           0,30,0,0,0,0,0,0,0,0,
     4           0,0,0,0,0,0,0,0,0,0,
     5           0,0,0,0,0,0,0,0,0,0,
     6           0,0,0,0,0,0,0,0,0,0,
     7           0,0,0,0,0,0,0,0,0,0,
     8           81,82,83,84,85,86,87,88,89,90,
     9           91,92,93,94,95,96,97,98,99,
     *           1,2,3,4,5,6,7,8,0,0,
     1           11,12,13,14,15,16,0,0,0,0,
     2           21,22,23,24,25,0,0,0,0,32,
     3           0,0,0,0,0,0,0,0,0,0,
     4           0,0,0,0,0,0,0,0,0,0,
     5           0,0,0,0,0,0,0,0,0,0,
     6           0,0,0,0,0,0,0,0,0,0,
     7           0,0,0,0,0,0,0,0,0,0,
     8           81,82,83,84,85,86,87,88,89,90,
     9           91,92,93,94,95,96,97,98,99/
      data NOANT/-21,-22,-23,-25/
      save ITABJ,NOANT

      hwtran=ID
      IDA=IABS(ID)
      J1=MOD(IDA,10)
      I1=MOD(IDA/10,10)
      I2=MOD(IDA/100,10)
      I3=MOD(IDA/1000,10)
      I4=MOD(IDA/10000,10)

      if(IDA.EQ.0)then
C..        write(LNHOUT,*) ' HWTRAN 1: particle ID is zero'
      elseif(mconv.LT.1 .OR. mconv.GT.2)then
        hwtran=0
        write(LNHOUT,*) ' HWTRAN 2: unallowed conversion option'
      elseif(IDA.LT.100)then
C...Higgs, etc.
        hwtran=isign(ITABJ(IDA,mconv),ID)
C...check for illegal antiparticles
        if(ID.LT.0)then
          if(hwtran.GE.-99 .AND. hwtran.LE.-81) hwtran=0
          do 101 J=1,4
            if(hwtran.EQ.NOANT(J)) hwtran=0
 101      CONTINUE
        endif
      elseif(I1.NE.0 .AND. I3.NE.0 .AND. J1.EQ.2)then
C...spin 1/2 baryons
      elseif(I1.NE.0 .AND. I3.NE.0 .AND. J1.EQ.4)then
C...spin 3/2 baryons
      elseif(I1.NE.0 .AND. I3.NE.0 .AND. J1.EQ.0)then
C...special case "baryons"
      elseif(I1.NE.0 .AND. I2.NE.0 .AND. I3.EQ.0)then
C...mesons 
        if(mconv.EQ.1)then
          if(IDA.EQ.20413) hwtran=isign(10413,ID)
          if(IDA.EQ.20423) hwtran=isign(10423,ID)
          if(IDA.EQ.20433) hwtran=isign(10433,ID)
          if(IDA.EQ.20443) hwtran=isign(30443,ID)
          if(IDA.EQ.30443) hwtran=isign(40443,ID)
        elseif(mconv.EQ.2) then
          if(IDA.EQ.10413) hwtran=isign(20413,ID)
          if(IDA.EQ.10423) hwtran=isign(20423,ID)
          if(IDA.EQ.10433) hwtran=isign(20433,ID)
          if(IDA.EQ.30443) hwtran=isign(20443,ID)
          if(IDA.EQ.40443) hwtran=isign(30443,ID)
          if(IDA.EQ.20413) hwtran=0
          if(IDA.EQ.20423) hwtran=0
          if(IDA.EQ.20433) hwtran=0
C...all 3 chi c states map to a single chi c state
          if(IDA.EQ.20443) hwtran=10441
          if(IDA.EQ.445) hwtran=10441
        endif
C...check for illegal antiparticles
        if(I1.EQ.I2 .AND. ID.LT.0) hwtran=0
      elseif(I2.NE.0 .AND. I3.NE.0 .AND. I1.EQ.0)then
C...diquarks
      else
C...undefined
        hwtran=0
      endif
C...check for illegal anti KS, KL
      if(ID.EQ.-130 .OR. ID.EQ.-310) hwtran=0

      if(hwtran.EQ.0 .AND. IDA.NE.0)then
        if(mconv.EQ.1) write(LNHOUT,111) ID
        if(mconv.EQ.2) write(LNHOUT,112) ID
      endif
 111  format('  HWTRAN 3: HERWIG particle ',I8,' translates to zero')
 112  format('  HWTRAN 3: PDG particle ',I8,' translates to zero')
      return
      end


 
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
