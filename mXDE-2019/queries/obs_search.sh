#!/bin/sh

BASE=http://localhost:8080/hapi-fhir-rw/baseDstu3

touch a.json
rm    *.json

# all observations
curl -o obs_all.json $BASE/Observation?

# all observations, include Subject in result
curl -o obs_all_w-subject.json $BASE/Observation?_include=Observation:subject

# all observations, include Patient in result
curl -o obs_all_w-patient.json $BASE/Observation?_include=Observation:patient

# all observations, include Provenance in result
curl -o obs_all_w-provenance.json $BASE/Observation?_revinclude=Provenance:target

# category
curl -o obs_vital-signs.json "$BASE/Observation?category=http://hl7.org/fhir/observation-category%7Cvital-signs"

# code
curl -o obs_blood-glucose.json "$BASE/Observation?code=http://loinc.org%7C32016-8"

# subject
curl -o obs_subject-49.json "$BASE/Observation?subject=49&_pretty=true"

# subject (no observations)
curl -o obs_subject-52.json "$BASE/Observation?subject=52&_pretty=true"

# date searches
curl -o obs_date-eq-20190217.json "$BASE/Observation?date=2019-02-17&_pretty=true"

curl -o obs_date-gt-20190101.json "$BASE/Observation?date=gt2019-01-01&_pretty=true"

curl -o obs_date-lt-20190101.json "$BASE/Observation?date=lt2019-01-01&_pretty=true"

