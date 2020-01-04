#!/bin/sh

# master_setup pushes Patient and Device resources
# to a FHIR server to enable testing

SAXON=../lib/saxon9he.jar
MAP=../tmp/fhir.map.txt

initialize_folders () {
 for f in csv	\
	fhir_documentreferences	\
	fhir_encounters	\
	fhir_observations	\
	fhir_provenance	\
	mcsd	\
	tmp	\
	; do
  rm -r ../$f
  mkdir ../$f
 done
}

initialize_map () {
 touch $1
 rm -f $1
 touch $1

}

wget_mcsd_resources () {
 touch ../mcsd
 rm -r ../mcsd
 mkdir ../mcsd

 wget --recursive -nd -P ../mcsd -o /tmp/wget.log	\
	ftp://ftp.ihe.net/Connectathon/test_data/ITI-profiles/mCSD-test-data/mCSD_FHIR_Resources

}

post_device() {
 echo post device
 ./post_resource.sh Device ../templates/fhir_device.xml
 if [ $? != 0 ] ; then
  echo "./post_resource.sh Device ../templates/fhir_device.xml" failed
  exit 1
 fi
}

map_device() {
 echo map_device
 map_file=$1
 touch ../tmp/post_status.txt.ab; rm ../tmp/post_status.txt.ab
 split -p "<Device" ../tmp/post_status.txt ../tmp/post_status.txt.
 java -jar $SAXON -o:../tmp/device.id.txt ../tmp/post_status.txt.ab ../xsl/Device.id.xsl
 echo "Device\tNA" > ../tmp/device.txt
 perl cat_files.pl ../tmp/device.txt ../tmp/device.id.txt >> $map_file
}

post_location() {
 echo post location
 ./post_resource.sh Location ../templates/fhir_location.xml
 if [ $? != 0 ] ; then
  echo "./post_resource.sh Location ../templates/fhir_location.xml" failed
  exit 1
 fi
}

map_location() {
 echo map_location
 map_file=$1
 touch ../tmp/post_status.txt.ab; rm ../tmp/post_status.txt.ab
 split -p "<Location" ../tmp/post_status.txt ../tmp/post_status.txt.
 java -jar $SAXON -o:../tmp/location.id.txt ../tmp/post_status.txt.ab ../xsl/Location.id.xsl
 java -jar $SAXON -o:../tmp/location.identifier.txt ../tmp/post_status.txt.ab ../xsl/Location.identifier.xsl
 echo "Location" > ../tmp/location.txt
 perl cat_files.pl ../tmp/location.txt ../tmp/location.identifier.txt ../tmp/location.id.txt >> $map_file
}

post_organization() {
 echo post organization
 ./post_resource.sh Organization ../templates/fhir_organization.xml
 if [ $? != 0 ] ; then
  echo "./post_resource.sh Organization ../templates/fhir_organization.xml" failed
  exit 1
 fi
}

map_organization() {
 echo map_organization
 map_file=$1
 touch ../tmp/post_status.txt.ab; rm ../tmp/post_status.txt.ab
 split -p "<Organization" ../tmp/post_status.txt ../tmp/post_status.txt.
 java -jar $SAXON -o:../tmp/organization.id.txt ../tmp/post_status.txt.ab ../xsl/Organization.id.xsl
 java -jar $SAXON -o:../tmp/organization.identifier.txt ../tmp/post_status.txt.ab ../xsl/Organization.identifier.xsl
 echo "Organization" > ../tmp/organization.txt
 perl cat_files.pl ../tmp/organization.txt ../tmp/organization.identifier.txt ../tmp/organization.id.txt >> $map_file
}

post_patient() {
 ./post_resource.sh Patient $1
 if [ $? != 0 ] ; then
  echo "./post_resource.sh Patient $1" failed
  exit 1
 fi
}

map_patient() {
 echo map_patient
 map_file=$1
 touch ../tmp/post_status.txt.ab; rm ../tmp/post_status.txt.ab
 split -p "<Patient" ../tmp/post_status.txt ../tmp/post_status.txt.
 java -jar $SAXON -o:../tmp/patient.id.txt ../tmp/post_status.txt.ab ../xsl/Patient.id.xsl
 java -jar $SAXON -o:../tmp/patient.identifiers.txt ../tmp/post_status.txt.ab ../xsl/Patient.identifier.xsl

 touch ../tmp/patient.identifiers.txt.ab; rm -f ../tmp/patient.identifiers.??
 split -l 1 ../tmp/patient.identifiers.txt ../tmp/patient.identifiers.txt.
 echo Patient > ../tmp/patient.txt
 for identifier in ../tmp/patient.identifiers.txt.?? ; do
  perl cat_files.pl ../tmp/patient.txt $identifier ../tmp/patient.id.txt >> $map_file
 done
}


initialize_folders
initialize_map $MAP

wget_mcsd_resources

#post_device
#map_device $MAP
#
#post_location
#map_location $MAP
#
#post_organization
#map_organization $MAP

#for patient_resource in Patient-2703 ; do
# post_patient ../fhir_patients/$patient_resource.xml
# map_patient $MAP
#done

