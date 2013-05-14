C#@# 1: Cross section [mb] of the tW-channel single top production at LHC.
C
* this example provides the generation of tW-channel single top production
* see TXPRO(3) = 1
      PROGRAM TOPREX_test03

      IMPLICIT NONE
#include "txpar.inc" 
#include "txpro.inc" 
      CHARACTER*12 FRAME, BEAM, TARGET
      DOUBLE PRECISION Ecm     ! CMS energy
      INTEGER I
*
C...EXTERNAL statement links PYDATA on most machines.
      EXTERNAL PYDATA
*
      INTEGER          KCHG, MSTP, MSTI, NGENPD, NGEN
      DOUBLE PRECISION PMAS, PARF, VCKM, PARP, PARI
      DOUBLE PRECISION XSEC
      COMMON /PYDAT2/ KCHG(500,4),PMAS(500,4),PARF(2000),VCKM(4,4)
      COMMON /PYPARS/ MSTP(200),PARP(200),MSTI(200),PARI(200)
C...Generation and cross section statistics.
      COMMON /PYINT5/ NGENPD,NGEN(0:500,3),XSEC(0:500,3)
      INTEGER         ITEST/1/

      FRAME  = 'USER'
      BEAM   = 'P'
      TARGET = 'P'
       Ecm    =  14000.d0     ! LHC cms energy (in GeV)
*       txsel = 1
      txpro(3) = 1  ! tW production
      PMAS(6,1)  = 175.d0     ! top mass
      PMAS(24,1) =  80.41d0   ! W mass
      MSTP(51) = 8            ! PDF: CTEQ5L
      CALL TopReX(FRAME, BEAM, TARGET, Ecm)  ! TopRex initialisation
      CALL PYINIT(FRAME,BEAM,TARGET, Ecm)
       do I = 1,500 
        print*,'Event number I=',I
        CALL PYEVNT
c...    at this place analysis routines and/or
c...    detector simulations may be called
      ENDDO

c...Printing out the cross section table:
      call PYSTAT(1)

c...Printing the total cross section and its uncerainty to testi.dat:
c     Opening the file for output:
      open(unit = 10, file = 'testi.dat', status = 'unknown')
      write(10,100) ITEST, XSEC(0,3),XSEC(0,3)/sqrt(dble(NGEN(0,3)))
      close(10)
100   format('toprex_test1',I3,2E15.6)
      END




*-------------
