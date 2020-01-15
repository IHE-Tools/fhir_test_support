#!/bin/sh

SAXON=../../lib/saxon9he.jar

check_args() {
 # This script requires no arguments
 return
}

check_folder() {
 if [ ! -e base_url.sh ] ; then
  echo "The file base_url.sh is not found in the current folder."
  echo "This script expects you to be resident in the 'scripts' folder."
  exit 1
 fi

 if [ ! -d ../fhir_patients ] ; then
  echo "The folder ../fhir_patients is not found."
  echo "There is something wrong with the folder structure."
  exit 1
 fi

 mkdir -p ../logs
}


post_resource() {
 echo post $*
 ./post_resource.sh $*
 if [ $? != 0 ] ; then
  echo "./post_resource.sh $1 $2" failed
  exit 1
 fi
}

check_args $*
check_folder

for patient_resource in ../fhir_patients/*.xml ; do
 patient_log=../logs/`./last_path_component.sh $patient_resource`.txt
 echo $patient_resource $patient_log
 ./post_resource.sh Patient $patient_resource $patient_log
 if [ $? != 0 ] ; then
  echo "./post_resource.sh Patient" failed
  exit 1
 fi
done
