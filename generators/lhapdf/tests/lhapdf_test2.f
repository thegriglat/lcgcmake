      program lhapdf_glue
*
*#@# 21-40: This program writes a predefined set of tests to the file 'testi.dat' 
*#@# (appended to test.dat, see the latter).      
*#@# Each line in the file contains:
*#@# lhapdf_test2  test_number value  error ! comment_string
*#@# Tested values are parton densities for UP quark, i.e. f(2),
*#@# at x = 0.1,0.5,0.9, Q = 1.5,10,100 GeV and given set
*#@# of PDF files.
*#@# This program tests the LHAGLUE interface.
*
* Created 15.12.2005 GENSER team, I.Kachaev
*
      implicit none
      integer lun
*
      lun = 99
      open(lun,file='testi.dat',form='formatted',status='new')
      call TestPDFset(lun,10000,10040,'cteq6.LHpdf')
      call TestPDFset(lun,20070,20074,'MRST2001nnlo.LHgrid')
      call TestPDFset(lun,29040,29045,'MRST98lo.LHgrid')
      call TestPDFset(lun,40550,40567,'a02m_nnlo.LHgrid')
      call TestPDFset(lun,70250,70270,'H12000loE.LHgrid')
cc      call TestPDFset(lun,40100,40110,'Alekhin_100.LHpdf')
cc      call TestPDFset(lun,10050,10090,'cteq6.LHpdf')
      close(lun)
      end
    
      subroutine TestPDFset(lun,iset1,iset2,name)
*
* Print results about given PDFset. Parameters:
* lun - input, Fortran i/o unit to write results
* iset1, iset2 - input, PDF set numbers, iset1 is the 'best fit' set
* name - input, PDF set file name for printout only
*
      implicit none
      integer lun, iset1, iset2
      character name*(*)
      integer N, i, j
      integer Nsetmax
      parameter (Nsetmax = 1024)
      real*8 upxx(9,0:Nsetmax), umin(9), umax(9)
      real*8 x1, x2, x3, Q1, Q2, Q3, error
      real*8 upv,dnv,usea,dsea,str,chm,bot,top,glu
      integer itest
      data itest /20/ ! This is the second test program for lhapdf
      character*20 parm(20)
      real*8 value(20)
      data parm /20*' '/, value /20*0d0/
*
      character*20 lhaparm(20)
      double precision lhavalue(20)
      character*20 commoninitflag
      common/lhacontrol/lhaparm,lhavalue,commoninitflag
      save/lhacontrol/
C      include 'commonlhacontrol.inc'
       
*
C...Interface to LHAPDFLIB.
      character*512 lhaname
      integer lhaset, lhamemb
      common/lhapdf/lhaname, lhaset, lhamemb
      save /lhapdf/
C      include 'commonlhapdf.inc'
      integer ip1, ip2, lnblnk
*
      x1 = 0.1D0
      x2 = 0.5D0
      x3 = 0.8D0
      Q1 = 1.5D0
      Q2 = 10.D0
      Q3 = 100.D0
      write(*,*)
      write(*,*) 'Fit ',name,' Set numbers ',iset1,iset2
      N = iset2-iset1
      if (N .gt. Nsetmax) Stop 'Too many set numbers'
      do i=0,N
         parm(1) = 'DEFAULT'
         value(1)= i+iset1
         LHAPARM(19)= ' '
         if (i .gt. 1) LHAPARM(19)= 'SILENT'
         write(*,*)
         write(*,*) 'PDF set ',value(1)
         call PDFSET(parm,value)
C         write (*,*) 'DBG: PDFSET returned'
*
         call STRUCTM(x1,Q1,upv,dnv,usea,dsea,str,chm,bot,top,glu)
         upxx(1,i) = upv+usea
         call STRUCTM(x1,Q2,upv,dnv,usea,dsea,str,chm,bot,top,glu)
         upxx(2,i) = upv+usea
         call STRUCTM(x1,Q3,upv,dnv,usea,dsea,str,chm,bot,top,glu)
         upxx(3,i) = upv+usea
