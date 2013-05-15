C#@# Cross sections [mb] of multiple processes 
C#@# (see the source file for the process list) if not vanishing.
C#@# C.m.s. energy is 14 TeV for pp-collisions.
C#@# Made from the standard pythia example 62.
C#@# Note that processes missing from the cross section table
C#@# could have non-vanishing cross sections with different settings.

C...Run to check that all processes allowed work and to clock them.
C...PYTIME must be interfaced to local clock for this to work.
C...Replace suitably if you want CPU time rather than elapsed one.

C AR: for testing old Pythia (6.1xx) uncomment lines
C AR: labeled C-AR below

C-----------------------------------------------------------------
      PROGRAM PYTHIA6_TEST3

C
      INCLUDE "general_pythia.inc"
C

C...Local arrays.
      INTEGER NGENMY(0:500)

      DIMENSION INEP(10),INEE(20),INGAP(10),INGAGA(10),INGAST(10),
     &INEESS(10),INGSTP(10),MSTP14(20),ITIME(6),ITUSED(500),SIGTOT(500)
C...Processes needing other collider types than pp.
      DATA INEP/145,9*0/
      DATA INEE/70,103,146,153,158,343,344,345,346,347,348,9*0/
      DATA INGAP/33,34,35,36,54,80,84,107,2*0/
      DATA INGAGA/58,69,85,108,6*0/
      DATA INGAST/99,137,138,139,140,5*0/
      DATA INEESS/341,342,8*0/
      DATA INGSTP/131,132,133,134,135,136,4*0/
C...Processes needing MSTP(14)=0.
      DATA MSTP14/33,34,35,36,54,58,69,70,80,84,85,103,107,108,153,
     &158,4*0/

C...Default values time consumption.
      DATA ITUSED/500*-1/ 
      real value,errvalue
      integer isubi
C-----------------------------------------------------------------

C...First section: common parameters.

C...Number of events per case.
      NEV=100

C...Minimize printout.
      MSTP(122)=0

C...Do not crash if vanishing cross section.
      MSTP(127)=1

C...Set SUSY parameters in SUGRA scenario.
      IMSS(1)=2
      RMSS(1)=200D0
      RMSS(4)=1D0
      RMSS(5)=10D0
      RMSS(8)=800D0
      RMSS(16)=0D0

C-----------------------------------------------------------------

C...Second section: process and event loops.
      CALL PYLIST(0)
 
C...Loop over processes; check which to skip. 
      DO 300 ISUB=1,500
      IF(ISET(ISUB).LT.0.OR.ISET(ISUB).EQ.9) GOTO 300
        if(isub.eq.4)  goto300
        if(isub.eq.6)  goto300
        if(isub.eq.7)  goto300
        if(isub.eq.9)  goto300
        if(isub.eq.17) goto300
        if(isub.eq.21) goto300
        if(isub.eq.27) goto300
        if(isub.ge.37.and.isub.le.67) goto300
        if(isub.eq.74) goto300
        if(isub.eq.75) goto300
        if(isub.eq.78) goto300
        if(isub.eq.79) goto300
        if(isub.eq.90) goto300
        if(isub.eq.96) goto300
        if(isub.eq.97) goto300
        if(isub.eq.98) goto300
        if(isub.eq.100) goto300
        if(isub.eq.101) goto300
        if(isub.eq.109) goto300
        if(isub.ge.116.and.isub.le.120) goto300
        if(isub.ge.125.and.isub.le.130) goto300
        if(isub.eq.150) goto300
        if(isub.eq.154) goto300
        if(isub.eq.155) goto300
        if(isub.eq.159) goto300
        if(isub.eq.160) goto300
        if(isub.eq.170) goto300
        if(isub.ge.175.and.isub.le.180) goto300
        if(isub.ge.196.and.isub.le.200) goto300
        if(isub.eq.203) goto300
        if(isub.eq.206) goto300
C proc 209 failed for 6.1xx
C-AR        if(isub.eq.209) goto300
C proc 211 failed for 6.1xx
C-AR        if(isub.eq.211) goto300
        if(isub.eq.215) goto300
        if(isub.eq.245) goto300
        if(isub.eq.255) goto300
        if(isub.eq.257) goto300
        if(isub.eq.260) goto300
        if(isub.ge.266.and.isub.le.270) goto300
        if(isub.ge.302.and.isub.le.340) goto300
        if(isub.ge.355.and.isub.le.360) goto300
        if(isub.eq.369) goto300
        if(isub.ge.378.and.isub.le.380) goto300
        if(isub.eq.389) goto300
        if(isub.eq.390) goto300
        if(isub.ge.396.and.isub.le.400) goto300
        if(isub.ge.403.and.isub.le.420) goto300
        if(isub.ge.440.and.isub.le.460) goto300
        if(isub.ge.480) goto300

      WRITE(6,*) 'Now begin process ',ISUB   

C...Switch on desired subprocess and off the rest.
      MSEL=0
      DO 110 J=1,500
 110  MSUB(J)=0
      MSUB(ISUB)=1    

C...Decide on collider type; default is pp.
      ITYPE=1
      DO 120 J=1,10
        IF(ISUB.EQ.INEP(J)) ITYPE=2
        IF(ISUB.EQ.INEE(J)) ITYPE=3
        IF(ISUB.EQ.INEE(J+10)) ITYPE=3
        IF(ISUB.EQ.INGAP(J)) ITYPE=4
        IF(ISUB.EQ.INGAGA(J)) ITYPE=5
        IF(ISUB.EQ.INGAST(J)) ITYPE=6
        IF(ISUB.EQ.INEESS(J)) ITYPE=7
        IF(ISUB.EQ.INGSTP(J)) ITYPE=8
  120 CONTINUE

