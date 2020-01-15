#!/bin/sh

function check_status() {
 if [ $1 != 0 ] ; then
  echo Script failed: $*
  exit 1
 fi
 echo Status success: $*
 echo ""
}

                ./document_reference.sh p1_e1
check_status $? ./document_reference.sh p1_e1
                ./obscda_to_fhir_xml.sh p1_e1
check_status $? ./obscda_to_fhir_xml.sh p1_e1
                ./cda_to_enc_fhir_xml.sh p1_e1
check_status $? ./cda_to_enc_fhir_xml.sh p1_e1

                ./document_reference.sh p1_lab1
check_status $? ./document_reference.sh p1_lab1
                ./obscda_to_fhir_xml.sh p1_lab1
check_status $? ./obscda_to_fhir_xml.sh p1_lab1
                ./obscda_to_fhir_xml.sh p1_lab2
check_status $? ./obscda_to_fhir_xml.sh p1_lab2

                ./document_reference.sh p1_hp1
check_status $? ./document_reference.sh p1_hp1
                ./obscda_to_fhir_xml.sh p1_hp1
check_status $? ./obscda_to_fhir_xml.sh p1_hp1
