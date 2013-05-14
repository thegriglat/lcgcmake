C#@#  1  Cross-section [nb] in multiple processes
C#@#  For parameters see <a href=http://svnweb.cern.ch/world/wsvn/GENSER/GENSER2/tests/trunk/data/winhac.dat>winhac.dat</a>

      PROGRAM MAIN
*     ************
*/////////////////////////////////////////////////////////////////////
*// A simple demonstration program for WINHAC - a Monte Carlo Event //
*// Generator for:     p + p(~) --> W + X --> l + nu + X            //     
*// with O(alpha) YFS exponentiation in W decays.                   //
*/////////////////////////////////////////////////////////////////////
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
*   Next line was used 2 years ago for WINHAC 1.23, 1.24 (in 2007)
*      EXTERNAL PYDATA, LHAPDFSET
      DIMENSION Xpar(10000) ! array for input parameters
      CHARACTER*180 DiskFile
      DIMENSION Ivec(7)    
*
* open file <testi.dat> for output of cross-sections
      CALL PRINT_TEST(-1)
*
*///////////////////////////////////////////////////////////////
*//        Define output file of THIS test                    //
*///////////////////////////////////////////////////////////////
      Ninp = 15
      Nout = 16                    
      OPEN(Nout,file='winhac.output')
*///////////////////////////////////////////////////////////////
*//        Read DEFAULT input data file for WINHAC            //
*///////////////////////////////////////////////////////////////
      DiskFile = './winhac_default.dat'
      iReset   = 1
      CALL WH_ReaDataX( DiskFile,     iReset, 10000, Xpar)
*///////////////////////////////////////////////////////////////
*//        Read input data file for THIS test                 //
*///////////////////////////////////////////////////////////////
      DiskFile = './winhac.dat'
      iReset   = 0
      CALL WH_ReaDataX( DiskFile,    iReset, 10000, Xpar)
*///////////////////////////////////////////////////////////////
*//         WINHAC initialization                             //
*///////////////////////////////////////////////////////////////
      CALL WINHAC_Initialize(Ninp,Nout,Xpar)
*! Initialize histograms
      CALL Demo_Test(-1)
*--- Get QCD and hadronization switches from WINHAC
      CALL WH_GetKeyQCD(KeyQCD)
      CALL WH_GetKeyHad(KeyHad)
*--- Get process type
      CALL WH_GetKeyPhy(Ivec)
      KeyWmp = Ivec(1)         ! W- or W+ or both or Z
*///////////////////////////////////////////////////////////////
*//        MAIN EVENT GENERATION LOOP                         //
*///////////////////////////////////////////////////////////////
*===============================================================
*!... Number of events to be generated
      NevTot = 10 000 
      WRITE(6,*)' -------------- WINHAC test -------------------' 
      WRITE(6,*)' NevTot = ',NevTot,' events to be generated ...'
      WRITE(6,*)
      WRITE(nout,*)' --------------- WINHAC test ------------------' 
      WRITE(nout,*)' NevTot = ',NevTot,' events to be generated ...'
      WRITE(nout,*)
      DO Iev = 1,NevTot
        IF(MOD(Iev,1000) .EQ. 0) WRITE(6 ,*) Iev
*! Generate an event
        CALL WINHAC_Make
        IF (Iev.LE.5) THEN
           IF (KeyWmp .LT. 3) THEN
*//--- For W-boson
              CALL WH_PrnLabMom(6)
              CALL WH_PrnLabMom(Nout)
              CALL WH_PrnWrfMom(6)
              CALL WH_PrnWrfMom(Nout)
           ELSE
*//--- For Z-boson
              CALL WH_PrnLabMomZ(6)
              CALL WH_PrnLabMomZ(Nout)
              CALL WH_PrnZrfMom(6)
              CALL WH_PrnZrfMom(Nout)
           ENDIF
           IF (KeyQCD.EQ.1 .OR. KeyHad.EQ.1) THEN
              CALL WH_PyList(6   ,1)    
              CALL WH_PyList(Nout,1)
           ENDIF
        ENDIF
*! Fill histograms
        CALL Demo_Test( 0)
      ENDDO
*===============================================================
*///////////////////////////////////////////////////////////////
*//          Final print-outs from WINHAC                     //
*///////////////////////////////////////////////////////////////
      CALL WINHAC_Finalize
*! Save/print histograms
      CALL Demo_Test( 1)
* Get final total MC x-section to be printed below
      CALL WH_GetXSecMC(XSecMC,XErrMC)
