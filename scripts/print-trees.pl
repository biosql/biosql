#!/usr/local/bin/perl -w
#
# $Id$
#
# Script to print a named tree or all trees in a BioSQL database with
# the phylodb extension.
#
# Copyright 2006-2007 Hilmar Lapp, hlapp at gmx.net, 2006.
# Copyright 2006-2007 William Piel, william.piel at yale.edu, 2006
# 
#  This file is part of BioSQL.
#
#  BioSQL is free software: you can redistribute it and/or modify it
#  under the terms of the GNU Lesser General Public License as
#  published by the Free Software Foundation, either version 3 of the
#  License, or (at your option) any later version.
#
#  BioSQL is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public License
#  along with BioSQL. If not, see <http://www.gnu.org/licenses/>.

=head1 NAME

print-trees.pl

=head1 SYNOPSIS

  Usage: print-trees.pl
        --dsn        # the DSN of the database to connect to
        --dbuser     # user name to connect with
        --dbpass     # password to connect with
        --tree       # optional: the name of the tree to print

=head1 DESCRIPTION

This script prints a named or all trees found in the BioSQL instance
specified by the given DSN.

=head1 ARGUMENTS

=over

=item -d, --dsn

the DSN of the database to connect to; default is the value in the
environment variable DBI_DSN.

=item -u, --dbuser

user name to connect with; default is the value in the environment
variable DBI_USER.

=item -p, --dbpass

password to connect with; default is the value in the environment
variable DBI_PASSWORD.

=item --tree

optional: the name of the tree to print if only one tree is to be printed.

=item -h, --help

print this manual and exit

=back

=head1 Authors

Hilmar Lapp <hlapp at gmx.net>

=head1 Contributors

William Piel <william.piel at yale.edu>

=cut

use strict;
use DBI;
use Getopt::Long;

my $usrname = $ENV{DBI_USER};
my $pass = $ENV{DBI_PASSWORD};
my $dsn = $ENV{DBI_DSN};
my $tree;

my $ok = GetOptions("d|dsn=s", \$dsn,
                    "u|dbuser=s", \$usrname,
                    "p|dbpass=s", \$pass,
                    "tree=s", \$tree,
                    "h|help", sub { system("perldoc $0"); exit(0); });

my $dbh = connect_to_db($dsn, $usrname, $pass);

print_trees($dbh, $tree);

$dbh->disconnect;

sub connect_to_db {
  my ($cstr) = @_;
  return ConnectToMysql(@_) if $cstr =~ /:mysql:/i;
  return ConnectToPg(@_) if $cstr =~ /:pg:/i;
  die "can't understand driver in connection string: $cstr\n";
}

# Connect to MySQL using DBI
#==============================================================
sub ConnectToMySQL {

	my ($cstr, $user, $pass) = @_;
	
	my $dbh = DBI->connect($cstr, $user, $pass, {PrintError => 0, RaiseError => 1});
	$dbh || &error("DBI connect failed : ",$dbh->errstr);

	return($dbh);
}

# Connect to Pg using DBI
#==============================================================
sub ConnectToPg {

	my ($cstr, $user, $pass) = @_;
	
	my $dbh = DBI->connect($cstr, $user, $pass, 
                               {PrintError => 0, 
                                RaiseError => 1,
                                AutoCommit => 0});
	$dbh || &error("DBI connect failed : ",$dbh->errstr);

	return($dbh);
}

sub prepare_sth {
    my $dbh = shift;
    my $sth = $dbh->prepare(@_);
    die "failed to prepare statement '$_[0]': ".$dbh->errstr."\n" unless $sth;
    return $sth;
}

sub execute_sth {
    my $sth = shift;
    my $rv = $sth->execute(@_);
    die "failed to execute statement: ".$sth->errstr."\n" unless $rv;
    return $rv;
}

sub print_trees {
    my $dbh = shift;
    my @trees = @_;
    my $sel_trees = prepare_sth($dbh, "SELECT name FROM tree");
    my $sel_root = prepare_sth($dbh, 
                               "SELECT n.node_id, n.label FROM tree t, node n "
                               ."WHERE t.node_id = n.node_id AND t.name = ?");
    my $sel_chld = prepare_sth($dbh, 
                               "SELECT n.node_id, n.label, e.edge_id "
                               ."FROM node n, edge e "
                               ."WHERE n.node_id = e.child_node_id "
                               ."AND e.parent_node_id = ?");
    my $sel_attrs = prepare_sth($dbh,
                                "SELECT t.name, eav.value "
                                ."FROM term t, edge_attribute_value eav "
                                ."WHERE t.term_id = eav.term_id "
                                ."AND eav.edge_id = ?");
    if (! (@trees && $trees[0])) {
        @trees = ();
        execute_sth($sel_trees);
        while (my $row = $sel_trees->fetchrow_arrayref) {
            push(@trees,$row->[0]);
        }
    }
    foreach my $tree (@trees) {
        execute_sth($sel_root, $tree);
        my $root = $sel_root->fetchrow_arrayref;
        if ($root) {
            print ">$tree ";
        } else {
            print STDERR "no tree with name '$tree'\n";
            next;
        }
        print_tree_nodes($sel_chld,$root,$sel_attrs);
        print "\n";
    }
}

sub print_tree_nodes {
    my $sel_chld_sth = shift;
    my $root = shift;
    my $sel_attrs = shift;
    my @children = ();
    execute_sth($sel_chld_sth,$root->[0]);
    while (my $child = $sel_chld_sth->fetchrow_arrayref) {
        push(@children, [@$child]);
    }
    print "(" if @children;
    for(my $i = 0; $i < @children; $i++) {
        print "," unless $i == 0;
        print_tree_nodes($sel_chld_sth, $children[$i], $sel_attrs);
    }
    print ")" if @children;
    print $root->[1] if $root->[1];
    if (@$root > 2) {
        execute_sth($sel_attrs,$root->[2]);
        my %attrs = ();
        while (my $row = $sel_attrs->fetchrow_arrayref) {
            $attrs{$row->[0]} = $row->[1];
        }
        print $attrs{'support value'} if $attrs{'support value'};
        print ":".$attrs{'branch length'} if $attrs{'branch length'};
    }
}
