#!/usr/local/lib/perl

use Getopt::Long;

my $host = "localhost";
my $sqlname = "bioperl";
my $dbuser = "root";
my $dbpass = undef;
my $sqldir;

&GetOptions( 'host:s' => \$host,
	     'sqldb:s'  => \$sqlname,
	     'dbuser:s' => \$dbuser,
	     'dbpass:s' => \$dbpass,
	     'sqldir:s' => \$sqldir,
	     );

$sqldir = $sqldir || "./sql";
-d $sqldir or die "need to be in bioperl-db dir";
mysqlrun("drop database $sqlname");
mysqlrun("create database $sqlname");
unixrun("cat sql/basicseqdb-mysql.sql | mysql -h $host $sqlname");

sub unixrun {
    my $cmd = shift;
    print "RUNNING:$cmd\n";
    system($cmd) && warn("PROBLEM!\n");
}
sub mysqlrun {
    my $sql = shift;
    unixrun("echo '$sql' | mysql -h $host @_");
}
