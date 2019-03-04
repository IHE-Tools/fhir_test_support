#!/usr/bin/perl

require common;
use strict;

sub check_args {
 if (scalar(@_) != 3) {
  print STDERR
	"Usage: <doc xml> <doc ref template> <map file>\n\n" .
	"       <doc xml>:          CDA document (XML)\n" .
	"       <doc ref template>: template file\n" .
	"       <map file>:         Maps internal document identifiers to resource id's\n";
  die;
 }
}

#sub map_code_to_category {
# my ($code_value) = @_;
#
# my %h = (
#   "8302-2" => "vital-signs",
#   "3141-9" => "vital-signs",
#   "8480-6" => "vital-signs",
#   "8462-4" => "vital-signs",
#   "8867-4" => "vital-signs",
# );
#
# return $h{$code_value};
#}
#
#sub lookup_category_xml {
# my ($code_value) = @_;
#
# my $category_xml = "";
# my $category_code = map_code_to_category($code_value);
# if ($category_code eq "vital-signs") {
#  $category_xml =
#" <category> 
#   <coding> 
#     <system value=\"http://hl7.org/fhir/observation-category\"/> 
#     <code value=\"vital-signs\"/> 
#     <display value=\"Vital Signs\"/> 
#   </coding> 
#   <text value=\"Vital Signs\"/> 
# </category>";
# }
#
# return $category_xml;
#}
#
#sub lookup_system {
# my ($code_system_oid) = @_;
#
# my %h = (
#   "2.16.840.1.113883.6.1" => "http://loinc.org",
#   "2.16.840.1.113883.2.9.6.1.48.2" => "http://arsenal.it",
#   "2.16.840.1.113883.2.9.2.50901.6.1" => "http://arsenal.it/lab"
# );
#
# my $system_string = $h{$code_system_oid};
#
# die "Could not lookup coding system for this OID: $code_system_oid"
#	if ($system_string eq "");
# return $system_string;
#}
#
#sub lookup_patient_resource {
# my ($doc_patient_id, $doc_pat_id_assigner, %fhir_resource_map) = @_;
#
## my %h = (
##   "1.3.6.1.4.1.21367.13.20.1000:2019.100.1" => "49"
## );
#
# my $key_value = "Patient" . "/" . $doc_pat_id_assigner . "/" . $doc_patient_id;
#
# my $pat_resource = $fhir_resource_map{$key_value};
# die "No Patient Resource found for this combination ($doc_pat_id_assigner, $doc_patient_id)\n" if ($pat_resource eq "");
#
# return $pat_resource;
#}
#
#sub lookup_unit {
# my ($code_value, $unit) = @_;
#
# my %h = (
#   "8867-4:/min" => "beats/min"
# );
#
# my $key_value = $code_value . ":" . $unit;
#
# if ($h{$key_value} ne "") {
#  $unit = $h{$key_value};
# }
# return $unit;
#}
#
#sub translate_to_date {
# my ($time_stamp) = @_;
#
# my $date_string =
#	substr($time_stamp, 0, 4) .
#	"-" .
#	substr($time_stamp, 4, 2) .
#	"-" .
#	substr($time_stamp, 6, 2);
# return $date_string;
#}
#
#sub xml_escape {
# my ($s) = @_;
# $s =~ s/&/&amp;/sg;
# $s =~ s/</&lt;/sg;
# $s =~ s/>/&gt;/sg;
# $s =~ s/"/&quot;/sg;
# return $s;
#}
#
#
sub create_document_reference {
 my ($template, %fhir_resource_map) = @_;

 my $output = $template;

 my $docref_guid = common::new_guid();
 $output =~ s/DOCREF-GUID/$docref_guid/g;

 print "$output\n";
}

## Main starts here

check_args(@ARGV);
# Read the original CDA document
# $ARGV[0]
my $template = common::read_text_file_single_line($ARGV[1]);
my %fhir_resource_map = common::read_map($ARGV[2]);

create_document_reference($template, %fhir_resource_map);
#foreach my $line(@lines) {
# process_line($line, $template, %fhir_resource_map);
#}
