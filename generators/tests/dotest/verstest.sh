#!/bin/bash

# note: "@mode" notation means to run tests with specific mode
platforms="\
x86_64-mac106-gcc42-opt \
x86_64-slc5-gcc43-opt@mcgtest \
x86_64-slc6-gcc46-opt \
x86_64-slc5-gcc46-opt \
x86_64-slc5-gcc43-opt \
i686-slc5-gcc43-opt \
"


# return host name by platform name
machine () {
  local platform="$1"
  
  case "$platform" in
    "x86_64-mac106-gcc42-opt" ) echo "macphsft02.cern.ch" ;;
    "x86_64-slc6-gcc46-opt" )   echo "lxplus6.cern.ch" ;;
    "x86_64-slc5-gcc46-opt" )   echo "lx64slc5.cern.ch" ;;
    "x86_64-slc5-gcc43-opt" )   echo "lx64slc5.cern.ch" ;;
    "i686-slc5-gcc43-opt" )     echo "pcrfcms8.cern.ch" ;;
    * )
      echo "ERROR: Unknown platform: $platform" >&2
      exit 2
      ;;
  esac
}

# comparing results from test.dat.generator.* with the given reference file
compare () {
  local gen=$1   # generator name, e.g., pythia6, herwig
  local ref="$2" # reference data file
  
  if [[ "${gen}" = "" ]] ; then
    echo "ERROR: (compare) generator name is not specified.">&2
    exit 4
  fi
  
  if [ "X$(ls test.dat.${gen}.*)" = "X" ] ; then
    echo "ERROR: (compare) No test.dat.${gen}.* found.">&2
    exit 4
  fi
  
  if [[ "${ref}" = "" ]] ; then
    echo "ERROR: (compare) reference file is not specified.">&2
    exit 4
  fi
  
  if [ ! -s ${ref} ] ; then
    echo "ERROR: (compare) reference file ${ref} is absent or empty">&2
    exit 4
  fi
  
  grep -E "^${gen}_" ${ref} > .${gen}.ref.dat
  grepstr=$(sed 's/^[ ]*\([^ ][^ ]*\)[ ][ ]*\([0-9][0-9]*\) .*$/\^\1\[ \]+\2 /;' < .${gen}.ref.dat | tr '\n' '|' | sed 's/|$//')
#  grep -v -E "${grepstr}|^[ ]*$" test.dat.${gen}.*
  cat test.dat.${gen}.* | sed 's/$/ /;' | grep -v -E "${grepstr}|^[ ]*$" \
  | sed 's/^[^:]*:[ ]*\([^ ][^ ]*\)[ ][ ]*\([0-9][0-9]*\) .*$/\1 \2/;
         s/^[^:]*:[ ]*\([^ ][^ ]*\)[ ][ ]*\([0-9][0-9]*\)$/\1 \2/;
         s/^[ ]*\([^ ][^ ]*\)[ ][ ]*\([0-9][0-9]*\) .*$/\1 \2/;
         s/^[ ]*\([^ ][^ ]*\)[ ][ ]*\([0-9][0-9]*\)$/\1 \2/;
        ' \
        | sort | uniq > .${gen}.missing_from_ref.dat

  versions=$(ls -1 test.dat.$gen.* | \
             sed "s/^test.dat.$gen\.//;s/\.[^\.][^\.]*$//;" | \
       sort -r  | uniq | tr '\n' ' '
      )
  
  echo "Comparing test results for $gen with ones from $ref" >&2
  echo "Compiling ./chi.exe ... " >&2
  cc -o chi.exe chi.c -lm >&2
  if [[ "$?" != "0" ]] ; then
    echo "ERROR: failed to compile 'chi.cc'." >&2
    exit 1
  fi
  
  echo "Processing tests results ... " >&2
  for platform in ${platforms} ; do
    echo "@platform@: ${platform}"
    echo ""

    cat .${gen}.ref.dat | \
    while read test_name test_num ref_y ref_dy tl ; do
      echo "@ref@: $test_name : $test_num : $ref_y : $ref_dy"
      for version in ${versions} ; do
        echo -n "@version@: $version :"
        dat_file="test.dat.${gen}.${version}.${platform}"
        if [ ! -s $dat_file ] ; then
          echo " - -  $ref_y $ref_dy -  [not_built]"
        else
          str=$(cat $dat_file \
               | sed 's,[^\.a-z0-9A-Z_!+ \-],,g;' | sed 's,!.*$,,' \
               | grep -E \
                "^[ ]*${test_name}[ ]+${test_num}$|^[ ]*${test_name}[ ]+${test_num} "
               )
          if [ "x$str" = "x" ] ; then
            echo " - -  $ref_y $ref_dy -  [missing]"
          else
            #echo str:${str}:
            echo ${str} | \
            {
              read dum dum y dy tl
              if [ "x$y" = "x" ] || [ "x$dy" = "x" ]; then
                echo " - - $ref_y $ref_dy - [failed]"
              else
                #echo '>>>' $y $dy $ref_y $ref_dy '<<<' #| ./chi.exe
                echo $y $dy $ref_y $ref_dy | ./chi.exe
              fi
            }
          fi
        fi
      done

      echo "@end_test@"
      echo ""
    done

    # now finding tests missing from ${ref}:
    grep -v "^[ ]*$" .${gen}.missing_from_ref.dat | \
    while read test_name test_num tl ; do
      echo "@ref@: $test_name : $test_num : - : -"
      for version in ${versions} ; do
        echo -n @version@: $version :
        str=$(grep -E \
              "^[ ]*${test_name}[ ]+${test_num}$|^[ ]*${test_name}[ ]+${test_num} " \
              test.dat.${gen}.${version}.${platform}
             )
        echo ${str} | \
        {
          read dum dum y dy tl
          if [ "x$y" = "x" ] || [ "x$dy" = "x" ] ; then
            y="-" ; dy="-"
          fi
          echo $y $dy - - - "[missing_from_ref._file]"
        }
      done

      echo "@end_test@"
      echo ""
    done

    echo "@end_platform@"
    echo ""
  done

  rm -f ./chi.exe
}


