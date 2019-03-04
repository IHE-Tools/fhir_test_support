#!/bin/sh

BASE="http://localhost:8080/hapi-fhir-rw/baseDstu3"
#BASE="https://ihe.wustl.edu/hapi-fhir/baseDstu3"
RESOURCE=""

AT='@'
HEADER="Content-Type: application/fhir+xml"

check_args() {
 if [ $# -lt 2 ] ; then
  echo "Arguments: resource file [file ...]"
  echo "           resource is a proper FHIR resource (Patient, Observation, ...)"
  echo "           file is one or more files to send to a FHIR server"
  exit 1
 fi
}

post_resource() {
 echo $1 $2
 URL="$BASE/$1?_format=xml&_pretty=true"
 FILE=$AT$2
 curl -s -X POST -H "$HEADER" -i --data-binary $FILE -w '%{http_code}' -o ../tmp/post_status.txt "$URL"
 echo "\t" $1 $2
}

check_args $*
RESOURCE=$1
shift

for f in $* ; do
 post_resource $RESOURCE $f
done
