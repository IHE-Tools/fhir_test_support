#!/bin/sh

check_args() {
 if [ $# != 1 ] ; then
  echo "Arguments: <file>"
  echo "           <file>.xml resides in ../CDA folder (../CDA/file.xml)"
  echo "           Do not use ../CDA/file.xml"
  exit 1
 fi
}

check_folder() {
 if [ ! -e obscda_to_csv.sh ] ; then
  echo "The file obscda_to_csv.sh is not found in the current folder."
  echo "This script expects you to be resident in the 'scripts' folder."
  exit 1
 fi
}

check_input() {
 if [ ! -e ../CDA/$1.xml ] ; then
  echo "The file ../CDA/$1.xml does not exist. Please check the name."
  exit 1
 fi
}

create_csv() {
 mkdir -p ../csv
 ./obscda_to_csv.sh ../CDA/$1.xml ../csv/$1.csv
 if [ $? != 0 ] ; then
  echo ""
  echo The script ./obscda_to_csv.sh ../CDA/$1.xml ../csv/$1.csv failed.
  echo Please review/repair.
  exit 1
 fi
}

create_observations() {
 mkdir -p ../fhir_observations ../tmp

 perl obscsv_to_fhirxml.pl ../csv/$1.csv ../templates/fhir_observation.xml > ../tmp/$1.obs
 if [ $? != 0 ] ; then
  echo Failed to execute perl obscsv_to_fhirxml.pl ../csv/$1.csv ../templates/fhir_observation/$1.xml ../tmp/$1.obs
  exit 1
 fi

 split -p "<Observation" ../tmp/$1.obs  "../fhir_observations/$1."
}


# Main starts here

check_args $*
check_folder
check_input $1

create_csv $1
create_observations $1

