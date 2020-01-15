#!/bin/sh

 if [ ! -e base_url.sh ] ; then
  echo "The file base_url.sh is not found in the current folder."
  echo "This script expects you to be resident in the 'scripts' folder."
  exit 1
 fi

 if [ ! -d $1 ] ; then
  echo "The folder $1 is not found."
  echo "There is something wrong with the folder structure."
  exit 1
 fi

 mkdir -p ../logs

