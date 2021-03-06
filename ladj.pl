#!/usr/bin/perl
use strict;
use warnings;
use autodie;

# This script generates a Wiktionary article (in English) for a Latin
# adjective. It prints the output to a file, launches a terminal
# emulator, prints the contents of the output file, and pipes that printing
# to a pager. You can edit this behavior at line ??.


my $term = 'xterm';
my $geometry = "80x50";
my $pager = $ENV{PAGER} // 'less';

# Directory to save output file(s)
my $dir= $ENV{PWD};

# set this to 1 if you want a unique output filename every time (i.e. you
# want to keep backup copies of the output)
my $uniq_name = 0;
my $out;
my $of_name;

# set this to anything but a null string if you want to conclude a reference
my $ref_string = 'Langenscheidt Pocket Latin Dictionary. Berlin: Langenschedit, 1966.';

# More templates will be added later.
print "Available templates:
1.\tfirst/second declension\n";
print "Choice: ";
#chomp( my $choice = <STDIN> );
my $choice = 1;
unless  ( $choice >= 1 and $choice <= 1 ) {
    print "Invalid choice; exiting.\n";
    exit;
}

&ladj_1_2 if $choice == 1;

sub ladj_1_2 {
    print "Type the stem (use 'a-' for 'ā' etc.): ";
    chomp( my $stem = <STDIN> );
    unless ( $stem =~ /\w+/ ) {
        print "Stem has no word characters; exiting.";
        exit;
    }
    my $stem_mac = &add_mac($stem);
    my $stem_nomac = &de_mac($stem);
    print "Stem with macrons:    $stem_mac\n";
    print "Stem without macrons: $stem_nomac\n";
    print "Is this acceptable? (Y/n) ";
    chomp( my $goahead = <STDIN> );
    if ( $goahead =~ /[y1]/i or $goahead =~ /^\s*$/ ) {
        print "Generating wiki code...\n";
        if ( $uniq_name ) {
            $of_name = "$stem_nomac.txt";
            for ( my $i=0; -e "$dir/$of_name"; $i++ ) {
                $of_name= "$stem_nomac" . "_$i.txt";
            }
            print "file: $of_name\n";
            open($out, ">", $of_name);
        }
        else {
            $of_name = "ladj_out.txt";
            open($out, ">", "$of_name");
        }
# Beginning of Latin section
        print $out "== Latin ==\n";

# Alternative spellings
        print "Add alternative spellings? (y/N) ";
        chomp(my $add_spel = <STDIN>);
        if ( $add_spel =~ /[y1]/i ) {
            print "Enter alternative spellings, separated by <RETURN>,".
                "(or nothing) then CTRL+D:\n";
            my @alt_spel = <>;
                print $out "\n=== Alternative spellings ===\n"; 
                for (@alt_spel) {
                    print $out "$_\n" unless /^\s*$/;
            }
    }

# Etymlogy; more templates will be incorporated eventually
        print "Add a {{term|TARGET|DISPLAY|MEANING|lang=la}} etymology? (y/N) ";
        chomp(my $add_etm = <STDIN>);
        if ( $add_etm =~ /[y1]/i ) {
#                        print "Enter target: ";
#            chomp(my $etm_targ = <STDIN>);
#            print "Enter display: ";
#            chomp(my $etm_disp = <STDIN>);
            print "Enter origin (macrons as before):\n";
            chomp( my $origin = <STDIN> );
            my $etm_targ = &de_mac($origin);
            my $etm_disp = &add_mac($origin);
            print "Enter explanation: ";
            chomp(my $etm_exp = <STDIN>);
            print "Enter anything (or nothing) to add after {{term}}: ";
            chomp(my $etm_ext = <STDIN>);
            print $out "\n=== Etymology ===" .
                       "\nFrom {{term|$etm_targ|$etm_disp|$etm_exp|lang=la}}$etm_ext\n";
        }

# Adjective
        print $out "\n=== Adjective ===\n".
                   "{{la-adj-1&2|$stem_mac" . "us|$stem_nomac" . "a|$stem_mac" . 
                   "a|$stem_nomac" . "um|$stem_mac" . "um}}\n";
        print "Enter the definitions, separated by <RETURN>, followed by CTRL+D:\n";
        my @defs = <>;
        for (@defs) {
            chomp;
            print $out "\n# $_";
        }

# Inflection
        print $out "\n\n==== Inflection ====\n".
        "{{la-decl-1&2|$stem_mac}}\n";

# Reference
        if ($ref_string) {
            print $out "\n=== References ===\n".
                       "* $ref_string\n\n";
        }

# Fin
        print "Finished. The contents of the file will be displayed in a new ".
        "terminal.\n";
        close $out;
        &disp_out;
    }
    else {
        print "Exiting.\n";
        exit;
    }
}

sub disp_out {
    defined(my $pid = fork) or die "Cannot fork: $!";
    unless ($pid) {
        close(STDIN);
        close(STDOUT);
        close(STDERR);
        exec "$term -geometry $geometry -e '$pager $of_name'";
        exit 0;
  }
}

sub add_mac {
    my ( $in_string ) = @_;
    $in_string =~ s/A-/Ā/g;
    $in_string =~ s/a-/ā/g;
    $in_string =~ s/e-/ē/g;
    $in_string =~ s/i-/ī/g;
    $in_string =~ s/o-/ō/g;
    $in_string =~ s/u-/ū/g;
    $in_string =~ s/y-/ȳ/g;
    return $in_string;
}

sub de_mac {
    my ( $in_string ) = @_;
    $in_string =~ s/-//g;
    return $in_string;
}
