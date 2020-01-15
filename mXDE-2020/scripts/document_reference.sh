#!/bin/sh

# Script creates DocumentReference resources for a (CDA) document
# that is used as the source of other resources (Observation, Encounter, ...)

SAXON=../../lib/saxon9he.jar

check_args() {
 if [ $# != 1 ] ; then
  echo "Arguments: <file>"
  echo "           <file>.xml resides in ../CDA folder (../CDA/file.xml)"
  echo "           Do not use ../CDA/file.xml"
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

construct_doc_reference() {
 echo construct_doc_reference $*
 mkdir -p ../fhir_documentreferences
 BASE=$1
 perl doc_to_docref-mhd.pl \
	../CDA/$BASE.xml ../templates/fhir_documentReference.xml ../tmp/fhir.map.txt \
	> ../fhir_documentreferences/$BASE.docref.xml
}

post_resource() {
 echo post $*
 ./post_resource.sh $*
 if [ $? != 0 ] ; then
  echo "./post_resource.sh $*" failed
  exit 1
 fi
}

# Main starts here

check_args $*
check_folder
check_input $1

construct_doc_reference $1
post_resource DocumentReference ../fhir_documentreferences/$1.docref.xml ../logs/$1.docref.xml.txt
map_document_ref ../tmp/fhir.map.txt
