C #@# HEJ 1.2 test for p-p at E = 3.5 + 3.5 TeV
C #@# process: dijet production 
C #@# reference value - Hej 1.2, 2 000 000 events
C #@# 1: cross-section


      real val1,val2,err1,err2

c        GENSER test output

      call testfileopen  

      open(UNIT=33,FILE='hej_val.out')
      read(33,*) val1, err1
      read(33,*) val2, err2
      close(33)

      print*,'Cross section in mub and its error:  ',val1, err1
              
      call testfile('hej_test0', 1, val1, err1)
      call testfileclose
   
      end
