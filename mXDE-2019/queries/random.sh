#!/bin/sh

BASE=http://hapi.fhir.org/baseDstu3

touch random.xml
rm    random.xml

curl -o random.xml "$BASE/Provenance?_format=xml&_pretty=true"

