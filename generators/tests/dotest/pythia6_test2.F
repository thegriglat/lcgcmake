C#@# 1: b bbar production cross section [mb] at LHC
C#@# 2: fraction of Bd in b-bbar events
C#@# 3: fraction of Bu in b-bbar events
C#@# 4: fraction of Bs in b-bbar events
C#@# 5: fraction of b-baryons in b-bbar events
C

      PROGRAM PYTHIA6_TEST2
C
C Common blocks
C
      INCLUDE "general_pythia.inc"
C

      DOUBLE PRECISION ECM
      DOUBLE PRECISION BBBARX, BBBARXERR
      INTEGER BCOUNT, BDCOUNT, BUCOUNT, BSCOUNT
      INTEGER BARIONS
      DOUBLE PRECISION BDFRACT, BUFRACT, BSFRACT, BARFRACT
      DOUBLE PRECISION BDFRACTERR, BUFRACTERR, BSFRACTERR
      DOUBLE PRECISION BARFRACTERR
      INTEGER NEVENTS
      INTEGER BFLAG

C c.m. energy
      ECM=14000.0D0

C the settings below are used by LHCb

C full user control
C processes will be switched on using MSUB
      MSEL = 0

C switching on individual processes
      MSUB(11) = 1
      MSUB(12) = 1
      MSUB(13) = 1
      MSUB(28) = 1
      MSUB(53) = 1
      MSUB(68) = 1
      MSUB(91) = 1
      MSUB(92) = 1
      MSUB(93) = 1
      MSUB(94) = 1
      MSUB(95) = 1
      MSUB(86) = 1
      MSUB(87) = 1
      MSUB(88) = 1
      MSUB(89) = 1
      MSUB(106) = 1

C second order running alpha_s
      MSTP(2) = 2
C inclusion of K factors
      MSTP(33) = 3
C not storing copy of resonance decay products
      MSTP(128) = 2
C gaussian matter distribution for multiple interactions
      MSTP(82) = 3
C PDFLIB (?) for parton distribution
      MSTP(52) = 2
C choice of proton parton-distribution function
      MSTP(51) = 10042
C multiplication of Q^2 scale of the hard scattering
      PARP(67) = 1.0
C regularization scale of the transverse momentum spectrum for multiple
C interaction (GeV)
      PARP(82) = 3.41
C reference energy scale for PARP(81) and PARP(82)
      PARP(89) = 14000.
C power of energy rescalling term
      PARP(90) = 0.162
C probability of two gluons in mulitple int.
      PARP(85) = 0.33
C as above but in closed gluon loop
      PARP(86) = 0.66
C width of Gaussian k distribution in hadron
      PARP(91) = 1.0
C probability that charm or heavier meson has spin 1
      PARJ(13) = 0.750
C probability that spin 0 meson is produced with ang. 1 and tot. 1
      PARJ(14) = 0.162
C probability that spin 1 meson is produced with ang. 1 and tot. 0
      PARJ(15) = 0.018
C probability that spin 1 meson is produced with ang. 1 and tot. 1
      PARJ(16) = 0.054
C probability that spin 1 meson is produced with ang. 1 and tot. 2
      PARJ(17) = 0.090
C no inclusion of B-Bbar mixing in decays
      MSTJ(26) = 0
C remaining energy (GeV) below which is the fragmentation of a parto is
C stopped 
      PARJ(33) = 0.4

C Initialize
      CALL PYINIT('CMS','P','P',ECM)

C reset the number of 'b events'
      BCOUNT = 0
C reset the number of Bd/Bu/Bs/b-baryons
      BDCOUNT=0 
      BUCOUNT=0 
      BSCOUNT=0 
      BARIONS=0

C set the total number of events
      NEVENTS = 100000
C Call event loop
      DO 02 Ievt = 1, NEVENTS
        BFLAG = 0
        CALL PYEVNT

C Check if b-bbar pair is present and count it
        DO 022 Ipart = 1, N
C the variable K(I,2) contains the KF code
          IF ((K(Ipart,2).EQ.5).OR.(K(Ipart,2).EQ.-5)) THEN
            BFLAG = 1
          ENDIF
C measure fractions of Bd/Bu/Bs/b-baryons in b-bbar events
          IF ((K(Ipart,2).EQ.511).OR.(K(Ipart,2).EQ.-511)) THEN
            BDCOUNT = BDCOUNT+1
C            write(*,*) "Bd"
          ENDIF

          IF ((K(Ipart,2).EQ.521).OR.(K(Ipart,2).EQ.-521)) THEN
            BUCOUNT = BUCOUNT+1
C            write(*,*) "Bu"

          ENDIF

          IF ((K(Ipart,2).EQ.531).OR.(K(Ipart,2).EQ.-531)) THEN
            BSCOUNT = BSCOUNT+1
C            write(*,*) "Bs"
          ENDIF

          IF ((K(Ipart,2).EQ.5122).OR.(K(Ipart,2).EQ.-5122).OR.
     &      (K(Ipart,2).EQ.5232).OR.(K(Ipart,2).EQ.-5232).OR.
     &      (K(Ipart,2).EQ.5132).OR.(K(Ipart,2).EQ.-5132)) THEN
            BARIONS = BARIONS+1
C            write(*,*) "Bbario"
          ENDIF          

 022      CONTINUE

C checking if it was a b-event
          IF (BFLAG.EQ.1) THEN
C            write (*,*) 'BBbar event'
C            write (*,*) ''
 
            BCOUNT = BCOUNT+1
C            CALL PYLIST(1)
          ENDIF
 02     CONTINUE
        
C Print cross section table
      CALL PYSTAT(1)

      BBBARX = PARI(1)*BCOUNT/NEVENTS
      BBBARXERR = BBBARX / SQRT(BCOUNT*1.0)
      
      WRITE(6,666) NEVENTS, BCOUNT
      WRITE(6,667) PARI(1), BBBARX, BBBARXERR
      WRITE(6,*) 'Bd ', BDCOUNT, ' Bu ', BUCOUNT, ' Bs ', BSCOUNT, '
     &  Bbario ', BARIONS

C calculating the fraction of different b-events 
      BDFRACT = 1.0*BDCOUNT/BCOUNT/2.0
      BUFRACT = 1.0*BUCOUNT/BCOUNT/2.0
      BSFRACT = 1.0*BSCOUNT/BCOUNT/2.0
      BARFRACT = 1.0*BARIONS/BCOUNT/2.0

      BDFRACTERR = BDFRACT / SQRT(BCOUNT*2.0)
      BUFRACTERR = BDFRACT / SQRT(BCOUNT*2.0)
      BSFRACTERR = BDFRACT / SQRT(BCOUNT*2.0)
      BARFRACTERR = BARFRACT / SQRT(BCOUNT*2.0)

 666  format(/ ' Total number of events ', I6,
     &       ' number of bbbar events ', I6)

 667  format(/ ' Total Xsection ', E12.4,
     &       ' mb;  bbbar Xsection ', E12.4, ' mb +/- ', E12.4)


      call testfileopen
      call testfile('pythia6_test2', 1, REAL(BBBARX), REAL(BBBARXERR))
      call testfile('pythia6_test2', 2, REAL(BDFRACT), REAL(BDFRACTERR))
      call testfile('pythia6_test2', 3, REAL(BUFRACT), REAL(BUFRACTERR))
      call testfile('pythia6_test2', 4, REAL(BSFRACT), REAL(BSFRACTERR))
      call testfile('pythia6_test2', 5, REAL(BARFRACT), REAL(BARFRACTERR
     &  ))
      call testfileclose

      END
