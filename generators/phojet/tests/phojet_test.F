C#@# . Cross-section [mb] in multiple processes
C#@# . For all cases C.m.s energy is 50 GeV
C#@# . Reference values of cross-sections were produced with NEVT=100000 
C#@# 1 Beams: P P
C#@# 2 Beams: GAMMA P
C#@# 3 Beams: GAMMA GAMMA

      PROGRAM PHOEX3
C**********************************************************************
C
C     example how to call PHOJET 1.04/1.05 without input cards
C
C**********************************************************************
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
      SAVE
C
      PARAMETER (ZERO   =  0.D0,
     &           IZERO  =  0,
     &           ONE    =  1.D0,
     &           TWO    =  2.D0,
     &           OHALF  =  0.5D0,
     &           PI     =  3.14159265359D0,
     &           TWOPI  =  6.28318530718D0,
     &           TINY   =  1.D-10,
     &           DEPS   =  1.D-10)
C
      COMMON /GLOCMS/ ECM,PCM,PMASS(2),PVIRT(2),IFPAP(2),IFPAB(2)
C
C  phojet global process flags
      COMMON /PROCES/ IPROCE,IDNODF,IDIFR1,IDIFR2,IDDPOM,IPRON(15,4)
C
      CHARACTER*8 MDLNA
      COMMON /MODELS/ MDLNA(50),ISWMDL(50),PARMDL(200),IPAMDL(200)
C
C  cross sections
      COMMON /POWGHT/ SIGGEN(4),HSWGHT(0:10),HSWCUT(20),EVWGHT(0:10),
     &                IPOWGC(0:10),ISWCUT(20),IVWGHT(0:10)
C
      DIMENSION IDPDG(6),ECMTAB(3),PAMTAB(6),P1(4),P2(4)
      DATA IDPDG / 2212, 2212, 22, 2212, 22, 22 /
      DATA ECMTAB / 10.D0, 20.D0, 50.D0 /
      DATA PAMTAB / 0.938D0, 0.938D0, 0.D0, 0.938D0, 2*0.D0 /
C
C  *********** hp compiler settings ******************************
*     ON DOUBLE PRECISION UNDERFLOW IGNORE
*     ON REAL UNDERFLOW IGNORE
C  **************************************************************
C
C
C  general initialization of phojet data structures
      CALL PHO_INIT(-1,IREJ)
      write(*,*)'DBG: PHO_INIT returned'
C
C open file testi.dat for output of cross-sections
      CALL PRINT_TEST(-1)
C
C  switch elastic, quasi-elastic and single-diff. processes on
      IPRON(2,1) = 1
      IPRON(3,1) = 1
      IPRON(4,1) = 1
      IPRON(5,1) = 1
      IPRON(6,1) = 1
C  set new pomeron PDF
      CALL PHO_SETPDF(45,IDUM,2,0,0,0,-1)
C
C  loop over particle and energy combinations
      DO 100 I=1,3
        DO 200 K=3,3
          write(*,*)'DBG: i:',i,' k:',k
C****
          NEVE = 10000
C****
          ECM = ECMTAB(K)
          write(*,*)'DBG: ECM(',k,'):',ECM
          IDPDGA = IDPDG(2*I-1)
          IDPDGB = IDPDG(2*I)
          PMASS1 = PAMTAB(2*I-1)
          PMASS2 = PAMTAB(2*I)
C
C  CMS kinematics
          S=ECM**2
          PM1 = PMASS1**2
          PM2 = PMASS2**2
          PCM = SQRT(S**2 - TWO*PM1*S - TWO*PM2*S - TWO*PM1*PM2
     &          + PM1**2 + PM2**2)/(TWO*ECM)
          EE = SQRT( PM1 + PCM**2 )
          P1(1) = ZERO
          P1(2) = ZERO
          P1(3) = PCM
          P1(4) = EE
          P2(1) = ZERO
          P2(2) = ZERO
          P2(3) = -PCM
          P2(4) = ECM-EE
C
C  initialize phojet for given energy, particle combination
          PVIR = 0.D0
          CALL PHO_SETPAR(1,IDPDGA,0,PVIR)
          CALL PHO_SETPAR(2,IDPDGB,0,PVIR)
          CALL PHO_EVENT(-1,P1,P2,SIGMAX,IREJ)
C
C  event generation loop
          ITRY = 0
          WRITE(6,'(//1X,A,2I7,I10//)') 
     &      'CALCULATION FOR IDPDGA,IDPDGB,NEVE:',IDPDGA,IDPDGB,NEVE
          DO 50 J=1,NEVE
 55         CONTINUE
            ITRY = ITRY+1
            WGHT = 1.D0
            CALL PHO_EVENT(1,P1,P2,SIGCUR,IREJ)
            IF(IREJ.NE.0) GOTO 55
 50       CONTINUE
C
C  statistics output
          CALL PHO_EVENT(-2,P1,P2,SIGMAX,IREJ)
          CALL PRINT_TEST(I)
C
C  output of histograms
CC          CALL POMINB(-2,ONE)
 200    CONTINUE
 100  CONTINUE
C
C  close the file
      CALL PRINT_TEST(0)
C
      END
C
C
      SUBROUTINE PRINT_TEST(I)
C=============================================
C     Input: I =  -1    OPEN file 'testi.dat'
C              =   0    CLOSE output
C              >   0    I - test number: WRITE cross-section
C=============================================
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
      SAVE
C
      PARAMETER (NMAXD=100)
      COMMON /PODEBG/ IDEB(NMAXD),KSPOM,KHPOM,KSREG,KHDIR,KACCEP,KSTRG,
     &                KHTRG,KSLOO,KHLOO,KSDPO,KHDPO,KEVENT,KSOFT,KHARD
C
     COMMON /POWGHT/ SIGGEN(4),HSWGHT(0:10),HSWCUT(20),EVWGHT(0:10),
     &                IPOWGC(0:10),ISWCUT(20),IVWGHT(0:10)

      INTEGER I
C
      IF (I .LT. 0)  THEN
         OPEN(unit = 10, file = 'testi.dat', status = 'unknown')
      ELSE IF (I .EQ. 0)  THEN
         CLOSE(10)
      ELSE
c...     Printing the total accepted cross section and its uncerainty to testi.dat:
         WRITE(10,100) I, SIGGEN(1), SIGGEN(1)/sqrt(DBLE(KACCEP))
      END IF
C
100   FORMAT('phojet_test ',I3,2(1PE15.6))
      RETURN
      END

