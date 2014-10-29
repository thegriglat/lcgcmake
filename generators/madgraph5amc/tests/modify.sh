cd ${1}
sed "s%# lhapdf = lhapdf-config% lhapdf = ${2}%" < me5_configuration.txt > me5_configuration.txtNEW
mv me5_configuration.txtNEW me5_configuration.txt
sed '/= pdlabel/s,^.*$, lhapdf = pdlabel,' < run_card.dat > run_card.datNEW
mv run_card.datNEW run_card.dat
sed "/= lhaid/s,^.*$, 10800 = lhaid," < run_card.dat > run_card.datNEW
mv run_card.datNEW run_card.dat
