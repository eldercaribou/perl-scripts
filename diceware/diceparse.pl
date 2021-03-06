#!/usr/bin/perl

# $Id$
# script that collects numbers and outputs diceware words from a list
# Copyright (c)2006 Brian Manning <elspicyjack at gmail dot com>

#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; version 2 dated June, 1991.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program;  if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111, USA.

# TODO
# - suppress warning for Term::ReadPassword if given a --quiet switch
# - allow for multiple word lists, and add a way to choose a random
# wordlist later on
# - Split things up into different functions
#   - Reading things: wordlists, diceware number lists
#   - Getting random numbers: for use with wordlists, and for the program to
#     use for determine actions for it to take
#   - Presentation: outputting the list of generated numbers to the user

use strict;
use warnings;
# external modules
use Getopt::Long;
use Pod::Usage;
# $noreadpassword get checked below along with --stdin and --ranlength to make
# sure that the script has enough information to run
eval { use Term::ReadPassword; };
my $noreadpassword;
if ( $@ ) {
    $noreadpassword = 1;
}

=pod

=head1 NAME

diceparse.pl

=head1 SYNOPSIS

diceparse.pl [OPTIONS]

General Options

  [-h|--help|--longhelp]   Shows script help information
  [-r|-rl|-ranlength]      Create a passphrase using this many Diceware words
  [-n|-num|-number]        Create this many Diceware passphrases
  [-pr|-perlrandom]        Use Perl's rand() function instead of /dev/random
  [-s|-si|-stdin]          Read Diceware numbers from STDIN
  [-l|-dl|-list|-dicelist] Diceware wordlist to parse for user input.
  [-D|-d|-debug]           Show debugging output during script execution

=head1 OVERVIEW

Reads a Diceware wordlist, then parses user input to generate a password using
the Diceware wordlist previously read.  Diceware wordlists can be obtained from
L<http://world.std.com/~reinhold/diceware.html>.

=head1 MODULES

=over 4

=cut

