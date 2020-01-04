#!/bin/sh

BASE=http://localhost:8080/hapi-fhir-rw/baseDstu3

check_args() {
 if [ $# -lt 1 ] ; then
  echo "Arguments: encoding"
  echo "           encoding is either 'xml' or 'json'"
  exit 1
 fi
}

# Main starts here

check_args $*
FORMAT=$1

touch a.$FORMAT
rm    *.$FORMAT

touch z.$FORMAT

# all observations
curl -o obs_all.$FORMAT $BASE/Observation?_format-$FORMAT

# all observations, include Subject in result
curl -o obs_all_w-subject.$FORMAT "$BASE/Observation?_format=$FORMAT&_include=Observation:subject"

# restrict search by patient + category
curl -o obs_vital-signs.$FORMAT \
	"$BASE/Observation?_format=$FORMAT&patient=251&category=http://hl7.org/fhir/observation-category%7Cvital-signs"

# restrict search by patient + category + code (body weight)
curl -o obs_vital-signs_body-weight.$FORMAT \
	"$BASE/Observation?_format=$FORMAT&patient=251&category=http://hl7.org/fhir/observation-category%7Cvital-signs&code=http://loinc.org%7C3141-9"

# restrict search by patient + category + date (20170101)
curl -o obs_vital-signs_after-2017.$FORMAT \
	"$BASE/Observation?_format=$FORMAT&patient=251&category=http://hl7.org/fhir/observation-category%7Cvital-signs&date=gt2017-01-01"

# restrict search by patient + category + code (body weight) + date (20170101)
curl -o obs_vital-signs_body-weight_after-2017.$FORMAT \
	"$BASE/Observation?_format=$FORMAT&patient=251&category=http://hl7.org/fhir/observation-category%7Cvital-signs&code=http://loinc.org%7C3141-9&date=gt2017-01-01"





##- # all observations, include Patient in result
##- curl -o obs_all_w-patient.json $BASE/Observation?_include=Observation:patient
##- 
##- # all observations, include Provenance in result
##- curl -o obs_all_w-provenance.json $BASE/Observation?_revinclude=Provenance:target
##- 
##- # category
##- curl -o obs_vital-signs.json "$BASE/Observation?category=http://hl7.org/fhir/observation-category%7Cvital-signs"
##- 
##- # code
##- curl -o obs_blood-glucose.json "$BASE/Observation?code=http://loinc.org%7C32016-8"
##- 
##- # subject
##- curl -o obs_subject-49.json "$BASE/Observation?subject=49&_pretty=true"
##- 
##- # subject (no observations)
##- curl -o obs_subject-52.json "$BASE/Observation?subject=52&_pretty=true"
##- 
##- # date searches
##- curl -o obs_date-eq-20190217.json "$BASE/Observation?date=2019-02-17&_pretty=true"
##- 
##- curl -o obs_date-gt-20190101.json "$BASE/Observation?date=gt2019-01-01&_pretty=true"
##- 
##- curl -o obs_date-lt-20190101.json "$BASE/Observation?date=lt2019-01-01&_pretty=true"
##- 

echo Done `date`
