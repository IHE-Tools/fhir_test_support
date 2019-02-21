#!/bin/sh

BASE="http://localhost:8080/hapi-fhir-rw/baseDstu3"

touch /tmp/obs
rm -r /tmp/obs
mkdir -p /tmp/obs

for resource in $* ; do
 echo $resource
 curl -o /tmp/obs/$resource.txt -X DELETE "$BASE/Observation/$resource?_pretty=true"
done
