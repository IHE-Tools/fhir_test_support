#!/usr/bin/perl

# Convert CSV file of encounter information to FHIR Encounter resources

use strict;
require common;

sub check_args {
 if (scalar(@_) != 3) {
  print STDERR
	"Usage: <csv file> <encounter template> <map file>\n";
  die;
 }
}

sub map_code_to_encounter_class{
 my ($code_value) = @_;

 my %h = (
   "99213" => "AMB,ambulatory",
   "99213a" => "EMER,emergency",
   "99213b" => "FLD,field",
   "99213c" => "HH,home health",
   "99213d" => "IMP,inpatient encounter",
   "99213e" => "ACUTE,inpatient acute",
   "99213f" => "NONAC,inpatient non-acute",
   "99213g" => "OBSENC,observation encounter",
   "99213h" => "PRENC,preadmission",
   "99213i" => "SS,short stay",
   "99213j" => "VR,virtual",
 );

 my $encounter_class = $h{$code_value};
 die "Could not map code $code_value to a FHIR Encounter class\n" if ($encounter_class eq "");

 return split /,/, $encounter_class;
}

sub map_code_to_reason {
 my ($code_value) = @_;
 return ("5902003", "History and physical examination, complete");
}

sub lookup_system {
 my ($code_system_oid) = @_;

 my %h = (
   "2.16.840.1.113883.6.1" => "http://loinc.org",
   "2.16.840.1.113883.2.9.6.1.48.2" => "http://arsenal.it",
   "2.16.840.1.113883.2.9.2.50901.6.1" => "http://arsenal.it/lab"
 );

 my $system_string = $h{$code_system_oid};

 die "Could not lookup coding system for this OID: $code_system_oid"
	if ($system_string eq "");
 return $system_string;
}

sub lookup_unit {
 my ($code_value, $unit) = @_;

 my %h = (
   "8867-4:/min" => "beats/min"
 );

 my $key_value = $code_value . ":" . $unit;

 if ($h{$key_value} ne "") {
  $unit = $h{$key_value};
 }
 return $unit;
}


sub process_line {
 my ($line, $template, %fhir_resource_map) = @_;
 my ($encounter_string, $doc_patient_id, $doc_pat_id_assigner,
	$time_stamp,
	$code_value, $code_system_oid, $code_meaning) = split /,/, $line;

 return if (!$encounter_string);
 return if ($encounter_string ne "Encounter");

 my ($class_code, $class_display) = map_code_to_encounter_class($code_value);
 my ($reason_code, $reason_display) = map_code_to_reason($code_value);

 $code_meaning = common::xml_escape($code_meaning);

# my $code_system = lookup_system($code_system_oid);
 my $enc_date    = common::translate_to_date($time_stamp);

 my $patient_resource = common::lookup_patient_resource($doc_patient_id, $doc_pat_id_assigner, %fhir_resource_map);
 my $location_resource = common::lookup_location_resource("BJC-1", %fhir_resource_map);
 my $organization_resource = common::lookup_organization_resource("WUSTL-PHYSICIANS", %fhir_resource_map);

# my $obs_system = "http://unitsofmeasure.org";
# my $obs_unit = lookup_unit ($code_value, $obs_coded_unit);
# my $category_xml = lookup_category_xml($code_value);
#
 my $enc_id_system = "assign_oid_fix";
#
 my $enc_guid = common::new_guid();

 my $output = $template;
 $output =~ s/ENC-ID-SYSTEM/$enc_id_system/g;
 $output =~ s/ENC-GUID/$enc_guid/g;

# Encounter.class
 $output =~ s/ENCOUNTERClass-CODE/$class_code/g;
 $output =~ s/ENCOUNTERClass-DISPLAY/$class_display/g;
#
# Encounter.serviceType
# Encounter.subject
 $output =~ s/PATIENT-REFERENCE/$patient_resource/g;

# Encounter.participant
# Encounter.period

# Encounter.reason
 $output =~ s/REASON-CODE/$reason_code/g;
 $output =~ s/REASON-DISPLAY/$reason_display/g;

# Encounter.diagnosis

# Encounter.location
 $output =~ s/LOCATION-REFERENCE/$location_resource/g;

# Encounter.serviceProvider
 $output =~ s/ORGANIZATION-REFERENCE/$organization_resource/g;



 print "$output\n";
# print STDERR "$output\n";
}

## Main starts here

check_args(@ARGV);
my @lines = common::read_text_file($ARGV[0]);
my $template = common::read_text_file_single_line($ARGV[1]);
my %fhir_resource_map = common::read_map($ARGV[2]);

foreach my $line(@lines) {
 process_line($line, $template, %fhir_resource_map);
}
