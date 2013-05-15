C #@# MCFM 5.8 test for p-p at E=14TeV 
C #@# process:    f(p1)+f(p2) --> W^+(-->nu(p3)+e^+(p4))  (#1 in process.DAT)
C #@# reference value - 21094.708 fb, 2 iterations, 10 calls
C #@# 1: cross-section

c      program check


c*********************************************************************************
cc    very preliminary test form mcfm:   
cc    process 1  '  f(p1)+f(p2) --> W^+(-->nu(p3)+e^+(p4))'     LO
cc    It would be better to use single top tqb (t-channel)
cc    very few calls and iterations have been used: 2 iterations and 10 calls
cc    Normally these numbers (one can change them in input.DAT) should be 3-5 and 10K-100K

cc    Test scheme: first we copy binary from repository (mcfm or mcfm_a) and execute it
cc    Output (cross-section with relative error) are written in mcfm_val.out and mcfm_err.out
cc    Then we use do_standard_sequence to read these files and pass value and errors to Genser 
c*********************************************************************************

      real val1,val2,err1,err2

c        GENSER test output

      call testfileopen  

      open(UNIT=33,FILE='mcfm_val.out')
      read(33,*) val1
      read(33,*) val2
      close(33)

      open(UNIT=33,FILE='mcfm_err.out')
      read(33,*) err1
      read(33,*) err2
      close(33)
              
      call testfile('mcfm_test0', 1, val1, err1*val1)
      call testfileclose
   
      end
