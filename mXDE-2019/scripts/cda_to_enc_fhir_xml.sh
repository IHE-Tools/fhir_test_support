#!/bin/sh

SAXON=../lib/saxon9he.jar

check_args() {
 if [ $# != 1 ] ; then
  echo "Arguments: <file> <doc reference>"
  echo "           <file>.xml resides in ../CDA folder (../CDA/file.xml)"
  echo "           Do not use ../CDA/file.xml"
  echo "           <doc reference> file will be posted to FHIR server and"
  echo "                           referenced in Provenance resources"
  exit 1
 fi
}

check_folder() {
 if [ ! -e cda_to_enc_csv.sh ] ; then
  echo "The file cda_to_enc_csv.sh is not found in the current folder."
  echo "This script expects you to be resident in the 'scripts' folder."
  exit 1
 fi
}

check_input() {
 if [ ! -e ../CDA/$1.xml ] ; then
  echo "The file ../CDA/$1.xml does not exist. Please check the name."
  exit 1
 fi
}

post_resource() {
 echo post $*
 ./post_resource.sh $1 $2
 if [ $? != 0 ] ; then
  echo "./post_resource.sh $1 $2" failed
  exit 1
 fi
}

map_encounter() {
 echo map_encounter $*
 map_file=$1
 touch ../tmp/post_status.txt.ab; rm ../tmp/post_status.txt.ab
 split -p "<Encounter" ../tmp/post_status.txt ../tmp/post_status.txt.
 java -jar $SAXON -o:../tmp/Encounter.id.txt         ../tmp/post_status.txt.ab ../xsl/Encounter.id.xsl
 java -jar $SAXON -o:../tmp/Encounter.identifier.txt ../tmp/post_status.txt.ab ../xsl/Encounter.identifier.xsl
 echo Encounter > ../tmp/Encounter.txt

 perl cat_files.pl ../tmp/Encounter.txt ../tmp/Encounter.identifier.txt ../tmp/Encounter.id.txt >> $map_file
}


construct_provenance_mhd() {
 echo construct_provenance_mhd $*
 mkdir -p ../fhir_provenance
 BASE=$1
 ENC=$2
 ENC_BASE=$(basename $ENC)
 PROVENANCE_FILE=../fhir_provenance/$ENC_BASE.prov
 echo NA > ../tmp/Device.identifier.txt

 java -jar $SAXON -o:../tmp/Encounter.identifier.txt $ENC ../xsl/Encounter.identifier.xsl

 perl enc_to_provenance-mhd.pl \
	../tmp/Encounter.identifier.txt ../tmp/DocumentReference.masterIdentifier.txt	\
	../tmp/Device.identifier.txt	\
	../templates/fhir_provenance-mhd.xml ../tmp/fhir.map.txt \
	> $PROVENANCE_FILE
}

create_csv() {
 echo create_csv $*
 mkdir -p ../csv
 ./cda_to_enc_csv.sh ../CDA/$1.xml ../csv/$1.encounter.csv
 if [ $? != 0 ] ; then
  echo ""
  echo The script ./cda_to_enc_csv.sh ../CDA/$1.xml ../csv/$1.encounter.csv failed
  echo Please review/repair.
  exit 1
 fi
}

create_fhir_encounters() {
 echo create_fhir_encounters $*
 mkdir -p ../fhir_encounters ../tmp
 BASE=$1
 MAP=$2

 perl enccsv_to_fhirxml.pl ../csv/$BASE.encounter.csv ../templates/fhir_encounter.xml $MAP > ../tmp/$1.enc
 if [ $? != 0 ] ; then
  echo Failed to execute \
	perl enccsv_to_fhirxml.pl ../csv/$BASE.csv \
		../templates/fhir_encounter.xml $MAP
  exit 1
 fi

 split -p "<Encounter" ../tmp/$BASE.enc  "../fhir_encounters/$BASE.enc."
}


# Main starts here

check_args $*
check_folder
check_input $1

create_csv $1
create_fhir_encounters $1 ../tmp/fhir.map.txt

for encounter_resource in ../fhir_encounters/$1.enc.?? ; do
 post_resource Encounter $encounter_resource
 map_encounter ../tmp/fhir.map.txt

 PROVENANCE_FILE="no_such_file"
 construct_provenance_mhd $1 $encounter_resource

 post_resource Provenance $PROVENANCE_FILE
done
