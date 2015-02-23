find . -depth -type d -name 'CVS' -o -name '.svn' | xargs rm -rf

rm -f `find -L . -type f -name "pythia.f"`
rm -f `find -L . -type f -name "herwig.f"`
rm -f `find -L . -type f -name "HERWIG65.INC"`
rm -f `find . -type f -name "herwig6520.f"`
rm -f `find . -type f -name "pythia-6.4.23.f"`
rm -f `find . -type f -name "herwig6520.inc"`
rm -f herwig6510.f
rm -f pythia-6.4.21.f
rm -f pythia-6.4.25.f

