      program lhapdf_test
*
*#@# 1-20: This program writes a predefined set of tests
*#@# to the file 'testi.dat' (see test.dat to which the testi.dat 
*#@# content is appended).
*#@# Each line in the file contains:
*#@# lhapdf test_number value error ! comment_string
*#@# Testted values are parton densities for UP quark, i.e. f(2),
*#@# at x = 0.1,0.5,0.9, Q = 1.5,10,100 GeV and given set
*#@# of PDF files.
*
* Created 8.12.2005 GENSER team, I.Kachaev
*
      implicit none
      integer lun
*
      lun = 99
      open(lun,file='testi.dat',form='formatted',status='new')
      call TestPDFset(lun,'cteq6.LHpdf')
cc      call TestPDFset(lun,'cteq6mE.LHgrid')
cc      call TestPDFset(lun,'MRST2001E.LHgrid')
      call TestPDFset(lun,'MRST2001nnlo.LHgrid')
      call TestPDFset(lun,'MRST98lo.LHgrid')
cc      call TestPDFset(lun,'MRST98nlo.LHgrid')
cc      call TestPDFset(lun,'a02m_lo.LHgrid')
      call TestPDFset(lun,'a02m_nnlo.LHgrid')
cc      call TestPDFset(lun,'H12000msE.LHgrid')
      call TestPDFset(lun,'H12000loE.LHgrid')
      close(lun)
      end
    
      subroutine TestPDFset(lun,name)
*
* Print results about given PDFset.
*
      implicit none
      integer lun
      character name*(*)
      integer N, i, j
      integer Nsetmax, Lup
      parameter(Nsetmax = 1024, Lup = 2)
      real*8 upv(9,0:Nsetmax), umin(9), umax(9)
      real*8 f(-6:6), x1, x2, x3, Q1, Q2, Q3, error
      integer itest
      data itest /0/
*
      x1 = 0.1D0
      x2 = 0.5D0
      x3 = 0.8D0
      Q1 = 1.5D0
      Q2 = 10.D0
      Q3 = 100.D0
C     write(*,*) 'Pdf Set Name is ', name
      call InitPDFsetByName(name)
      call numberPDF(N)
      if (N .gt. Nsetmax) Stop 'Too many set members'
      if (N .le. 1) then
         write(*,*)
         write(*,*) 'PDF set ',name,' has 1 member only'
         write(*,*) 'It is not apropriate for tests'
         write(*,*)
         return
      endif
      write(*,*)
      write(*,*) 'Fit ',name,' Number of PDF sets ',N
      do i=0,N
         call InitPDF(i)
*
         call evolvePDF(x1,Q1,f)
         upv(1,i) = f(Lup)
         call evolvePDF(x1,Q2,f)
         upv(2,i) = f(Lup)
         call evolvePDF(x1,Q3,f)
         upv(3,i) = f(Lup)
*
         call evolvePDF(x2,Q1,f)
         upv(4,i) = f(Lup)
         call evolvePDF(x2,Q2,f)
         upv(5,i) = f(Lup)
         call evolvePDF(x2,Q3,f)
         upv(6,i) = f(Lup)
*
         call evolvePDF(x3,Q1,f)
         upv(7,i) = f(Lup)
         call evolvePDF(x3,Q2,f)
         upv(8,i) = f(Lup)
         call evolvePDF(x3,Q3,f)
         upv(9,i) = f(Lup)
      enddo
*
C     do i = 0,N
C        write(*,*) 'PDF set ',i
C        write(*,*)
C        write(*,*) '   x  Q=1 GeV   Q=10 GeV  Q=100 GeV'
C        write(*,720) x1,upv(1,i),upv(2,i),upv(3,i)
C        write(*,720) x2,upv(4,i),upv(5,i),upv(6,i)
C        write(*,720) x3,upv(7,i),upv(8,i),upv(9,i)
C     enddo
*
      do j = 1,9
         umin(j) = upv(j,0)
         umax(j) = upv(j,0)
         do i = 1,N
            umin(j) = min(umin(j),upv(j,i))
            umax(j) = max(umax(j),upv(j,i))
         enddo
      enddo
*
      write(*,725)
      write(*,730) x1,
     &     umin(1),upv(1,0),umax(1),
     &     umin(2),upv(2,0),umax(2),
     &     umin(3),upv(3,0),umax(3)
      write(*,730) x2,
     &     umin(4),upv(4,0),umax(4),
     &     umin(5),upv(5,0),umax(5),
     &     umin(6),upv(6,0),umax(6)
      write(*,730) x3,
     &     umin(7),upv(7,0),umax(7),
     &     umin(8),upv(8,0),umax(8),
     &     umin(9),upv(9,0),umax(9)
      write(*,*)
*
      itest = itest + 1
      error = (umax(1)-umin(1))/2.D0
      write(lun,740) itest,upv(1,0),error,x1,Q1,name
cc      itest = itest + 1
cc      error = (umax(2)-umin(2))/2.D0
cc      write(lun,740) itest,upv(2,0),error,x1,Q2,name
      itest = itest + 1
      error = (umax(3)-umin(3))/2.D0
      write(lun,740) itest,upv(3,0),error,x1,Q3,name
*
      itest = itest + 1
      error = (umax(6)-umin(6))/2.D0
      write(lun,740) itest,upv(6,0),error,x2,Q3,name
      itest = itest + 1
      error = (umax(9)-umin(9))/2.D0
      write(lun,740) itest,upv(9,0),error,x3,Q3,name
*
C720  format(F5.1,3F10.6)
 725  format(/20X,'Q=1.5 GeV',20X,'Q=10 GeV',20X,'Q=100 GeV')
 730  format(' x =',F5.2,3(' [',F8.6,2F9.6,']'))
 740  format('lhapdf_test1',I3,2F10.6,' ! x =',F5.2,' Q =',F6.1,1X,A)
      end