*
         call STRUCTM(x2,Q1,upv,dnv,usea,dsea,str,chm,bot,top,glu)
         upxx(4,i) = upv+usea
         call STRUCTM(x2,Q2,upv,dnv,usea,dsea,str,chm,bot,top,glu)
         upxx(5,i) = upv+usea
         call STRUCTM(x2,Q3,upv,dnv,usea,dsea,str,chm,bot,top,glu)
         upxx(6,i) = upv+usea
*
         call STRUCTM(x3,Q1,upv,dnv,usea,dsea,str,chm,bot,top,glu)
         upxx(7,i) = upv+usea
         call STRUCTM(x3,Q2,upv,dnv,usea,dsea,str,chm,bot,top,glu)
         upxx(8,i) = upv+usea
         call STRUCTM(x3,Q3,upv,dnv,usea,dsea,str,chm,bot,top,glu)
         upxx(9,i) = upv+usea
      enddo
*
C     do i = 0,N
C        write(*,*) 'PDF set ',i
C        write(*,*)
C        write(*,*) '   x  Q=1 GeV   Q=10 GeV  Q=100 GeV'
C        write(*,720) x1,upxx(1,i),upxx(2,i),upxx(3,i)
C        write(*,720) x2,upxx(4,i),upxx(5,i),upxx(6,i)
C        write(*,720) x3,upxx(7,i),upxx(8,i),upxx(9,i)
C     enddo
*
      do j = 1,9
         umin(j) = upxx(j,0)
         umax(j) = upxx(j,0)
         do i = 1,N
            umin(j) = min(umin(j),upxx(j,i))
            umax(j) = max(umax(j),upxx(j,i))
         enddo
      enddo
*
C      write (*,*) 'DBG: LHANAME:',LHANAME,':'

      ip2 = lnblnk(LHANAME)
      do i = ip2, 1, -1
         if (LHANAME(i:i) .eq. '/') goto 90
      enddo
      i = 0
 90   continue
      ip1 = i + 1
      if (name .ne. LHANAME(ip1:ip2)) then
         write(*,745) iset1, iset2, name, LHANAME(ip1:ip2)
      endif
C>
C      write(*,*) 'Real PDF set name ',LHANAME(ip1:ip2)
C<
*
      write(*,725)
      write(*,730) x1,
     &     umin(1),upxx(1,0),umax(1),
     &     umin(2),upxx(2,0),umax(2),
     &     umin(3),upxx(3,0),umax(3)
      write(*,730) x2,
     &     umin(4),upxx(4,0),umax(4),
     &     umin(5),upxx(5,0),umax(5),
     &     umin(6),upxx(6,0),umax(6)
      write(*,730) x3,
     &     umin(7),upxx(7,0),umax(7),
     &     umin(8),upxx(8,0),umax(8),
     &     umin(9),upxx(9,0),umax(9)
      write(*,*)
*
      itest = itest + 1
      error = (umax(1)-umin(1))/2.D0
      write(lun,740) itest,upxx(1,0),error,x1,Q1,iset1,LHANAME(ip1:ip2)
cc      itest = itest + 1
cc      error = (umax(2)-umin(2))/2.D0
cc      write(lun,740) itest,upxx(2,0),error,x1,Q2,iset1,LHANAME(ip1:ip2)
      itest = itest + 1
      error = (umax(3)-umin(3))/2.D0
      write(lun,740) itest,upxx(3,0),error,x1,Q3,iset1,LHANAME(ip1:ip2)
*
      itest = itest + 1
      error = (umax(6)-umin(6))/2.D0
      write(lun,740) itest,upxx(6,0),error,x2,Q3,iset1,LHANAME(ip1:ip2)
      itest = itest + 1
      error = (umax(9)-umin(9))/2.D0
      write(lun,740) itest,upxx(9,0),error,x3,Q3,iset1,LHANAME(ip1:ip2)
*
C720  format(F5.1,3F10.6)
 725  format(/20X,'Q=1.5 GeV',20X,'Q=10 GeV',20X,'Q=100 GeV')
 730  format(' x =',F5.2,3(' [',F8.6,2F9.6,']'))
 740  format('lhapdf_test2',I3,2F10.6,' ! x =',F5.2,' Q =',F6.1,' Set',
     &  I6,1X,A,' lhaglue')
 745  format(/' WARNING: Set number',2I6,' name declared ',A,' real ',A)
      end
