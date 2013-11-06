#! /usr/bin/perl 
# $Id: check_mpt.pl,v 0.1 2006/05/16 15:17:49 Exp $

# check_mpt.pl Copyright (C) 2006 Claudio Messineo <claudio@zero.it>
#
#
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# you should have received a copy of the GNU General Public License
# along with this program (or with Nagios);  if not, write to the
# Free Software Foundation, Inc., 59 Temple Place - Suite 330,
# Boston, MA 02111-1307, USA

use strict;
use English;
use Getopt::Long;
use vars qw($PROGNAME);
use lib "/usr/local/nagios/libexec" ;
use utils qw (%ERRORS &print_revision &support);

sub print_help ();
sub print_usage ();

my ($opt_h, $opt_V, $opt_c);
my ($result, $message, $mpt_path, $num_raid, $enabled );

$PROGNAME="check_mpt";
$mpt_path="sudo /usr/sbin/mpt-status";
$num_raid=2;
$enabled=1;

Getopt::Long::Configure('bundling');
GetOptions(
	"V"	=> \$opt_V, "version"		=> \$opt_V,
	"h"	=> \$opt_h, "help"		=> \$opt_h,
	"c=n"	=> \$opt_c, "num_raid=n"	=> \$opt_c
	);

if ($opt_V) {
	print_revision($PROGNAME, '$Id: check_mpt.pl,v 0.1 2006/05/16 15:17:49 Exp $');
	exit $ERRORS{'OK'};
}

if ($opt_h) {
	print_help();
	exit $ERRORS{'OK'};
}

sub print_usage () {
	print "Usage:\n";
	print "  $PROGNAME <-c numraid>\n";
	print "  $PROGNAME [-h | --help]\n";
	print "  $PROGNAME [-V | --version]\n";
}

sub print_help () {
	print_revision($PROGNAME, '$Id: check_mpt.pl,v 0.1 2006/05/16 15:17:49 Exp $');
	print "Copyright (c) 2006 Claudio Messineo claudio\@__no__spam__zero.it (s/__no__spam__//)\n\n";
	print_usage();
	print "\n";
	support();
}

if($opt_c =~ /^([0-9]+)$/){
    $num_raid = $1;
}


if ( ! open( MPT_STAT, " $mpt_path | " ) ) {
           print "ERROR: could not open $mpt_path  \n";
           exit $ERRORS{'UNKNOWN'};
           }
else {
        while (<MPT_STAT>) {
			if ( $_ =~ m/ENABLED/ ) {
				$enabled--;
			}
			if ( $_ =~ m/ONLINE/ ) {
				$num_raid--;
			}
                        next;
                }
	if (($num_raid==0) and ($enabled==0)) {
		print "Mpt-status OK\n";
		exit $ERRORS{'OK'};
	}
	else {
		print "Mpt-status Alert\n";
		exit $ERRORS{'WARNING'};
	}
}