* Final print-outs of demo
      DO i = 1,2
         mout = 6
         IF(i .EQ. 2) mout = Nout
         WRITE(mout,'(A60)') '                              '
         WRITE(mout,'(A60)') '============ winhac_test ============'
         WRITE(mout,'(1X,F17.8, 4H  +-, F11.8, 1X, A30)') 
     &              XsecMC,XErrMC, 'XsecTot Best from WINHAC'
         WRITE(mout,'(A60)') '========== End winhac_test =========='
         WRITE(mout,'(A60)') '                              '
      ENDDO
*
* Print cross-section in the <testi.dat> and Close the file
      CALL PRINT_TEST(1)
      CALL PRINT_TEST(0)
      END

      SUBROUTINE Demo_Test(mode)
*     **************************
*/////////////////////////////////////////////////////////////////////
*// Some test histograms ...                                        //
*/////////////////////////////////////////////////////////////////////
      IMPLICIT DOUBLE PRECISION (A-H,O-Z) 
      DIMENSION QQ(4),qle(4),qnu(4),pqu(4),paq(4)
c      DIMENSION pqu(4),paq(4)
*
      IF (mode.EQ.-1) THEN
*---------------------------------------------------------------------- 
*/ Book histograms
        Nbin = 50
        yw1  = -6d0
        yw2  =  6d0
        cth1 = -1d0
        cth2 =  1d0
        eta1 = -6d0
        eta2 =  6d0
        pt1  =  0d0
        pt2  =  50d0
        CALL GBOOK1(1001,'W: rapidity y              $',Nbin,yw1,yw2)
        CALL Gbook1(1002,'lepton: cos(theta)         $',Nbin,cth1,cth2)
        CALL Gbook1(1003,'lepton: pseudorapidity eta $',Nbin,eta1,eta2)
        CALL Gbook1(1004,'lepton: p_T                $',Nbin,pt1,pt2)
        Ngmax = 10
        CALL GBOOK1(1005,'Photon multiplicity $',Ngmax,0d0,Ngmax*1d0)
*
      ELSEIF (mode.EQ.0) THEN
*---------------------------------------------------------------------- 
*/ Get W and lepton 4-momenta and photon number from event record
         CALL WH_GetLabMomW(QQ)
         CALL WH_GetLabMomLep(qle,qnu)
         CALL WH_GetPhoNum(Nphot)
!!!
c         CALL WH_GetLabMomQua(pqu,paq)

*/ Calculate observables for events with non-zero weight
         CALL WH_GetWtCrud(Wtxx,WtYFS)
         WtCrud = Wtxx*WtYFS
         IF (WtCrud .NE. 0d0) THEN
            EnW = QQ(4)
            pzW = QQ(3)
            yw     = 0.5*LOG( (EnW + pzW)/(EnW - pzW) )
            costhe = qle(3)/SQRT( qle(1)**2 + qle(2)**2 + qle(3)**2 )  
!!!
c            CALL BOSTDQ(1,QQ,qle,qle) 
c            CALL BOSTDQ(1,QQ,pqu,pqu) 
c            costhe = ( pqu(1)*qle(1) + pqu(2)*qle(2) + pqu(3)*qle(3) )/
c     &               SQRT( qle(1)**2 + qle(2)**2 + qle(3)**2 )/ 
c     &               SQRT( pqu(1)**2 + pqu(2)**2 + pqu(3)**2 ) 
c

            thel   = DACOS(costhe)
            etal   = -LOG( TAN(thel/2) )
            pTl    = SQRT( qle(1)**2 + qle(2)**2 )
        ELSE
            yw     = -50
            costhe = -2
            etal   = -50
            pTl    = -10
        ENDIF
        CALL WH_GetWtMain(WtMain)
        wt = WtMain
*/ Fill histograms
        CALL gf1(1001,yw    ,wt)
        CALL gf1(1002,costhe,wt)
        CALL gf1(1003,etal  ,wt)
        CALL gf1(1004,pTl   ,wt)
        CALL gf1(1005,Nphot*1.1d0,wt)
*
      ELSEIF (mode.EQ.1) THEN 
*---------------------------------------------------------------------- 
*/ Print histograms
         DO i = 1,5
            CALL gprint(1000+i)
         ENDDO
      ELSE
         WRITE(6,*)' >> Demo_Test: Wrong mode = ',mode
         STOP
      ENDIF
      END
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
      INTEGER I
C
      IF (I .LT. 0)  THEN
         OPEN(unit = 10, file = 'testi.dat', status = 'unknown')
      ELSE IF (I .EQ. 0)  THEN
         CLOSE(10)
      ELSE
* Get final total MC x-section to be printed below
         CALL WH_GetXSecMC(XSecMC,XErrMC)
c...     Printing the total accepted cross section and its uncerainty to testi.dat:
         WRITE(10,100) I, XSecMC, XErrMC
      END IF
C
100   FORMAT('winhac_test ',I3,2(1PE15.6))
      RETURN
      END