# variables
my $DEBUG; # are we debugging?
my $perlrandom; # use rand() function instead of reading /dev/random directly
my $ranlength; # how many random numbers to use for creating a diceware word
my $random_dev = q(/dev/random); # random device file to read from
my $req_passphrases = 1; # create this many passphrases
my $dicelist; # path to the word list
my $stdin; # read the numbers from standard input
my %diceware; # wordlist with numbers as the index

    ### begin script ###

    # http://tinyurl.com/a3e62 <- Getopt::Long docs
    # get the command line switches
    my $parser = new Getopt::Long::Parser;
    $parser->configure();
    $parser->getoptions(
        q(h|longhelp|help) => \&ShowHelp,
        q(pr|perlrand|perlrandom) => \$perlrandom,
        q(n|num|number=i) => \$req_passphrases,
        q(r|ranlength|rl=i) => \$ranlength,
        q(randomdev|randev|rd=s) => \$random_dev,
        q(debug|D:i) => \$DEBUG,
        q(l|dl|list|dicelist|wordlist=s) => \$dicelist,
        q(stdin|standardin|si|s) => \$stdin,
    );

    my @program_name = split(/\//,$0);

    if ( defined $noreadpassword &&
        ( ! defined $ranlength && ! defined $stdin) ) {
        die qq(Hmmm, there's a problem.  Term::ReadPassword can't load,\n)
            . q(and -ranlength/-stdin not used);
    }

    # grab the wordlist and parse it
    if ( ! defined $dicelist || ! -r $dicelist ) {
        die qq(ERROR: ) . $program_name[-1] . qq(\n)
            . qq(ERROR: No Diceware wordlist file passed in,\n)
            . qq(ERROR: or Diceware wordlist file not readable;\n)
            . qq(ERROR: Please use ) . $program_name[-1] . qq( --help )
            . qq(for a complete list of options\n);
    } # if ( ! defined $dicelist )

    my $counter = 0;

    open (my $fh_list, q(<),  $dicelist);
    foreach my $line (<$fh_list>) {
         chomp($line);
        if ( $line =~ m/^[1-6]{5}/ ) {
            $counter++;
            my ($dicenum, $diceword) = split(/\t/, $line);
            $diceware{$dicenum} = $diceword;
            #print q(line # ) . sprintf(q(%03d), $counter) . q(:  ')
            print qq(number: $dicenum, word: '$diceword'\n)
                if ( defined $DEBUG && $DEBUG > 0 );
        } # if ( $line =~ m/^[1-6]{5}/ )
    } # foreach
    close $fh_list;
    print qq(Read in $counter Diceware words\n) if ( defined $DEBUG );

    for (my $num_passphrases = 0;
            $num_passphrases < $req_passphrases;
            $num_passphrases++) {
        # if ranlength is not set, read in the dice numbers from the user
        my $dicein = q();
        if ( ! $ranlength ) {
            # maybe $stdin was set instead
            if ( defined $stdin ) {
                while(<STDIN>) {
                    $dicein .= $_;
                }
                $dicein =~ s/\s/ /g;
            } else {
                # nope, grab the numberlist from the user
                print q(Enter in the list of numbers to translate )
                    . qq(into Diceware words:\n);
                $dicein = read_password(q(diceware string: ), 0,0, 1);
            } # if ( defined $stdin )
        } else {
            my @bytes; # list of bytes generated randomly
            if ( defined $perlrandom ) {
                # generate random numbers via perl's built-in rand() function
                srand();
                for ( my $x = 1; $x < $ranlength * 5; $x++ ) {
                    push(@bytes, int(rand(6)) + 1);
                } # for ( my $x = 1; $x > $ranlength * 5; $x++ )
                $dicein = join(q(), @bytes);
            } else {
                # generate random numbers via the system's /dev/random device
                open(my $fh_random, q(<), $random_dev);
                  my $rawrandom;
                while ( length($dicein) < $ranlength * 5 ) {
                    # sysread(FILEHANDLE, $buffer, read_length)
                    sysread($fh_random, $rawrandom, 1);
                    my $byte = sprintf("%u", unpack(q(C), $rawrandom));
                    if ( $byte < 252 ) {
                        # to represent 6 possible values, we can divide 252 by
                        # 6, and add one to the result to get the possibility
                        # of values between 1 and 6 append the value to the
                        # $dicein string
                        $dicein .= int($byte/42) + 1;
                    } # if ( $byte < 252 )
                } # while ($dicein < $ranlength)
                close($fh_random);
            } # if ( defined $perlrand )
        } # if ( ! $ranlength )
        my $dicepassword;
        my $original_in = $dicein;
        # while $dicein has data
        while ( length($dicein) > 4 ) {
            # test a block of 5 bytes
            # substr($scalar, offset, length)
            my $teststring = substr($dicein, 0, 5);
            if ( $teststring =~ m/[1-6]{5}/ ) {
                # we got a match, 5 numbers in a row;
                # add the diceware string to the password
                # FIXME if there is more than one wordlist passed in, choose
                # which wordlist to use here
                $dicepassword .= $diceware{$teststring};
                # and then shorten $dicein by 5 characters
                $dicein = substr($dicein, 5);
            } else {
                # no match, shorten the $dicein string
                $dicein = substr($dicein, 1);
            } # if ( m/[1-6]{5}/ )
        } # while ( length($dicein) > 0 )

        if ( defined $DEBUG ) {
            # pretty print the output
            print qq(input was: $original_in\n);
            print qq(output is: $dicepassword\n);
        } else {
            # just print the generated password
            print qq($dicepassword\n); # . qq(\n);
        }
    }
### end main script ###

sub ShowHelp {
# shows the POD documentation (short or long version)
    my $whichhelp = shift;  # retrieve what help message to show
    shift; # discard the value

    # call pod2usage and have it exit non-zero
    # if if one of the 2 shorthelp options were not used, call longhelp
    if ( ($whichhelp eq q(help))  || ($whichhelp eq q(h)) ) {
        pod2usage(-exitstatus => 1);
    } else {
        pod2usage(-exitstatus => 1, -verbose => 2);
    }

} # sub ShowHelp

=pod

=head1 VERSION

The CVS version of this file is $Revision$. See the top of this file for
the author's version number.

=head1 AUTHOR

Brian Manning

=cut

# vi: set sw=4 ts=4
# end of line
