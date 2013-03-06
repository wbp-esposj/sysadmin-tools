#!/usr/bin/perl -w

use DBI;
use strict;
use warnings;
use Data::Dumper;

my $newusername = $ARGV[0];
if ($newusername eq "" ){
    die "usage: $0 newusername";
}

#show prints during inserts
my $debug   = 1;

#don't execute SQL inserts;
my $dryrun  = 1;

#database credentials;
my $dbname = "";
my $dbhost = "";
my $dbuser = ""
my $dbpass = "";

#this represents the right side of the user@server in the username
my $jabber_server = "";

#the skiplist is useful for contractors,services, or others who don't need to get autopopulated.
#ie. my @skiplist = qw(nagios contractor1 contractor2);
my @skiplist = qw();

my $dsn = "DBI:mysql:$dbname:$dbhost";
my $dbh = DBI->connect( $dsn,$dbuser,$dbpass) or die "Cant connect to $dsn\n";

#Variables are loaded. Run the query...

my @users;
my $sth = $dbh->prepare ("SELECT username, name FROM ofUser");
$sth->execute or die "unable to execute query\n";
while(my @data = $sth->fetchrow_array()){
    my %user;
    $user{'username'} = $data[0];   
    $user{'name'} = $data[1];   
    push (@users, \%user);
}

# Add this user to all existing user's rosters
foreach my $user (@users){
    $sth = $dbh->prepare ("SELECT rosterID FROM ofRoster WHERE username = ? AND jid = ? ORDER BY rosterID DESC LIMIT 1");
    $sth->execute($newusername, $user->{'username'} . "\@$jabber_server") or die "unable to execute query\n";
    my $skip = 0;
    while(my @data = $sth->fetchrow_array()){
        $skip = 1;
    }
    if ($skip){
        next;
    }
    #Exclusions See down below as well!
    if (/$user->{'username'}/ ~~ @skiplist ){
        next;
    }
    $sth = $dbh->prepare ("SELECT rosterID FROM ofRoster ORDER BY rosterID DESC LIMIT 1");
    $sth->execute or die "unable to execute query\n";
    my $insert_id;
    while(my @data = $sth->fetchrow_array()){
        $insert_id = $data[0] + 1;
    }
    if( $debug ) {
        print "Going to insert user $newusername into " . $user->{'name'} . " (" . $user->{'username'} . "\@$jabber_server)'s roster\n";
    }
    my $insert_handle = $dbh->prepare_cached("INSERT INTO ofRoster (RosterID,username,jid,sub,ask,recv,nick) VALUES (?, ?, ?,'3','-1','-1',?)");
    unless( $dryrun ){
        $insert_handle->execute($insert_id, $newusername, $user->{'username'} . "\@$jabber_server", $user->{'name'});
    }
}

# Add all users to this user's roster
foreach my $user (@users){
        $sth = $dbh->prepare ("SELECT rosterID FROM ofRoster WHERE username = ? AND jid = ? ORDER BY rosterID DESC LIMIT 1");
        $sth->execute($user->{'username'}, $newusername . "\@$jabber_server") or die "unable to execute query\n";
        my $skip = 0;
        while(my @data = $sth->fetchrow_array()){
                $skip = 1;
        }
        if ($skip){
            next;
        }
#Exclusions
    if (/$user->{'username'}/ ~~ @skiplist ){next;}
        $sth = $dbh->prepare ("SELECT rosterID FROM ofRoster ORDER BY rosterID DESC LIMIT 1");
        $sth->execute or die "unable to execute query\n";
        my $insert_id;
        while(my @data = $sth->fetchrow_array()){
                $insert_id = $data[0] + 1;
        }
        # Get actual name of new user
        my $newname;
        my $sth = $dbh->prepare ("SELECT name FROM ofUser WHERE username = ?");
        $sth->execute($newusername) or die "unable to execute query\n";
        while(my @data = $sth->fetchrow_array()){
            $newname = $data[0];
        }
        if(!defined($newname)){
            $newname = $newusername;
        }

        if( $debug ){
            print "Going to insert user " . $user->{'username'}  . "  into $newname ($newusername\@$jabber_server)'s roster\n";
        }
        my $insert_handle = $dbh->prepare_cached("INSERT INTO ofRoster (RosterID,username,jid,sub,ask,recv,nick) VALUES (?, ?, ?,'3','-1','-1',?)");
        unless( $dryrun ){
            $insert_handle->execute($insert_id, $user->{'username'}, $newusername . "\@$jabber_server", $newname);
        }
}