submit_tests () {
  echo "Submitting tests for platforms: $platforms"
  echo ""
  
  local workdir="$(pwd)"
  
  for platform in ${platforms} ; do
      local test_platform=$(echo $platform | cut -d @ -f 1)
      local test_mode=$(echo $platform | cut -s -d @ -f 2)
      test_mode=${test_mode:-$mode}
      
      # Running platform-specific tests on other hosts:
      host=$(machine $test_platform)
      
      # mac platform require explicit AFS authentication
      local prelude=""
      if [[ "$host" == "macphsft02.cern.ch" ]] ; then
        prelude="kinit && aklog &&"
      elif [[ "$test_platform" == "x86_64-slc5-gcc46-opt" ]] ; then
        prelude="source /afs/cern.ch/sw/lcg/contrib/gcc/4.6/x86_64-slc5-gcc46-opt/setup.sh &&"
      fi
      
      argstring="$prelude \
                 source /afs/.cern.ch/sw/lcg/external/MCGenerators/.work/GBUILD/noarch/TOOLS/genser.rc && \
                 cd ${workdir} && \
                 ./verstest.sh \
                    --mode=${test_mode} \
                    --generator=${generator} \
                    --versions=${versions} \
                    --platform=${platform}"
      echo "=> Connecting to $host (platform $test_platform, mode $test_mode)"
      ssh -t ${host} bash -c "\"${argstring}\"" || exit 1
      echo ""
  done
}


run_tests () {
  for version in $(echo $versions | tr ',' ' ') ; do
    local tag=${generator}.${version}.${platform}
    
    echo > test.dat
    echo "[$(date)] Running tests for ${generator}-${version}-${platform} (see details in test-${tag}.log) ... "
    nice ./dotest --mode=${mode} --vers_${generator}=${version} --no_compare >& ./test-${tag}.log
    
    if [[ "$?" != "0" ]] ; then
      echo "ERROR: tests failed"
      exit 1
    fi
    
    mv -f test.dat test.dat.${tag}
  done
}


compare_tests () {
  compare $generator $ref_file > $generator.comparison.txt
  
  echo "See comparison results in file:"
  echo "  ./${generator}.comparison.txt"
  echo ""
  echo "To prepare html page with comparison results do:"
  echo "  $ ./comp2html.sh ${generator}.comparison.txt > ${generator}-version.html"
  echo ""
  echo "If results are fine copy the page to:"
  echo "  $WEB/validation/"
  echo ""
  echo "Follow publication steps from testing instructions to make results visible on GENSER website."
  echo ""
}



# print usage info if no parameters given:
if [[ "$#" = "0" ]] ; then
  echo "Usage: $0"
  echo "           --generator=name"
  echo "           --versions=ver1[,ver2[,...]]"
  echo "         [ --mode=mcg|mcgrep|g3shadow ]"
  echo "         [ --platform={LCG PLATFORM} ]"
  echo "         [ --ref_file=reference_file ]"
  echo "         [ --compare_only ]"
  exit 0
fi

# default parameters:
generator=""
versions=""
mode="lcgcmt64"
platform=""
ref_file="./reference.dat"
compare_only="0"

# parse parameters:
for arg in $* ; do
  option=${arg/=*/}
  value=${arg/*=/}
  case "${option}" in
    "--generator" ) generator=${value} ;;
    "--versions"  ) versions=${value} ;;
    "--mode"      ) mode=${value} ;;
    "--platform"  ) platform=${value} ;;
    "--ref_file"  ) ref_file=${value} ;;
    "--compare_only" ) compare_only=1 ;;
    * )
      echo "ERROR: unknown option: ${option}" >&2
      exit 1
      ;;
  esac
done

# check parameters:
if [[ "$generator" = "" ]] ; then
  echo "ERROR: generator not defined (parameter '--generator=name' is missing)" >&2
  exit 1
fi

if [[ "$versions" = "" ]] ; then
  echo "ERROR: versions not defined (parameter '--versions=ver1,ver2,...' is missing)" >&2
  exit 1
fi

if [[ ! -s ${ref_file} ]] ; then
  echo "ERROR: Can't find reference file at ${ref_file}"
  echo "       Check its location and re-run ./verstest.sh ... --ref_file=/path/to/reference_file"
  exit 1
fi

if ! fs whereis >& /dev/null ; then
  echo "ERROR: current directory is not the AFS folder"
  exit 1
fi

# === main ===

if [[ "$compare_only" = "1" ]] ; then
  compare_tests
  exit
fi

if [[ "$platform" = "" ]] ; then
  submit_tests
  compare_tests
  exit
fi

run_tests
