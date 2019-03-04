# Common subroutines

use strict;
use warnings;
use Env;
use Data::GUID;
use XML::XPath;
use POSIX qw/strftime/;

package common;

#require Exporter;
#@ISA=qw(Exporter);

sub read_text_file {
 my ($path) = @_;

 my $handle;

 unless (open $handle, "<:encoding(utf8)", $path) {
   die "Could not open file '$path': $!\n";
 }
 chomp(my @lines = <$handle>);
 close $handle;

 return @lines;
}

sub read_text_file_single_line {
 my ($path) = @_;

 my $handle;

 unless (open $handle, "<:encoding(utf8)", $path) {
   die "Could not open file '$path': $!\n";
 }
 local $/ = undef;
 (my $line = <$handle>);
 close $handle;

 return $line;
}

sub read_map {
 my ($map_file) = @_;
 my @lines = common::read_text_file($map_file);
 my %map;
 foreach my $line(@lines) {
  my ($resource, $identifier, $fhir_id) = (split /\t/, $line);
  my $key = $resource . "/" . $identifier;
  $map{$key} = $fhir_id;
 }
 return %map;
}

sub new_guid {
 my $guid = Data::GUID->new;
 return $guid->as_string;
}

sub current_time_instance {

 my $time_string = POSIX::strftime ("%Y-%m-%dT%H:%M:%SZ", gmtime);
 return $time_string;
}

sub xml_escape {
 my ($s) = @_;
 $s =~ s/&/&amp;/sg;
 $s =~ s/</&lt;/sg;
 $s =~ s/>/&gt;/sg;
 $s =~ s/"/&quot;/sg;
 return $s;
}

sub translate_to_date {
 my ($time_stamp) = @_;

 my $date_string =
        substr($time_stamp, 0, 4) .
        "-" .
        substr($time_stamp, 4, 2) .
        "-" .
        substr($time_stamp, 6, 2);
 return $date_string;
}

sub lookup_patient_resource {
 my ($doc_patient_id, $doc_pat_id_assigner, %fhir_resource_map) = @_;

 my $key_value = "Patient" . "/" . $doc_pat_id_assigner . "/" . $doc_patient_id;

 my $pat_resource = $fhir_resource_map{$key_value};
 die "No Patient Resource found for this combination ($doc_pat_id_assigner, $doc_patient_id)\n" if ($pat_resource eq "");

 return $pat_resource;
}

sub lookup_location_resource {
 my ($location_identifier, %fhir_resource_map) = @_;

 my $key_value = "Location" . "/" . $location_identifier;

 my $location_resource = $fhir_resource_map{$key_value};
 die "No Location Resource found for this combination ($location_identifier)\n" if ($location_resource eq "");

 return $location_resource;
}

sub lookup_organization_resource {
 my ($organization_identifier, %fhir_resource_map) = @_;

 my $key_value = "Organization" . "/" . $organization_identifier;

 my $organization_resource = $fhir_resource_map{$key_value};
 die "No Organization Resource found for this combination ($organization_identifier)\n" if ($organization_resource eq "");

 return $organization_resource;
}

1;
