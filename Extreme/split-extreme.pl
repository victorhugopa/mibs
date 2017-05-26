#!/usr/bin/perl
##
## $Id$
## Split monolithic Extreme MIB into multiple files.
## Net-SNMP doesn't handle multiple modules in a single
## file well (it can do it, but you have to create the
## index yourself instead of letting it do it).
##
## This should be usable for splitting other
## items into multile files, but the magic for
## capturing the copyright will be lost.
##

my $filename = undef;
my $copyright = "";
my $between = "";

while (<>) {
        if (/^(.*)-MIB.*BEGIN/) {
                $filename = lc($1);
                open(OUT, ">${filename}.mib");
                if ($filename ne "extreme-base") {
                        print OUT $copyright;
                } else {
                        # remove misleading comment
                        $between =~ s/--\r?\n-- This file contains multiple ASN.1 Module definitions\r?\n--\r?\n\r?\n//m;
                        # Munge RCS commands
                        $between =~ s/^(--.*\$)(\w+:)/$1Extreme_$2/mg;
                        # Find Extreme's version number
                        ($ver) = ($between =~ /(\$Extreme_Id:[^\$]+\$)/);
                        # find copyright
                        ($copyright) = ($between =~ /^(--\s+\*\s+Copyright.*extremenetworks.com\s*\r?)$/msi);
                        # XXX assuming \r\n
                        $copyright = "--/* \r\n-- *\r\n" . $copyright . "\n-- *\r\n";
                        if ($ver) {
                                $copyright .= "-- * extracted from $ver\r\n-- *\r\n";
                        }
                        $copyright .= "-- */\r\n";
                }
                print OUT $between;
                $between = "";
        }
        if (!defined($filename)) {
                $between .= $_;
                next;
        }
        print OUT;
        if (/^\s*END\s*$/) {
                $filename = undef;
        }
}
