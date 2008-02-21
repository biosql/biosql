#!/usr/local/bin/perl -w
#
# $Id$
#
# Script to precompute nested set and transitive closure optimization
# structures for a named tree or all trees in a BioSQL database with
# the phylodb extension to accelerate hierarchical queries.
#
# Copyright 2007-2008 Hilmar Lapp
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

tree-precompute.pl

=head1 SYNOPSIS

  Usage: tree-precompute.pl
        --dsn        # the DSN of the database to connect to
        --dbuser     # user name to connect with
        --dbpass     # password to connect with
        --tree       # optional: the name of the tree

=head1 DESCRIPTION

This script precomputes the nested set and transitive closure
optimization structures for a named tree or all trees in a BioSQL
database with the phylodb extension.

The optimization structures are needed to accelerate hierarchical queries.

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

optional: the name of the tree to precompute the optimization
structures for if only a single tree is to be optimized.

=item --namespace

optional: the namespace of the trees for which to precompute the
optimization structures; if used without specifying --tree,
precomputes will be run for all trees in that namespace, and otherwise
only if the named tree is in the given namespace.

=item -h, --help

print this manual and exit

=back

=head1 Authors

Hilmar Lapp <hlapp at gmx.net>

=head1 Contributors

William Piel <william.piel at yale.edu>

=cut

# depth-first tree traversal to generate left_id, right_id, and path

use strict;
use DBI;
use Getopt::Long;
use constant LOG_CHUNK => 10000;

my $usrname = $ENV{DBI_USER};
my $pass = $ENV{DBI_PASSWORD};
my $dsn = $ENV{DBI_DSN};
my $tree;
my $namespace;
my $verbose;

my $ok = GetOptions("d|dsn=s", \$dsn,
                    "u|dbuser=s", \$usrname,
                    "p|dbpass=s", \$pass,
                    "tree=s", \$tree,
                    "namespace=s", \$namespace,
                    "v|verbose", \$verbose,
                    "h|help", sub { system("perldoc $0"); exit(0); });

my $dbh = connect_to_db($dsn, $usrname, $pass);

my $sel_children = prepare_sth(
    $dbh, "SELECT child_node_id FROM edge WHERE parent_node_id = ?");  
my $upd_nestedSet  = prepare_sth(
    $dbh, "UPDATE node SET left_idx = ?, right_idx = ? WHERE node_id = ?");
my $reset_nestedSet = prepare_sth(
    $dbh, "UPDATE node SET left_idx = null, right_idx = null WHERE tree_id =?");

my $sel_trees = 
    "SELECT t.name, t.node_id, t.tree_id FROM tree t, biodatabase db "
    ."WHERE db.biodatabase_id = t.biodatabase_id";
my @bind_params = ();
if (defined($tree)) {
    $sel_trees .= " AND t.name = ?";
    push(@bind_params, $tree);
}
if (defined($namespace)) {
    $sel_trees .= " AND db.name = ?";
    push(@bind_params, $namespace);
}

my $sth = prepare_sth($dbh, $sel_trees);
execute_sth($sth, @bind_params);

while(my $row = $sth->fetchrow_arrayref) {
    my ($tree_name, $root_id, $tree_id) = @$row;
    print STDERR "Computing nested set values for tree $tree_name...\n";
    print STDERR "\tresetting existing values\n" if $verbose;
    # we need to reset the values to null first to prevent any
    # possible unique key violations when updating on a tree that has
    # them already
    execute_sth($reset_nestedSet, $tree_id);
    print STDERR "\tcomputing new values:\n" if $verbose;
    # recursively traverse the tree, depth-first, filling in the value
    # along the way
    handle_progress(0) if $verbose; # initialize
    walktree($root_id);
    handle_progress(LOG_CHUNK, 1) if $verbose; # final tally
    print STDERR "Computing transitive closure for tree $tree_name...\n";
    # transitive closure for the given tree; this will delete existing
    # paths first
    compute_tc($dbh, $tree_id);
    print STDERR "Done.\n";
    $dbh->commit;
}
$sth->finish;
$dbh->disconnect;

