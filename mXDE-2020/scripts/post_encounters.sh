#!/bin/sh

SAXON=../../lib/saxon9he.jar

check_args() {
 # This script requires no arguments
 return
}

check_args $*
FOLDER=../hand_generated/encounters
. ./check_folder.sh $FOLDER

for resource in $FOLDER/*.xml ; do
 log=../logs/`./last_path_component.sh $resource`.txt
 echo $resource $log
 ./post_resource.sh Encounter $resource $log
 if [ $? != 0 ] ; then
  echo "./post_resource.sh Procedure" failed
  exit 1
 fi
done
