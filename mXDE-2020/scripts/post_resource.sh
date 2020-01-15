#!/bin/sh

. ./base_url.sh

RESOURCE=""

AT='@'
HEADER="Content-Type: application/fhir+xml"

check_args() {
 if [ $# != 3 ] ; then
  echo "Arguments: resource file log_file"
  echo "           resource is a proper FHIR resource (Patient, Observation, ...)"
  echo "           file is one file to send to a FHIR server"
  echo "           log_file is log information from the curl command"
  exit 1
 fi
}

post_resource() {
 echo $1 $2 $3
 URL="$BASE_URL/$1?_format=xml&_pretty=true"
 FILE=$AT$2
 LOG=$3
 HTTP_STATUS=`curl -s -X POST -H "$HEADER" -i --data-binary $FILE -w '%{http_code}' -o $LOG "$URL"`
 if [ $? != 0 ] ; then
  echo "The curl command itself failed."
  echo "The post_resource.sh script will exit with an error code."
  exit 1
 fi

 if [ $HTTP_STATUS != "201" ] ; then
  echo "The POST request returned an unrecognized result: $HTTP_STATUS"
  echo "The post_resource.sh script will exit with an error code."
  exit 1
 fi

 # We need this for a script that will follow
 cp $LOG ../tmp/post_status.txt
}

check_args $*
post_resource $*
