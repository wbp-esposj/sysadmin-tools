#!/usr/bin/perl -w
###############################################################################
#This script deletes all messages to a user from a Postfix Queue.
#Joe Esposito
#Version 1.0 4/3/13
###############################################################################

use strict;
use Postfix::Parse::Mailq;
use Data::Dumper;
use List::MoreUtils qw(firstidx);
my $email_address = '';
$email_address = shift;
if( "$email_address" eq '' ){
        die "usage: $0 emailaddress";
}
chomp($email_address);
my $debug = 0;
my $mailq_output = `mailq`;
my $entries = Postfix::Parse::Mailq->read_string($mailq_output);

foreach my $entry ( @$entries ) {
        my $idx = firstidx { $_ eq $email_address } @{$entry->{'remaining_rcpts'} };
            print $entry->{'queue_id'} . "\t" . $entry->{'sender'}  . "\t" . $entry->{remaining_rcpts}[$idx] . "\n" if $debug;
                my $queue_id = $entry->{'queue_id'};
                    `postsuper -d $queue_id`;
}
