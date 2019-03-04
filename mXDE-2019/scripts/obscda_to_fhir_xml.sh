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
 if [ ! -e obscda_to_csv.sh ] ; then
  echo "The file obscda_to_csv.sh is not found in the current folder."
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

map_document_ref() {
 echo map_document $*
 map_file=$1
 touch ../tmp/post_status.txt.ab; rm ../tmp/post_status.txt.ab
 split -p "<DocumentReference" ../tmp/post_status.txt ../tmp/post_status.txt.
 java -jar $SAXON -o:../tmp/DocumentReference.id.txt ../tmp/post_status.txt.ab ../xsl/DocumentReference.id.xsl
 java -jar $SAXON -o:../tmp/DocumentReference.masteridentifier.txt ../tmp/post_status.txt.ab ../xsl/DocumentReference.masteridentifier.xsl
 echo DocumentReference > ../tmp/DocumentReference.txt

 perl cat_files.pl ../tmp/DocumentReference.txt ../tmp/DocumentReference.masteridentifier.txt ../tmp/DocumentReference.id.txt >> $map_file
}

post_resource() {
 echo post observation $*
 ./post_resource.sh $1 $2
 if [ $? != 0 ] ; then
  echo "./post_resource.sh $1 $2" failed
  exit 1
 fi
}

map_observation() {
 echo map_observation $*
 map_file=$1
 touch ../tmp/post_status.txt.ab; rm ../tmp/post_status.txt.ab
 split -p "<Observation" ../tmp/post_status.txt ../tmp/post_status.txt.
 java -jar $SAXON -o:../tmp/Observation.id.txt         ../tmp/post_status.txt.ab ../xsl/Observation.id.xsl
 java -jar $SAXON -o:../tmp/Observation.identifier.txt ../tmp/post_status.txt.ab ../xsl/Observation.identifier.xsl
 echo Observation > ../tmp/Observation.txt

 perl cat_files.pl ../tmp/Observation.txt ../tmp/Observation.identifier.txt ../tmp/Observation.id.txt >> $map_file
}

construct_doc_reference() {
 echo construct_doc_reference $*
 mkdir -p ../fhir_documentreferences
 BASE=$1
 perl doc_to_docref-mhd.pl \
	../CDA/$BASE.xml ../templates/fhir_documentReference.xml ../tmp/fhir.map.txt \
	> ../fhir_documentreferences/$BASE.docref.xml
}


construct_provenance_mhd() {
 echo construct_provenance_mhd $*
 mkdir -p ../fhir_provenance
 BASE=$1
 OBS=$2
 OBS_BASE=$(basename $OBS)
 PROVENANCE_FILE=../fhir_provenance/$OBS_BASE.prov
 echo NA > ../tmp/Device.identifier.txt

 java -jar $SAXON -o:../tmp/Observation.identifier.txt $OBS ../xsl/Observation.identifier.xsl

 perl obs_to_provenance-mhd.pl \
	../tmp/Observation.identifier.txt ../tmp/DocumentReference.masterIdentifier.txt	\
	../tmp/Device.identifier.txt	\
	../templates/fhir_provenance-mhd.xml ../tmp/fhir.map.txt \
	> $PROVENANCE_FILE
}


create_csv() {
 echo create_csv $*
 mkdir -p ../csv
 ./obscda_to_csv.sh ../CDA/$1.xml ../csv/$1.csv
 if [ $? != 0 ] ; then
  echo ""
  echo The script ./obscda_to_csv.sh ../CDA/$1.xml ../csv/$1.csv failed.
  echo Please review/repair.
  exit 1
 fi
}

create_observations() {
 echo create_observations $*
 mkdir -p ../fhir_observations ../tmp
 BASE=$1
 MAP=$2

 perl obscsv_to_fhirxml.pl ../csv/$BASE.csv ../templates/fhir_observation.xml $MAP > ../tmp/$1.obs
 if [ $? != 0 ] ; then
  echo Failed to execute perl obscsv_to_fhirxml.pl ../csv/$BASE.csv ../templates/fhir_observation/$BASE.xml ../tmp/$BASE.obs
  exit 1
 fi

 split -p "<Observation" ../tmp/$BASE.obs  "../fhir_observations/$BASE.obs."
}


# Main starts here

check_args $*
check_folder
check_input $1

construct_doc_reference $1
#post_resource DocumentReference ../fhir_documentreferences/$1.docref.xml
#map_document_ref ../tmp/fhir.map.txt

create_csv $1
create_observations $1 ../tmp/fhir.map.txt

for observation_resource in ../fhir_observations/$1.obs.?? ; do
 post_resource Observation $observation_resource
 map_observation ../tmp/fhir.map.txt

 PROVENANCE_FILE="no_such_file"
 construct_provenance_mhd $1 $observation_resource

 post_resource Provenance $PROVENANCE_FILE
done
