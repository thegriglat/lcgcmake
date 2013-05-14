C#@# 1: Z + jets (Z->ee) total cross section [nb] at LHC
C#@# 2: Fraction of events with >=2 isolated charged leptons and >=2 jets
C----------------------------------------------------------------------
      SUBROUTINE RCLOS()
C     DUMMY IF HBOOK IS USED
C----------------------------------------------------------------------
      END


C----------------------------------------------------------------------
      SUBROUTINE HWABEG
C     USER'S ROUTINE FOR INITIALIZATION
C----------------------------------------------------------------------
      integer hwgethepevtsize
      call anzjetshepmcini(hwgethepevtsize())

 999  END


C----------------------------------------------------------------------
      SUBROUTINE HWAEND
C     USER'S ROUTINE FOR TERMINAL CALCULATIONS, HISTOGRAM OUTPUT, ETC
C----------------------------------------------------------------------
      INCLUDE 'HERWIG65.INC'
*
      REAL*8 XNORM
      INTEGER I,J,K
*
      integer lun, nevtype(10)
      real val, errval
      DOUBLE PRECISION RNWGT,SPWGT,ERWGT
*

C XNORM IS SUCH THAT THE CROSS SECTION PER BIN IS IN PB, SINCE THE HERWIG 
C WEIGHT IS IN NB, AND CORRESPONDS TO THE AVERAGE CROSS SECTION
      XNORM=1.D3/DFLOAT(NEVHEP)
C
      call anzjetshepmcout(nevtype)
C
      lun = 36
      OPEN(lun, file='testi.dat', status='UNKNOWN', form='formatted')
*
      val = AVWGT ! total cross section (nb)
      RNWGT=1./FLOAT(NWGTS)
      SPWGT=SQRT(MAX(WSQSUM*RNWGT-AVWGT**2,ZERO))
      ERWGT=SPWGT*SQRT(RNWGT)
      errval = ERWGT
      call testfile('mcatnlo_test1', 1, val, errval)
*
      val = float(nevtype(4))/FLOAT(NWGTS) ! frac. with > 1 lept. and > 1 jets
      errval = 0.
      if(nevtype(4).gt.0) then
        errval = val*sqrt(float(nevtype(4)))/float(nevtype(4))
      endif
      call testfile('mcatnlo_test1', 2, val, errval)
*
      close(lun)

      END

C----------------------------------------------------------------------
      SUBROUTINE HWANAL
C     USER'S ROUTINE TO ANALYSE DATA FROM EVENT
C----------------------------------------------------------------------
      INCLUDE 'HERWIG65.INC'
c
      IF (IERROR.NE.0) RETURN
c
      call anzjetshepmcrun(2)

 999  END
