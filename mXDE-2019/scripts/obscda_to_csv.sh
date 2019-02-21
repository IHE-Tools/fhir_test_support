#!/bin/sh

check_args() {
 if [ $# != 2 ] ; then
  echo "Arguments: <input> <output>"
  echo "           input is the name of the CDA input file"
  echo "           output is the name of the output CSV file"
  exit 1
fi

}

check_args $*

SAXON=../lib/saxon9he.jar

if [ ! -e $SAXON ] ; then
 echo The file $SAXON does not exist. Please retrieve a 9.x version from their
 echo website and intall saxon9he.jar in the lib folder.
 echo We are using version 9.8 from https://sourceforge.net/projects/saxon.
 exit 1
fi

java -jar $SAXON -o:$2 $1 ../xsl/cda_to_observations.xsl
