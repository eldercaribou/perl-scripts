#!/usr/bin/perl

# test regular expressions

print "please input a test string: ";
$input = <STDIN>;
chomp($input);
# .1.3.6.1.2.1.25.2
# period, one or more digits, repeated one or more times
# $input =~ s/^([.\d+]+)$/$1/g;
# print "substituted text is >$1<\n";

# HH:MM ???
#my $regex = '\d\d:\d\d \(\d+?\+?\d+:\d+\)';
# phone number
#my $regex = '\d{3}-\d{3}-\d{4}';
# MS-DOS path/filename
# ^([c-zC-Z]:/[a-zA-Z0-9_.-]+)
# a file path: >./deathmatch/deathtag:<
#my $regex = q(^\.[\/\w]*:$);
my $regex = q(headers:local:archive:size:same);
if ( $regex =~ /$input/ ) {
#if ( $input =~ m#^([c-zC-Z]:/[a-zA-Z0-9_.-]+)# ) {
    print "MATCH; pattern '$regex' matches '$input'\n";
    print "Thanks for playing!!\n";
} else {
    print "Does not match pattern \n";
    print "Regex was: $regex\n";
} # if ( $input =~


