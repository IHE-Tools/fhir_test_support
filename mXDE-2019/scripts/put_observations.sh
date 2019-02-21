#!/bin/sh

BASE="http://localhost:8080/hapi-fhir-rw/baseDstu3"
RESOURCE=Observation

AT='@'
HEADER="Content-Type: application/fhir+xml"

check_args() {
 if [ $# == 0 ] ; then
  echo "Arguments: file [file ...]"
  echo "           One or more files to set to a FHIR server"
  exit 1
 fi
}

put_observation() {
 echo $1
 URL="$BASE/$RESOURCE?_format=xml&_pretty=true"
 FILE=$AT$1
 curl -s -X POST -H "$HEADER" -i --data-binary $FILE -w '%{http_code}' -o /tmp/x.txt "$URL"
 echo "\t" $1
}

check_args $*

for f in $* ; do
 put_observation $f
done
