#!/usr/local/bin/perl -w
#
# $Id$
#
# Script to precompute nested set and transitive closure optimization
# structures for a named tree or all trees in a BioSQL database with
# the phylodb extension to accelerate hierarchical queries.
#
# (c) Hilmar Lapp, hlapp at gmx.net, 2006.
# (c) William Piel, william.piel at yale.edu, 2006
# 
# You may use, modify, and distribute this software under the same terms
# as Perl itself. See the Perl Artistic License for the terms, for
# example at http://www.perl.com/pub/a/language/misc/Artistic.html.
#
# THIS SOFTWARE COMES AS IS, WITHOUT ANY EXPRESS OR IMPLIED
# WARRANTY. USE AT YOUR OWN RISK.

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

=item -h, --help

print this manual and exit

=back

=head1 Authors

Hilmar Lapp <hlapp at gmx.net>,
William Piel <william.piel at yale.edu>

=cut

# depth-first tree traversal to generate left_id, right_id, and path

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

my $sel_children = prepare_sth(
    $dbh, "SELECT child_node_id FROM edge WHERE parent_node_id = ?");  
my $upd_nestedSet  = prepare_sth(
    $dbh, "UPDATE node SET left_idx = ?, right_idx = ? WHERE node_id = ?");

my $statement = "SELECT name, node_id FROM tree";
$statement .= " WHERE name = ?" if defined($tree);

my $sth = prepare_sth($dbh,$statement);
execute_sth($sth, defined($tree) ? $tree : ());

while(my $row = $sth->fetchrow_arrayref) {
    print "Computing nested set values for tree ".$row->[0]."...\n";
    walktree($row->[1], 0);
    print "Computing transitive closure for tree ".$row->[0]."...\n";
    compute_tc($dbh,$row->[1]);
    print "Done.\n";
    $dbh->commit;
}
$sth->finish;
$dbh->disconnect;

#==============================================================
sub walktree {
	my ($id, $left, $path) = @_;
        my $right = $left+1; # default for leaf

	execute_sth($sel_children,$id);
	
	my @children = ();
	while (my $row = $sel_children->fetchrow_arrayref) {
            push(@children,$row->[0]);
        }
	my $branches = 1;
        foreach my $child (@children) {
            $right = walktree($child, $right);
            $right++;
            $branches++;
	}
	$upd_nestedSet->execute($left, $right, $id);
        return $right;
}

sub compute_tc {
    my $dbh = shift;
    my $tree = shift;
    my $del_sql =
        "DELETE FROM node_path WHERE child_node_id IN ("
        ."SELECT node_id FROM node WHERE tree_id = ?)";
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
    my $sth = prepare_sth($dbh,$del_sql);
    execute_sth($sth, $tree);
    $sth = prepare_sth($dbh,$init_sql);
    execute_sth($sth,$tree);
    $sth = prepare_sth($dbh,$path_sql);
    my $dist = 1;
    my $rv = 1;
    while ($rv > 0) {
        $rv = execute_sth($sth, $tree, $dist);
        $dist++;
    }
}

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
