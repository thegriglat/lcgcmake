#!/bin/bash

open_html() {
cat << EOT
<html>
<head>
  <title>Test results</title>
  <style>
    tr#good {}
    td#YdY {display: none}
    .switchlink {color: #0055CC; cursor: pointer; margin: 4px; border-bottom: 1px dashed #0055CC; }
  </style>
  
  <script language="javascript">
<!--
function turn_good()
{
  var rows = document.getElementsByTagName('tr');
  for (var i = 0; i < rows.length; i++)
  {
    var row = rows[i];

    if (row.id == "good") {
      if (row.style.display != "none")
        row.style.display = "none";
      else
        row.style.display = "table-row";
    }
  }
}

function turn_YdY()
{
  var cols = document.getElementsByTagName('td');
  for (var i = 0; i < cols.length; i++)
  {
    var col = cols[i];

    if (col.id == "YdY") {
      if (col.style.display != "table-cell")
        col.style.display = "table-cell";
      else
        col.style.display = "none";
    }
  }
}

-->
  </script>
</head>
<body>

EOT
}

write_parameters() {
  echo "<h1>Tests results</h1>"
  echo "<p>"
  echo "  Generator: $generators <br>"
  echo "  Versions: $versions <br>"
  # FIXME: -r is GNU only option:
  #echo "  Test date: $(LANG=C LC_ALL=C date -r $TXTFILE) <br>"
  echo "  Test date: $(LANG=C LC_ALL=C date) <br>"
  echo "  Revision: $(svnversion) (<a href=\"https://svnweb.cern.ch/trac/GENSER/log/validation/trunk/tests\">log</a>) <br>"
  echo "  Comments:  <br>"
  echo "</p>"
  echo "<hr>"
}

write_notation() {
cat << EOT
<h4>Notation:</h4>
<table cellpadding=3>
<tr>
  <td align=left> Y , &nbsp; &nbsp; &nbsp; dY </td>
  <td> -- value of an observable and its stat. error  </td>
</tr>
<tr>
  <td align=left> Y<sub>ref</sub> ,  dY<sub>ref</ref> </td> 
  <td> -- reference value of an observable and its stat. error  </td>
</tr>
<tr>
  <td align=left> Pull  </td> 
  <td> -- ( Y - Y<sub>ref</sub> ) / ( dY<sup> 2</sup> + dY<sup> 2</sup><sub>ref</sub> )<sup> 1/2</sup> </td>
</tr>
<tr>
  <td bgcolor="#00ff00" align=center>ok</td> 
  <td> -- tests are succesfully compiled and executed with <i>pull</i> &lt; 3 for all versions </td>
</tr>
<tr>
    <td bgcolor="#4aa1ff" align=center> badstat</td>
    <td> -- as above, but statistics is insufficient: Y<sub>ref</sub> &lt; 5dY<sub>ref</sub> or Y &lt; 4dY </td>
</tr>
<tr>
  <td bgcolor="#ffaa00" align=center> deviation</td> 
  <td> -- at least one <i>pull</i> &gt; 3 </td>
</tr>
<tr>
  <td bgcolor="#ff0000" align=center> failed </td>
  <td> -- test crashed at least for one version</td>
</tr>
<tr>
  <td bgcolor="#ff0000" align=center> errors </td>
  <td> -- test failed to compile at least for one version </td>
</tr>
</table>

<hr>
EOT
}

write_table_controls() {
cat << EOT
<p>
  <span class="switchlink" onClick="turn_good()">Show/Hide rows with Status = [OK]</span> | 
  <span class="switchlink" onClick="turn_YdY()">Show/Hide Y/dY columns</span><br>
  <font size="-1">Be patient, this operations can take up to several tens of seconds</font>
</p>

<hr>

EOT
}

start_platform() {
  echo "<h2>" $1 "</h2>"
  echo "<table border=1>"
}

write_versions() {
  echo "<tr>"
  echo "  <td align=\"right\"> Version: </td>"
  echo "  <td></td>"
  for version in $* ; do
    echo "  <td align=\"center\"> $version </td>"
    echo "  <td id=\"YdY\"></td>"
    echo "  <td id=\"YdY\"></td>"
  done
  echo "  <td align=\"center\" colspan=\"2\"> Reference </td>"
  echo "  <td></td>"
  echo "</tr>"
  
  echo "<tr>"
  echo "  <td align=\"center\"> Test </td> <td></td>"
  for version in $* ; do
    echo "  <td align=\"center\" id=\"YdY\"> Y </td>"
    echo "  <td align=\"center\" id=\"YdY\"> dY </td>"
    echo "  <td align=\"center\"> pull </td>"
  done
  echo "  <td align=\"center\"> Y<sub>ref</sub> </td>"
  echo "  <td align=\"center\"> dY<sub>ref</sub> </td>"
  echo "  <td align=\"center\"> Status </td>"
  echo "</tr>"
}

write_test_name() {
  local name=$1
  local num=$2
  local rowStat=$3
  
  local rowId="good"
  if [[ "$rowStat" != "[OK]" ]] ; then
    rowId="bad"
  fi
  
  echo "<tr id=\"$rowId\">"
  echo "  <td align=\"left\"> <a href=\"#${name}\"> $name </a> </td>"
  echo "  <td align=\"right\"> $num </td>"
}

write_y_dy() {
  local y=$1
  local dy=$2
  local dev=$3
  local stat=$4
  
  if [[ "$y" = "-" || "$dy" = "-" ]] ; then
    align="center"
    ycolor="#ffdddd"
  else
    align="right"
    ycolor="#ffffff"
  fi
  
  dev_align="right"
  if   [ "x$stat" = "x" ] || [ "x${stat/OK/}" != "x${stat}" ] ; then
    dev_color="#55ff55"
  elif [ "x${stat/BADSTAT/}" != "x${stat}"     ] ; then
    dev_color="#4aa1ff"
  elif [ "x${stat/DEVIATION/}" != "x${stat}"     ] ; then
    dev_color="#ffaa00"
  elif [ "x${stat/built/}" != "x${stat}"     ] ; then
    dev_color="#ff0000"
    y=""
    dy=""
    dev="not_built"
    ycolor="#ff0000"
  else
    dev_color="${ycolor}"
  fi
  
  if   [ "x$dev" = "x-" ] ; then
    dev_color="#ffdddd"
    dev_align="center"
  fi
  
  echo "  <td align=${align} bgcolor=\"${ycolor}\" id=\"YdY\"> $y </td>"
  echo "  <td align=${align} bgcolor=\"${ycolor}\" id=\"YdY\"> $dy </td>"
  echo "  <td align=${dev_align} bgcolor=\"${dev_color}\"> $dev </td>"
}

close_test() {
  local y=$1
  local dy=$2
  local stat=$3
  
  if   [ "x$stat" = "x" ] || [ "x$stat" = "x[OK]" ] ; then
    stat="<td align=center bgcolor=\"#00FF00\"> ok </td>"  
  elif [ "x${stat/missing_from/}" != "x${stat}"  ] ; then
    stat="<td align=center bgcolor=\"#ff9999\"> missing from reference file </td>"
  elif [ "x${stat/missing/}" != "x${stat}"     ] ; then
    stat="<td align=center bgcolor=\"#FF0000\"> errors </td>"
  elif [ "x${stat/failed/}" != "x${stat}"     ] ; then
    stat="<td align=center bgcolor=\"#FF0000\"> failed </td>"
  elif [ "x${stat/DEVIATION/}" != "x${stat}"     ] ; then
    stat="<td align=center bgcolor=\"#ffaa00\"> deviation </td>"
  elif [ "x${stat/BADSTAT/}" != "x${stat}"     ] ; then
    stat="<td align=center bgcolor=\"#4aa1ff\"> badstat </td>"
  elif [ "x${stat/not_built/}" != "x${stat}"     ] ; then
    stat="<td align=center bgcolor=\"#FF0000\"> not_built </td>"
  else
    stat="<td>Unknown code: $stat</td>"
  fi
  
  if [ "x$y" = "x-" ] || [ "x$dy" = "x-" ] ; then
    align="center"
    ycolor="#ff9999"
  else
    align="right"
    ycolor="#ffffff"
  fi
  
  echo "  <td align=${align} bgcolor=\"${ycolor}\"> $y  </td> "
  echo "  <td align=${align} bgcolor=\"${ycolor}\"> $dy </td> "
  echo "  ${stat}"
  echo "</tr>"
}

close_table() {
  echo -e "\n</table>"
}

write_test_descriptions() {
  echo "<h1>Test routines</h1>"
  for test_name in $* ; do
    test_src=$(ls -1 ${test_name}.* | head -n 1)
    echo "<h2><a name=\"${test_name}\" href=\"http://svnweb.cern.ch/world/wsvn/GENSER/validation/trunk/tests/${test_src}\">${test_name}</a></h2>"
    echo "<p>"
    sed '/#@#/!d;s/^.*#@#//;s/$/<br>/;' ${test_src}
  done
}

close_html () {
  echo "</body>"
  echo "</html>"
}

# main: 

TXTFILE=$1

if [[ "$TXTFILE" == "" ]] ; then
  echo "Usage: ./comp2html.sh {file}"
  exit 1
fi

if [ ! -s $TXTFILE ] ; then
  echo "ERROR: Can't open input file ${TXTFILE}"
  exit 1
fi

versions=$(cat ${TXTFILE} | grep "^@version@" | cut -d : -f 2 | tr -d ' ' | sort -r | uniq | xargs)
test_names=$(cat ${TXTFILE} | grep "^@ref@" | cut -d : -f 2 | tr -d ' ' | uniq | sort | uniq | xargs)
generators=$(echo "$test_names" | tr ' ' '\n' | cut -d _ -f 1 | sort | uniq | xargs)

open_html
write_parameters
write_notation
write_table_controls

# drop empty lines,
# clean double spaces and clean spaces around ':'
grep -v -E "^[ ]*$|^[ ]*#.*$" ${TXTFILE} | \
sed -e 's,  , ,g' -e 's,: ,:,g' -e 's, :,:,g' | \
while read str; do
  cmd=$(echo $str | cut -d : -f 1)
  
  if   [[ "$cmd" == "@platform@" ]] ; then
    platform=$(echo $str | cut -d : -f 2)
    start_platform $platform
    write_versions "$versions"
    
  elif [[ "$cmd" == "@ref@" ]] ; then
    rowTest=""
    rowStat="[OK]"
    
    test_name=$(echo $str | cut -d : -f 2)
    test_num=$(echo $str | cut -d : -f 3)
    y_ref=$(echo $str | cut -d : -f 4)
    dy_ref=$(echo $str | cut -d : -f 5)
    
  elif [[ "$cmd" == "@version@" ]] ; then
    #version=$(echo $str | cut -d : -f 2)
    str3=$(echo $str | cut -d : -f 3)
    
    y=$(echo $str3 | cut -d ' ' -f 1)
    dy=$(echo $str3 | cut -d ' ' -f 2)
    # positions 3 and 4 are y_ref, dy_ref
    dev=$(echo $str3 | cut -d ' ' -f 5)
    stat=$(echo $str3 | cut -d ' ' -f 6)
    
    rowTest="$rowTest | $y $dy $dev $stat"
    if [[ "$stat" != "[OK]" ]] ; then
      rowStat=$stat
    fi
    
  elif [[ "$cmd" == "@end_test@" ]] ; then
    write_test_name $test_name $test_num $rowStat
    echo ${rowTest/ |} | tr '|' '\n' | while read y dy dev stat ; do
      write_y_dy $y $dy $dev $stat
    done
    close_test $y_ref $dy_ref $rowStat
    
  elif [[ "$cmd" == "@end_platform@" ]] ; then
    close_table
    
  else
    echo "Stray line in ${TXTFILE}: $str" >&2 
  fi
done

write_test_descriptions ${test_names}
close_html
