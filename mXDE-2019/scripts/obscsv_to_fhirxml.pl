#!/usr/bin/perl

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

sub check_args {
 if (scalar(@_) != 2) {
  print STDERR
	"Usage: <csv file> <observation template>\n";
  die;

 }
}

sub map_code_to_category {
 my ($code_value) = @_;

 my %h = (
   "8302-2" => "vital-signs",
   "3141-9" => "vital-signs",
   "8480-6" => "vital-signs",
   "8462-4" => "vital-signs",
   "8867-4" => "vital-signs",
 );

 return $h{$code_value};
}

sub lookup_category_xml {
 my ($code_value) = @_;

 my $category_xml = "";
 my $category_code = map_code_to_category($code_value);
 if ($category_code eq "vital-signs") {
  $category_xml =
" <category> 
   <coding> 
     <system value=\"http://hl7.org/fhir/observation-category\"/> 
     <code value=\"vital-signs\"/> 
     <display value=\"Vital Signs\"/> 
   </coding> 
   <text value=\"Vital Signs\"/> 
 </category>";
 }

 return $category_xml;
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

sub lookup_patient_resource {
 my ($doc_patient_id, $doc_pat_id_assigner) = @_;

 my %h = (
   "1.3.6.1.4.1.21367.13.20.1000:2019.100.1" => "49"
 );

 my $key_value = $doc_pat_id_assigner . ":" . $doc_patient_id;

 $pat_resource = $h{$key_value};
 die "No Patient Resource found for this combination ($doc_pat_id_assigner, $doc_patient_id)\n" if ($pat_resource eq "");

 return $pat_resource;
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

sub xml_escape {
 my ($s) = @_;
 $s =~ s/&/&amp;/sg;
 $s =~ s/</&lt;/sg;
 $s =~ s/>/&gt;/sg;
 $s =~ s/"/&quot;/sg;
 return $s;
}


sub process_line {
 my ($line, $template) = @_;
 my ($obs, $doc_patient_id, $doc_pat_id_assigner,
	$code_value, $status, $time_stamp, $code_system_oid, 
	$code_meaning, $obs_value, $obs_coded_unit) = (split /,/, $line);
 return if (!$obs);
 return if ($obs ne "Observation");

 $code_meaning = xml_escape($code_meaning);
 $obs_value    = xml_escape($obs_value);

 my $code_system = lookup_system($code_system_oid);
 my $obs_date    = translate_to_date($time_stamp);
 my $patient_resource = lookup_patient_resource($doc_patient_id, $doc_pat_id_assigner);

 my $obs_system = "http://unitsofmeasure.org";
 my $obs_unit = lookup_unit ($code_value, $obs_coded_unit);
 my $category_xml = lookup_category_xml($code_value);

 my $output = $template;
 $output =~ s/PATIENT-REFERENCE/$patient_resource/g;
 $output =~ s/CATEGORY/$category_xml/g;

 $output =~ s/OBS-UNIT/$obs_unit/g;
 $output =~ s/OBS-CODED-UNIT/$obs_coded_unit/g;
 $output =~ s/OBS-SYSTEM/$obs_system/g;
 $output =~ s/OBS-VALUE/$obs_value/g;

 $output =~ s/OBS-DATE/$obs_date/g;

 $output =~ s/CODE-SYSTEM/$code_system/g;
 $output =~ s/CODE-VALUE/$code_value/g;
 $output =~ s/CODE-DISPLAY/$code_meaning/g;
 print "$output\n";
}

## Main starts here

check_args(@ARGV);
my @lines = read_text_file($ARGV[0]);
my $template = read_text_file_single_line($ARGV[1]);

foreach my $line(@lines) {
 process_line($line, $template);
}
