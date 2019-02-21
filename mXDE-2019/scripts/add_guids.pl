#!/usr/bin/perl

use Data::GUID;

my $guid = Data::GUID->new;
my $string = $guid->as_string;
print "$string\n";