#==============================================================
sub walktree {
    my $id = shift;
    my $left = shift || 1;
    my $right = $left+1; # default for leaf

    execute_sth($sel_children,$id);
    
    my @children = ();
    while (my $row = $sel_children->fetchrow_arrayref) {
        push(@children,$row->[0]);
    }
    foreach my $child (@children) {
        $right = walktree($child, $right);
        $right++;
    }
    execute_sth($upd_nestedSet, $left, $right, $id);
    handle_progress(LOG_CHUNK) if $verbose;
    return $right;
}

sub compute_tc {
    my $dbh = shift;
    my $tree = shift;
    my $del_sql =
        "DELETE FROM node_path WHERE child_node_id IN ("
        ."SELECT node_id FROM node WHERE tree_id = ?)";
    my $zero_sql = 
        "INSERT INTO node_path (child_node_id, parent_node_id, distance)"
        ." SELECT n.node_id, n.node_id, 0 FROM node n WHERE n.tree_id = ?";
    my $init_sql = 
        "INSERT INTO node_path (child_node_id, parent_node_id, path, distance)"
        ." SELECT e.child_node_id, e.parent_node_id, n.left_idx, 1"
        ." FROM edge e, node n"
        ." WHERE e.child_node_id = n.node_id AND n.tree_id = ?";
    my $path_sql =
        "INSERT INTO node_path (child_node_id, parent_node_id, path, distance)"
        ." SELECT e.child_node_id, p.parent_node_id,"
        ." p.path||'.'||n.left_idx, p.distance+1"
        ." FROM node_path p, edge e, node n"
        ." WHERE p.child_node_id = e.parent_node_id"
        ." AND n.node_id = e.child_node_id AND n.tree_id = ?"
        ." AND p.distance = ?";
    print STDERR "\tdeleting existing transitive closure\n" if $verbose;
    my $sth = prepare_sth($dbh,$del_sql);
    execute_sth($sth, $tree);
    print STDERR "\tcreating zero length paths\n" if $verbose;
    $sth = prepare_sth($dbh,$zero_sql);
    execute_sth($sth,$tree);
    print STDERR "\tcreating paths with length=1\n" if $verbose;
    $sth = prepare_sth($dbh,$init_sql);
    execute_sth($sth,$tree);
    $sth = prepare_sth($dbh,$path_sql);
    my $dist = 1;
    my $rv = 1;
    while ($rv > 0) {
        print STDERR "\textending paths with length=$dist\n" if $verbose;
        $rv = execute_sth($sth, $tree, $dist);
        $dist++;
    }
}

sub connect_to_db {
    my ($dsn, $user, $pass) = @_;
	
    my $dbh = DBI->connect($dsn, $user, $pass, 
                           {PrintError => 1, 
                            RaiseError => 0,
                            AutoCommit => 0});
    die "DBI connect failed: ".$dbh->errstr unless $dbh;
    
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
    if (!$rv) {
        my $sql = $sth->{Statement};
        my @params = ();
        my $vals = $sth->{ParamValues};
        foreach my $key (sort (keys(%$vals))) {
            push(@params,$vals->{$key});
        }
        die "failed to execute statement: ".$sth->errstr
            ."SQL query: $sql\nParameters: ".join(";",@params)."\n";
    }
    return $rv;
}

sub handle_progress{
    my $chunk = shift;
    my $final = shift;
    our $_time = time() if $chunk == 0;
    our $_n = 0 if $chunk == 0;
    our $_last_n = 0 if $chunk == 0;
    return if $chunk == 0;
    $_n++ unless $final;
    if ($final || (($_n-$chunk) >= $_last_n)) {
	my $elapsed = time() - $_time;
        my $fmt = "\t%d done (in %d secs, %4.1f rows/s)\n";
        printf STDERR $fmt, $_n, $elapsed, ($_n-$_last_n)/($elapsed||1);
        $_time = time() if $elapsed;
        $_last_n = $_n;
    }
}

