#!/usr/bin/perl

require common;
use strict;

sub check_args {
 if (scalar(@_) != 5) {
  print STDERR
	"Usage: <enc identifier> <docref identifier> <provenance template> <map file>\n" .
	"       <enc identifier>:      File contains Encounter.identifier.value\n" .
	"       <docref identifier>:   File contains DocumentReference.identifier.value\n" .
	"       <device identifier>:   File contains Device.identifier.value\n" .
	"       <doc ref xml>:         FHIR DocumentReference encoded in XML\n" .
	"       <provenance template>: template file\n" .
	"       <map file>:            Maps internal document identifiers to resource id's\n";
  die;
 }
}

sub map_encounter_id {
 my ($enc_identifier_file, %fhir_resource_map) = @_;
 my $enc_identifier = common::read_text_file_single_line($enc_identifier_file);
 chomp $enc_identifier;
 my $key_value = "Encounter" . "/" . $enc_identifier;
 my $enc_id = $fhir_resource_map{$key_value};
 return $enc_id;
}

sub map_identifier_to_id {
 my ($resource, $identifier_file, %fhir_resource_map) = @_;
 my $identifier = common::read_text_file_single_line($identifier_file);
 chomp $identifier;
 my $key_value = $resource . "/" . $identifier;
 my $id = $fhir_resource_map{$key_value};
 return $id;
}

sub construct_provenance_mhd {
 my ($enc_identifier_file, $docref_identifier_file, $device_identifier_file,
	$template, %fhir_resource_map) = @_;

 my $output = $template;

 my $enc_id = map_identifier_to_id("Encounter", $enc_identifier_file, %fhir_resource_map);
 my $docref_id = map_identifier_to_id("DocumentReference", $docref_identifier_file, %fhir_resource_map);
 my $device_id = map_identifier_to_id("Device", $device_identifier_file, %fhir_resource_map);
 my $target_ref = "Encounter/$enc_id";
 my $time_instance = common::current_time_instance();

 $output =~ s/TARGET-REF/$target_ref/g;
 $output =~ s/DOC-REF/$docref_id/g;
 $output =~ s/DEVICE-REF/$device_id/g;
 $output =~ s/PROVENANCE-RECORDED/$time_instance/g;

 print "$output\n";
}

## Main starts here

#	"Usage: <enc xml> <doc ref xml> <provenance template> <map file>\n" .
check_args(@ARGV);
my $template = common::read_text_file_single_line($ARGV[3]);
my %fhir_resource_map = common::read_map($ARGV[4]);
my $enc_identifier    = $ARGV[0];
my $docref_identifier = $ARGV[1];
my $device_identifier = $ARGV[2];

construct_provenance_mhd(
	$enc_identifier, $docref_identifier, $device_identifier,
	$template, %fhir_resource_map);
