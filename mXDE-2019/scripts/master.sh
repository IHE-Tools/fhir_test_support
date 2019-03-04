#!/bin/sh


./document_reference.sh p1_e1
./obscda_to_fhir_xml.sh p1_e1
./cda_to_enc_fhir_xml.sh p1_e1

./document_reference.sh p1_lab1
./obscda_to_fhir_xml.sh p1_lab1
./obscda_to_fhir_xml.sh p1_lab2

./document_reference.sh p1_hp1
./obscda_to_fhir_xml.sh p1_hp1
