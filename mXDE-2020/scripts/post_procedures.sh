#!/bin/sh

SAXON=../../lib/saxon9he.jar

check_args() {
 # This script requires no arguments
 return
}

#post_resource() {
# echo post $*
# ./post_resource.sh $*
# if [ $? != 0 ] ; then
#  echo "./post_resource.sh $1 $2" failed
#  exit 1
# fi
#}

check_args $*
FOLDER=../hand_generated/procedures
. ./check_folder.sh $FOLDER

for resource in $FOLDER/*.xml ; do
 log=../logs/`./last_path_component.sh $resource`.txt
 echo $resource $log
 ./post_resource.sh Procedure $resource $log
 if [ $? != 0 ] ; then
  echo "./post_resource.sh Procedure" failed
  exit 1
 fi
done
