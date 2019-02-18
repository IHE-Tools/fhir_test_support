#!/bin/sh

./obscda_to_csv.sh $1
perl obscsv_to_fhirxml.pl $1.csv ../templates/fhir_observation.xml > $1-obs.xml