C...Set MSTP(14)=0 rather than default for some processes..
      MSTP(14)=30
      DO 130 J=1,20
        IF(ISUB.EQ.MSTP14(J)) MSTP(14)=0
  130 CONTINUE
      IF(ISUB.EQ.99) MSTP(14)=26

C...Reset CKIN(3).
      CKIN(3)=0D0

C...Starting time.
      CALL PYTIME(ITIME)
      TOLD=3600D0*ITIME(4)+60D0*ITIME(5)+ITIME(6)
 
C...Initialize for collider type.
C...(These are just convenient choices; could be changed.)
      IF(ITYPE.EQ.1) THEN
        CALL PYINIT('CMS','p','p',14000D0)
      ELSEIF(ITYPE.EQ.2) THEN
        CALL PYINIT('CMS','e+','p',2000D0)
      ELSEIF(ITYPE.EQ.3) THEN
        CALL PYINIT('CMS','e+','e-',2000D0)
      ELSEIF(ITYPE.EQ.4) THEN
        CALL PYINIT('CMS','gamma','p',2000D0)
      ELSEIF(ITYPE.EQ.5) THEN
        CALL PYINIT('CMS','gamma','gamma',2000D0)
      ELSEIF(ITYPE.EQ.6) THEN
        CALL PYINIT('CMS','gamma/e+','gamma/e-',2000D0)
      ELSEIF(ITYPE.EQ.7) THEN
        CALL PYINIT('CMS','e-','e-',200D0)
      ELSEIF(ITYPE.EQ.8) THEN
        CALL PYINIT('CMS','gamma/e-','p',2000D0)
      ENDIF  
 
C...Generate events, unless no cross section found...
      IF(MSTI(53).NE.1) THEN      
        DO 200 IEV=1,NEV
          CALL PYEVNT
  200   CONTINUE
      ELSE
        PARI(1)=-1D0
      ENDIF

C...Finishing time.
      CALL PYTIME(ITIME)
      TNEW=3600D0*ITIME(4)+60D0*ITIME(5)+ITIME(6)

C...Save time and cross sections.
      ITUSED(ISUB)=TNEW-TOLD
      SIGTOT(ISUB)=PARI(1)
      WRITE(6,*) 'Time and cross section: ',ITUSED(ISUB),PARI(1)   
      ngenmy(isub)=NGEN(ISUB,3)
C...End loop over processes.

 300  CONTINUE

C-----------------------------------------------------------------

C...Third section: produce output and end.

C...Loop over processes; write time and cross section.
      call testfileopen

      DO 400 ISUB=1,500
        IF(ITUSED(ISUB).NE.-1)  WRITE(6,'(2X,I4,3X,A28,I8,1P,E12.4)')
     &  ISUB,PROC(ISUB),ITUSED(ISUB),SIGTOT(ISUB)
        
        value=SIGTOT(ISUB)
c        errvalue=value/SQRT(real(NEV))
        if(NGENmy(ISUB).gt.0) errvalue=value/SQRT(real(NGENmy(ISUB)))
        if(isub.eq.4)   goto400
        if(isub.eq.6)   goto400
        if(isub.eq.7)   goto400
        if(isub.eq.9)   goto400
        if(isub.eq.17)  goto400
        if(isub.eq.21)  goto400
        if(isub.eq.27)  goto400
        if(isub.ge.37.and.isub.le.67) goto400
        if(isub.eq.74)  goto400
        if(isub.eq.75)  goto400
        if(isub.eq.78)  goto400
        if(isub.eq.79)  goto400
        if(isub.eq.90)  goto400
        if(isub.eq.96)  goto400
        if(isub.eq.97)  goto400
        if(isub.eq.98)  goto400
        if(isub.eq.100) goto400
        if(isub.eq.101) goto400
        if(isub.eq.109) goto400
        if(isub.ge.116.and.isub.le.120) goto400
        if(isub.ge.125.and.isub.le.130) goto400
        if(isub.eq.150) goto400
        if(isub.eq.154) goto400
        if(isub.eq.155) goto400
        if(isub.eq.159) goto400
        if(isub.eq.160) goto400
        if(isub.eq.170) goto400
        if(isub.ge.175.and.isub.le.180) goto400
        if(isub.ge.196.and.isub.le.200) goto400
        if(isub.eq.203) goto400
        if(isub.eq.206) goto400
        if(isub.eq.215) goto400
        if(isub.eq.245) goto400
        if(isub.eq.255) goto400
        if(isub.eq.257) goto400
        if(isub.eq.260) goto400
        if(isub.ge.266.and.isub.le.270) goto400
        if(isub.ge.302.and.isub.le.340) goto400
        if(isub.ge.355.and.isub.le.360) goto400
        if(isub.eq.369) goto400
        if(isub.ge.378.and.isub.le.380) goto400
        if(isub.eq.389) goto400
        if(isub.eq.390) goto400
        if(isub.ge.396.and.isub.le.400) goto400
        if(isub.ge.403.and.isub.le.420) goto400
        if(isub.ge.440.and.isub.le.460) goto400
        if(isub.ge.480) goto400


        call testfile('pythia6_test3', ISUB, value, errvalue) 
  400 CONTINUE   

      call testfileclose
    
      END

      subroutine testfileopen
      INTEGER lun
      lun = 36
      OPEN(lun, file='testi.dat', status='UNKNOWN', form='formatted')
      END
*
      subroutine testfileclose
      INTEGER lun
      lun = 36
      close(lun)
      END

      subroutine testfile(genname, itest, value, error)
      implicit none
      character*(*) genname
      integer itest
      real value, error
*
      write(36,1) genname, itest, value, error
      return
1     format(A, 1X, I3, 1X, E14.6, 1X, E14.6)
      end

