#!/usr/bin/perl

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
 if (scalar(@_) < 2) {
  print STDERR
	"Usage: file1 file2 [file...]>\n";
  die;
 }
}

## Main starts here

check_args(@ARGV);
my $output = "";
foreach $f (@ARGV) {
 my $content = read_text_file_single_line($f);
 chomp $content;
 $output .= $content . "\t";
}

chop $output;
print "$output\n";
