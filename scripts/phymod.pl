#!/usr/bin/perl -w
#
# $Id$
#
# Copyright 2007-2008 James Estill
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
#
#-----------------------------------------------------------+
#                                                           |
# phymod.pl - modify trees in PhyloDB                       |
#                                                           |
#-----------------------------------------------------------+
#                                                           |
# CONTACT: JamesEstill_at_gmail.com                         |
# STARTED: 07/06/2007                                       |
# UPDATED: 09/20/2007                                       |
#                                                           |
# DESCRIPTION:                                              | 
#  Modify trees in the PhyloDb database.                    |
#  Includes: branch removal                                 |
#                                                           |
# LICENSE:                                                  |
#  GNU Lesser Public License                                |
#  http://www.gnu.org/licenses/lgpl.html                    |  
#                                                           |
#-----------------------------------------------------------+
# TO DO:
# - PGSQL support
# - Add some safety scissors ... curently the cut command completely
#   deletes the records, it would be good to move these to a temporary
#   table so that they could be recovered with and Undelete
# - Copy and paste command
#   Simply move edge and run phyopt on the two trees affected
# - Cut and paste command
#   If temp table working, then move these over, 
 
print "Staring $0 ..\n";

#Package this as phytools for now
package PhyloDB;

#-----------------------------+
# INCLUDES                    |
#-----------------------------+
use strict;
use DBI;
use Getopt::Long;
use Bio::TreeIO;                # creates Bio::Tree::TreeI objects
use Bio::Tree::TreeI;
use Bio::Tree::Node;
use Bio::Tree::NodeI;

#-----------------------------+
# VARIABLE SCOPE              |
#-----------------------------+
my $ver = "Dev: 07/20/2007";   # The current version number

my $usrname = $ENV{DBI_USER};  # User name to connect to database
my $pass = $ENV{DBI_PASSWORD}; # Password to connect to database
my $dsn = $ENV{DBI_DSN};       # DSN for database connection
my $infile;                    # Full path to infile for adding
                               # tree to the database. 
my $format = 'newick';         # Data format used in infile
my $db;                        # Database name (ie. biosql)
my $host;                      # Database host (ie. localhost)
my $driver;                    # Database driver (ie. mysql)
my $help = 0;                  # Display help
my $quiet = 0;                 # Run the program in quiet mode
                               # will not prompt for command line options
my $tree_name;                 # The name of the tree
                               # For files with multiple trees, this may
                               # be used as a base name to name the trees with
my @trees = ();                # Array holding the names of the trees that will
                               # be exported
my $statement;                 # Var to hold SQL statement string
my $sth;                       # Statement handle for SQL statement object


#our $tree;                      # Tree object, this has to be a package
#my $tree = new Bio::Tree::Tree() ||
#	die "Can not create the tree object.\n";

my $parent_node;                # The parent node that will serve as the
                                # clipping point for exporting a 
                                # new tree
my $parent_edge;                # A parend edge that will serve as the 
                                # clipping point for exporing a tree
                                # May not implement this ..
our $tree;                      # Tree object, this has to be a package
#                               # level variable since we will modify this
                                # in a subfunction below.
                                # This is my first attempt to work with
                                # a package level var.
my $cut_node;                   # Node that will be source of cut
my $copy_node;                  # Node that will be source of copy
my $paste_node;                 # Node that will be source of paste
                                # for the tree tree_name
my $oper;                       # The operation that is being requested
                                # -delete, cut, copy

# BOOLEANS
my $show_help = 0;             # Display help
my $show_man = 0;              # Show the man page via perldoc
my $show_usage = 0;            # Show the basic usage for the program
my $show_version = 0;          # Show the program version
my $verbose = 0;               # Run program in chatty mode

#-----------------------------+
# USAGE                       |
#-----------------------------+
# TO DO: Add full set of usage statements
#my $usage = "\nphymod.pl -h for help\n";

#-----------------------------+
# COMMAND LINE OPTIONS        |
#-----------------------------+
my $ok = GetOptions(
		    "d|dsn=s"       => \$dsn,
                    "u|dbuser=s"    => \$usrname,
		    "i|infile=s"    => \$infile,
                    "f|format=s"    => \$format,
                    "p|dbpass=s"    => \$pass,
		    "driver=s"      => \$driver,
		    "dbname=s"      => \$db,
		    "host=s"        => \$host,
		    "t|tree=s"      => \$tree_name,
		    "q|quiet"       => \$quiet,
		    "x|cut-node=s"  => \$cut_node,
                    "c|copy-node=s" => \$copy_node,
                    "v|paste-node=s"=> \$paste_node,
		    # BOOLEANS
		    "verbose"       => \$verbose,
		    "version"       => \$show_version,
		    "man"           => \$show_man,
		    "usage"         => \$show_usage,
		    "h|help"        => \$show_help);


# Exit if format string is not recognized
#print "Requested format:$format\n";
$format = &in_format_check($format);



## SHOW HELP
#if($show_help || (!$ok)) {
#    system("perldoc $0");
#    exit($ok ? 0 : 2);
#}


#-----------------------------+
# SHOW REQUESTED HELP         |
#-----------------------------+

if ($show_usage) {
    print_help("");
}

if ($show_help || (!$ok) ) {
    print_help("full");
}

if ($show_version) {
    print "\n$0:\nVersion: $ver\n\n";
    exit;
}

if ($show_man) {
    # User perldoc to generate the man documentation.
    system("perldoc $0");
    exit($ok ? 0 : 2);
}

print "Staring $0 ..\n" if $verbose; 

# A full dsn can be passed at the command line or components
# can be put together
unless ($dsn) {
    # Set default values if none given at command line
    $db = "biosql" unless $db; 
    $host = "localhost" unless $host;
    $driver = "mysql" unless $driver;
    $dsn = "DBI:$driver:database=$db;host=$host";
} else {
    
    # We need to parse the database name, driver etc from the dsn string
    # in the form of DBI:$driver:database=$db;host=$host
    # Other dsn strings will not be parsed properly
    # Split commands are often faster then regular expressions
    # However, a regexp may offer a more stable parse then splits do
    my ($cruft, $prefix, $suffix, $predb, $prehost); 
    ($prefix, $driver, $suffix) = split(/:/,$dsn);
    ($predb, $prehost) = split(/;/, $suffix);
    ($cruft, $db) = split(/=/,$predb);
    ($cruft, $host) = split(/=/,$prehost);

    # Print for debug
    print "\tDSN:\t$dsn\n";
    print "\tPRE:\t$prefix\n";
    print "\tDRIVER:\t$driver\n";
    print "\tSUF:\t$suffix\n";
    print "\tDB:\t$db\n";
    print "\tHOST:\t$host\n";
    # The following not required
    print "\tTREES\t$tree_name\n" if $tree_name;
}

#-----------------------------+
# DETERMINE THE REQUESTED     |
# OPERATION                   |
#-----------------------------+
# Exit on nonsense combinations
if ($copy_node && $cut_node) {
    print "\a";
    print "\nERROR: It is not possible to simultaneously cut and copy.\n\n";
    exit;    
}
elsif ($cut_node && !$paste_node) {
    $oper = "delete";
}
elsif ($paste_node && $cut_node) {
    $oper = "cutnode";
}
elsif ($paste_node && $copy_node) {
    $oper = "copynode";
}else{
    print "\a";
    print "\nERROR: I don't understand your request.\n";
    print_help("");
    exit;
}

#print "Requested operation is $oper\n";
#exit;

#-----------------------------+
# GET DB PASSWORD             |
#-----------------------------+
# This prevents the password from being globally visible
# I don't know what happens with this in anything but Linux
# so I may need to get rid of this or modify it 
# if it crashes on other OS's

unless ($pass) {
    print "\nEnter password for the user $usrname\n";
    system('stty', '-echo') == 0 or die "can't turn off echo: $?";
    $pass = <STDIN>;
    system('stty', 'echo') == 0 or die "can't turn on echo: $?";
    chomp $pass;
}


#-----------------------------+
# CONNECT TO THE DATABASE     |
#-----------------------------+
# Commented out while I work on fetching tree structure
my $dbh = &connect_to_db($dsn, $usrname, $pass);

#-----------------------------+
# EXIT HANDLER                |
#-----------------------------+
#END {
#    &end_work($dbh);
#}

#-----------------------------+
# PREPARE SQL STATEMENTS      |
#-----------------------------+


if ($oper =~ "delete") {

#-----------------------------+
# DELETE                      |
#-----------------------------+

    # Warn the user about what would be deleted from
    # the database
    # Currently serving as a test that this is working
    my $num_del = count_deleted_data_2($dbh, $cut_node);
    
    # Check with user before deleting
    if ($num_del > 0) {
	my $del_check = user_feedback("Do you want to delete these records");
	
	if ($del_check =~ "Y") {
	    # DELETE THE RECORDS
	    print "These records will be deleted.\n";

	    delete_data_2($dbh, $cut_node);
	} else {
	    print "No records will be deleted.\n";
	    exit;
	} # End of check for delete
	
    } # End of if number to delete is gt zero

} # End of opeation is delete


# There will be a number of possible operations being requested

# End of program
print "\n$0 has finished.\n";

exit;

#-----------------------------------------------------------+
# SUBFUNCTIONS                                              |
#-----------------------------------------------------------+

#sub fetch_

sub count_deleted_data_2 {
# Give the user info on the data that would be deleted
# This allows to show warning before proceeding

    my ($dbh, $del_node_id) = @_;
    my ($result, $cur, @row);
    my $count_total_del = 0;         # Total number of records deleted

    #-----------------------------+
    # DETERMINE TREE NAME         |
    #-----------------------------+
    my $sql_tree_name = "SELECT tree.name FROM tree".
	" RIGHT JOIN node".
	" ON node.tree_id = tree.tree_id".
	" WHERE node.node_id = '$del_node_id'";
    $cur = $dbh->prepare($sql_tree_name);
    $cur->execute();
    @row=$cur->fetchrow;
    #my $res_tree_name=$row[0];
    my $res_tree_name=$row[0] ||
	die "No tree name found for node: $del_node_id\n".
	"This node may not exist in the database.\n";
    $cur->finish();

    #-----------------------------+
    # DETERMINE TREE ID           |
    #-----------------------------+
    my $sql_tree_id = "SELECT tree.tree_id FROM tree".
	" RIGHT JOIN node".
	" ON node.tree_id = tree.tree_id".
	" WHERE node.node_id = '$del_node_id'";
    $cur = $dbh->prepare($sql_tree_id);
    $cur->execute();
    @row=$cur->fetchrow;
    my $res_tree_id=$row[0] ||
	die "No tree id found for node: $del_node_id\n".
	"This node may not exist in the database.\n";
    $cur->finish();

    #-----------------------------+
    # SQL FOR NODE ID             |
    #-----------------------------+
    my $sql_in_nodes = "SELECT n1.node_id".
	" FROM node AS n1, node AS n2".
	" WHERE n1.left_idx BETWEEN n2.left_idx AND n2.right_idx". 
	" AND n2.node_id='$del_node_id'".
	" AND n2.tree_id='$res_tree_id'";

    #-----------------------------+
    # TABLE: count_node_path      |
    #-----------------------------+
    my $sql_count_node_path = 
	"SELECT COUNT(*) FROM node_path".
	" WHERE parent_node_id IN".
	" (".$sql_in_nodes.")";
    $cur = $dbh->prepare($sql_count_node_path);
    $cur->execute();
    @row=$cur->fetchrow;
    my $res_count_node_path=$row[0];
    $cur->finish();
    $count_total_del = $count_total_del + $res_count_node_path;

    #-----------------------------+
    # TABLE: node_attribute_value |
    #-----------------------------+
    my $sql_count_node_attribute =
	"SELECT COUNT(*) FROM node_attribute_value". 
	" WHERE node_id IN".
	" (".$sql_in_nodes." )";
    $cur = $dbh->prepare($sql_count_node_attribute);
    $cur->execute();
    @row=$cur->fetchrow;
    my $res_count_node_attribute=$row[0];
    $cur->finish();
    $count_total_del = $count_total_del + $res_count_node_attribute;


    #-----------------------------+
    # TABLE: node                 |
    #-----------------------------+
    my $sql_count_node =  "SELECT COUNT(*)".
	" FROM node AS n1, node AS n2".
	" WHERE n1.left_idx BETWEEN n2.left_idx AND n2.right_idx". 
	" AND n2.node_id='$del_node_id'".
	" AND n2.tree_id='$res_tree_id'";
    $cur = $dbh->prepare($sql_count_node);
    $cur->execute();
    @row=$cur->fetchrow;
    my $res_count_node=$row[0];
    $cur->finish();
    $count_total_del = $count_total_del + $res_count_node;

    #-----------------------------+
    # TABLE: edge                 |
    #-----------------------------+
    my $sql_count_edge = "SELECT COUNT(*) from edge". 
	" WHERE child_node_id IN".
	" (".$sql_in_nodes." )";
    $cur = $dbh->prepare($sql_count_edge);
    $cur->execute();
    @row=$cur->fetchrow;
    my $res_count_edge=$row[0];
    $cur->finish();
    $count_total_del = $count_total_del + $res_count_edge;
    
    #-----------------------------+
    # TABLE: edge_attribute_value |
    #-----------------------------+
    # This will remove edge_attribute_values 
    # where the nodes are 
    my $sql_count_edge_attribute = "SELECT COUNT(*) FROM edge_attribute_value".
	" WHERE edge_id IN".
	" (SELECT edge_id FROM edge".
	"   WHERE child_node_id IN".
	"   (".$sql_in_nodes." )".
	" )";
    $cur = $dbh->prepare( $sql_count_edge_attribute );
    $cur->execute();
    @row=$cur->fetchrow;
    my $res_count_edge_attribute=$row[0];
    $cur->finish();
    $count_total_del = $count_total_del + $res_count_edge_attribute;

    #-----------------------------+
    # SHOW COUNTS IF ANY EXIST    |
    #-----------------------------+
    # Warn the user if any records would be deleted
    if ($count_total_del > 0) {
	print "\nThe following data will be deleted:\n";
	print "\tTREE: $res_tree_name\n" 
	    unless !$res_tree_name;
	print "\tnode_path ( $res_count_node_path records )\n"
	    unless $res_count_node_path == 0;
	print "\tnode_attribute_value ( $res_count_node_attribute records )\n"
	    unless $res_count_node_attribute == 0;
	print "\tnode ( $res_count_node records)\n"
	    unless $res_count_node == 0;
	print "\tedge ( $res_count_edge records)\n"
	    unless $res_count_edge == 0;
	print "\tedge_attribute_value ( $res_count_edge_attribute records )\n"
	    unless $res_count_edge_attribute == 0;
	} 
    else {
	# If no data would actually be cut with this query
	# then exit the program
	print "No data would be deleted with this query\n";
	exit;
    }
    
    return "$count_total_del";
    
} # End of count_deleted_data subfunction

sub count_deleted_data {
# Give the user info on the data that would be deleted
# This allows to show warning before proceeding

    my ($dbh, $del_node_id) = @_;
    my ($result, $cur, @row);
    my $count_total_del = 0;         # Total number of records deleted

    #-----------------------------+
    # DETERMINE TREE NAME         |
    #-----------------------------+
    my $sql_tree_name = "SELECT tree.name FROM tree".
	" RIGHT JOIN node".
	" ON node.tree_id = tree.tree_id".
	" WHERE node.node_id = '$del_node_id'";
    $cur = $dbh->prepare($sql_tree_name);
    $cur->execute();
    @row=$cur->fetchrow;
    my $res_tree_name=$row[0];
    $cur->finish();

    #-----------------------------+
    # TABLE: count_node_path      |
    #-----------------------------+
    my $sql_count_node_path = 
	"SELECT COUNT(*) FROM node_path".
	" WHERE parent_node_id IN".
	" (".
	"  SELECT pt.node_id ".
	"  FROM node_path p, edge e, node pt, node ch ".
	"  WHERE e.child_node_id = p.child_node_id".
	"  AND pt.node_id = e.parent_node_id".
	"  AND ch.node_id = e.child_node_id".
	"  AND p.parent_node_id = '$del_node_id'".
	")";
    $cur = $dbh->prepare($sql_count_node_path);
    $cur->execute();
    @row=$cur->fetchrow;
    my $res_count_node_path=$row[0];
    $cur->finish();
    $count_total_del = $count_total_del + $res_count_node_path;

    #-----------------------------+
    # TABLE: node_attribute_value |
    #-----------------------------+
    my $sql_count_node_attribute =
	"SELECT COUNT(*) FROM node_attribute_value". 
	" WHERE node_id IN".
	" (".
	"  SELECT pt.node_id". 
	"  FROM node_path p, edge e, node pt, node ch". 
	"  WHERE e.child_node_id = p.child_node_id".
	"  AND pt.node_id = e.parent_node_id".
	"  AND ch.node_id = e.child_node_id".
	"  AND p.parent_node_id = '$del_node_id'".
	" )";
    $cur = $dbh->prepare($sql_count_node_attribute);
    $cur->execute();
    @row=$cur->fetchrow;
    my $res_count_node_attribute=$row[0];
    $cur->finish();
    $count_total_del = $count_total_del + $res_count_node_attribute;


    #-----------------------------+
    # TABLE: node                 |
    #-----------------------------+
    my $sql_count_node = "SELECT COUNT(*) FROM node". 
	" WHERE node_id IN".
	" (".
	"  SELECT pt.node_id".
	"  FROM node_path p, edge e, node pt, node ch". 
	"  WHERE e.child_node_id = p.child_node_id".
	"  AND pt.node_id = e.parent_node_id".
	"  AND ch.node_id = e.child_node_id".
	"  AND p.parent_node_id = '$del_node_id'".
	" )";
    $cur = $dbh->prepare($sql_count_node);
    $cur->execute();
    @row=$cur->fetchrow;
    my $res_count_node=$row[0];
    $cur->finish();
    $count_total_del = $count_total_del + $res_count_node;


    #-----------------------------+
    # TABLE: edge                 |
    #-----------------------------+
    my $sql_count_edge = "SELECT COUNT(*) from edge". 
	" WHERE edge_id IN".
	" (".
	"  SELECT e.edge_id".
	"  FROM node_path p, edge e, node pt, node ch". 
	"  WHERE e.child_node_id = p.child_node_id".
	"  AND pt.node_id = e.parent_node_id".
	" AND ch.node_id = e.child_node_id".
	" AND p.parent_node_id = '$del_node_id'".
	" )";
    $cur = $dbh->prepare($sql_count_edge);
    $cur->execute();
    @row=$cur->fetchrow;
    my $res_count_edge=$row[0];
    $cur->finish();
    $count_total_del = $count_total_del + $res_count_edge;
    
    #-----------------------------+
    # TABLE: edge_attribute_value |
    #-----------------------------+
    my $sql_count_edge_attribute = "SELECT COUNT(*) FROM edge_attribute_value".
	" WHERE edge_id IN".
	" (".
	"  SELECT e.edge_id".
	"  FROM node_path p, edge e, node pt, node ch".
	"  WHERE e.child_node_id = p.child_node_id".
	"  AND pt.node_id = e.parent_node_id".
	"  AND ch.node_id = e.child_node_id".
	"  AND p.parent_node_id = '$del_node_id'".
	" )";
    $cur = $dbh->prepare( $sql_count_edge_attribute );
    $cur->execute();
    @row=$cur->fetchrow;
    my $res_count_edge_attribute=$row[0];
    $cur->finish();
    $count_total_del = $count_total_del + $res_count_edge_attribute;

    #-----------------------------+
    # SHOW COUNTS IF ANY EXIST    |
    #-----------------------------+
    # Warn the user if any records would be deleted
    if ($count_total_del > 0) {
	print "\nThe following data will be deleted:\n";
	print "\tTREE: $res_tree_name\n" 
	    unless !$res_tree_name;
	print "\tnode_path ( $res_count_node_path records )\n"
	    unless $res_count_node_path == 0;
	print "\tnode_attribute_value ( $res_count_node_attribute records )\n"
	    unless $res_count_node_attribute == 0;
	print "\tnode ( $res_count_node records)\n"
	    unless $res_count_node == 0;
	print "\tedge ( $res_count_edge records)\n"
	    unless $res_count_edge == 0;
	print "\tedge_attribute_value ( $res_count_edge_attribute records )\n"
	    unless $res_count_edge_attribute == 0;
	} 
    else {
	# If no data would actually be cut with this query
	# then exit the program
	print "No data would be deleted with this query\n";
	exit;
    }
    
    return "$count_total_del";
    
} # End of count_deleted_data subfunction

sub delete_data_2 {
# Give the user info on the data that would be deleted
# This allows to show warning before proceeding

    my ($dbh, $del_node_id) = @_;
    my ($result, $cur, @row);
    my $count_total_del = 0;         # Total number of records deleted

    #-----------------------------+
    # DETERMINE TREE NAME         |
    #-----------------------------+
    my $sql_tree_name = "SELECT tree.name FROM tree".
	" RIGHT JOIN node".
	" ON node.tree_id = tree.tree_id".
	" WHERE node.node_id = '$del_node_id'";
    $cur = $dbh->prepare($sql_tree_name);
    $cur->execute();
    @row=$cur->fetchrow;
    my $res_tree_name=$row[0];
    $cur->finish();

    #-----------------------------+
    # DETERMINE TREE ID           |
    #-----------------------------+
    my $sql_tree_id = "SELECT tree.tree_id FROM tree".
	" RIGHT JOIN node".
	" ON node.tree_id = tree.tree_id".
	" WHERE node.node_id = '$del_node_id'";
    $cur = $dbh->prepare($sql_tree_id);
    $cur->execute();
    @row=$cur->fetchrow;
    my $res_tree_id=$row[0];
    $cur->finish();

    #-----------------------------+
    # SQL FOR NODE ID             |
    #-----------------------------+
    my $sql_in_nodes = "SELECT n1.node_id".
	" FROM node AS n1, node AS n2".
	" WHERE n1.left_idx BETWEEN n2.left_idx AND n2.right_idx". 
	" AND n2.node_id='$del_node_id'".
	" AND n2.tree_id='$res_tree_id'";


    #-----------------------------+
    # GET LEFT AND RIGHT IDX      |
    #-----------------------------+
    my $sql_get_idx = "SELECT left_idx, right_idx".
	" FROM node".
	" WHERE node_id ='$del_node_id'";
    $cur = $dbh->prepare($sql_get_idx);
    $cur->execute;
    @row=$cur->fetchrow;
    my $left_idx =$row[0];
    my $right_idx=$row[1];
    $cur->finish();
    #print "LEFT:\t$left_idx\n";
    #print "RIGHT:\t$right_idx\n";

    #-----------------------------+
    # TABLE: edge_attribute_value |
    #-----------------------------+
    # This will remove edge_attribute_values 
    # where the nodes are 
    my $sql_count_edge_attribute = "DELETE FROM edge_attribute_value".
	" WHERE edge_id IN".
	" (SELECT edge_id FROM edge".
	"   WHERE child_node_id IN".
	"   (".$sql_in_nodes." )".
	" )";
    $cur = $dbh->prepare( $sql_count_edge_attribute );
    $cur->execute();
    $cur->finish();

    #-----------------------------+
    # TABLE: edge                 |
    #-----------------------------+
    my $sql_count_edge = "DELETE from edge". 
	" WHERE child_node_id IN".
	" (".$sql_in_nodes." )";
    $cur = $dbh->prepare($sql_count_edge);
    $cur->execute();
    $cur->finish();

    #-----------------------------+
    # TABLE: node_path            |
    #-----------------------------+
    my $sql_del_node_path = 
	"DELETE FROM node_path".
	" WHERE parent_node_id IN".
	" (".$sql_in_nodes.")";
    $cur = $dbh->prepare($sql_del_node_path);
    $cur->execute();
    $cur->finish();

    #-----------------------------+
    # TABLE: node_attribute_value |
    #-----------------------------+
    my $sql_del_node_attribute =
	"DELETE FROM node_attribute_value". 
	" WHERE node_id IN".
	" (".$sql_in_nodes." )";
    $cur = $dbh->prepare($sql_del_node_attribute);
    $cur->execute();
    $cur->finish();

    #-----------------------------+
    # TABLE: node                 |
    #-----------------------------+
    # The query below makes use of the $left_idx and 
    # $right_idx values from above
    my $sql_del_node = "DELETE FROM node WHERE".
	" left_idx BETWEEN".
	" $left_idx AND $right_idx";
    $cur = $dbh->prepare($sql_del_node);
    $cur->execute();
    $cur->finish();

    $dbh->commit();
    
} # End of count_deleted_data subfunction




sub delete_data {
# Give the user info on the data that would be deleted
# This allows to show warning before proceeding

    my ($dbh, $del_node_id) = @_;
    my ($result, $cur, @row);

    print "CUTTING $del_node_id\n";


    # GET THE INFO ON THE RECORDS TO DELETE



# THE FOLLOWING DELETE QUERY DOES NOT WORK
#    #-----------------------------+
#    # TABLE: node_path            |
#    #-----------------------------+
#    my $sql_del_node_path = 
#	"DELETE FROM node_path".
#	" WHERE parent_node_id IN".
#	" (".
#	"  SELECT pt.node_id ".
#	"  FROM node_path p, edge e, node pt, node ch ".
#	"  WHERE e.child_node_id = p.child_node_id".
#	"  AND pt.node_id = e.parent_node_id".
#	"  AND ch.node_id = e.child_node_id".
#	"  AND p.parent_node_id = '$del_node_id'".
#	")";
#    $cur = $dbh->prepare($sql_del_node_path);
#    $cur->execute();
#    $cur->finish();
    
    #-----------------------------+
    # TABLE: node_attribute_value |
    #-----------------------------+
    my $sql_del_node_attribute =
	"DELETE FROM node_attribute_value". 
	" WHERE node_id IN".
	" (".
	"  SELECT pt.node_id". 
	"  FROM node_path p, edge e, node pt, node ch". 
	"  WHERE e.child_node_id = p.child_node_id".
	"  AND pt.node_id = e.parent_node_id".
	"  AND ch.node_id = e.child_node_id".
	"  AND p.parent_node_id = '$del_node_id'".
	" )";
    $cur = $dbh->prepare($sql_del_node_attribute);
    $cur->execute();
    $cur->finish();

    #-----------------------------+
    # TABLE: edge_attribute_value |
    #-----------------------------+
    my $sql_del_edge_attribute = "DELETE FROM edge_attribute_value".
	" WHERE edge_id IN".
	" (".
	"  SELECT e.edge_id".
	"  FROM node_path p, edge e, node pt, node ch".
	"  WHERE e.child_node_id = p.child_node_id".
	"  AND pt.node_id = e.parent_node_id".
	"  AND ch.node_id = e.child_node_id".
	"  AND p.parent_node_id = '$del_node_id'".
	" )";
    $cur = $dbh->prepare( $sql_del_edge_attribute );
    $cur->execute();
    $cur->finish();


# The following have the problem where the UPDATE refers
# tables that are referenced by the SELECT query within the WHERE
    #-----------------------------+
    # TABLE: node                 |
    #-----------------------------+
    my $sql_del_node = "DELETE FROM node". 
	" WHERE node_id IN".
	" (".
	"  SELECT pt.node_id".
	"  FROM node_path p, edge e, node pt, node ch". 
	"  WHERE e.child_node_id = p.child_node_id".
	"  AND pt.node_id = e.parent_node_id".
	"  AND ch.node_id = e.child_node_id".
	"  AND p.parent_node_id = '$del_node_id'".
	" )";
    $cur = $dbh->prepare($sql_del_node);
    $cur->execute();
    $cur->finish();

    #-----------------------------+
    # TABLE: edge                 |
    #-----------------------------+
    my $sql_del_edge = "DELETE from edge". 
	" WHERE edge_id IN".
	" (".
	"  SELECT e.edge_id".
	"  FROM node_path p, edge e, node pt, node ch". 
	"  WHERE e.child_node_id = p.child_node_id".
	"  AND pt.node_id = e.parent_node_id".
	"  AND ch.node_id = e.child_node_id".
	"  AND p.parent_node_id = '$del_node_id'".
	" )";
    $cur = $dbh->prepare($sql_del_edge);
    $cur->execute();
    $cur->finish();
    
    # Commint
    $dbh->commit();

} # End of count_deleted_data subfunction


sub load_tree_nodes {

    my $sel_chld_sth = shift;# SQL to select children
    my $root = shift;        # reference to the root
    my $sel_attrs = shift;   # SQL to select attributes

    my @children = ();

    &execute_sth($sel_chld_sth,$root->[0]);

    # Push results to the children array
    while (my $child = $sel_chld_sth->fetchrow_arrayref) {
        push(@children, [@$child]);
    }
    
    # For all of the children, add the descendent node to
    # the tree object and call the load_tree_nodes subfunction
    # recursively for the resulting children nodes
    for(my $i = 0; $i < @children; $i++) {

	# The following used for debug
	#print "\t||".$root->[0]."-->".$children[$i][0]."||\n";

	my ($par_node) = $PhyloDB::tree->find_node( '-id' => $root->[0] );
	
	# Check here that @par_node contains only a single node object
	my $nodeChild = new Bio::Tree::Node( '-id' => $children[$i][0] );
	$par_node->add_Descendent($nodeChild);

	&load_tree_nodes($sel_chld_sth, $children[$i], $sel_attrs);

    }

} # end of load_tree_nodes


sub fetch_node_label {

    # $dbh is the database handle
    # $node_id is the database node_id
    my ($dbh, $node_id) = @_;
    my ($sql, $cur, $result, @row);
    
    $sql = "SELECT label FROM node WHERE node_id = $node_id";
    $cur = $dbh->prepare($sql);
    $cur->execute();
    @row=$cur->fetchrow;
    $result=$row[0];
    $cur->finish();
    #print "\t\t$result\n";
    return $result;

}

sub end_work {
# Copied from load_itis_taxonomy.pl
    
    my ($dbh, $commit) = @_;
    
    # skip if $dbh not set up yet, or isn't an open connection
    return unless $dbh && $dbh->{Active};
    # end the transaction
    my $rv = $commit ? $dbh->commit() : $dbh->rollback();
    if(!$rv) {
	print STDERR ($commit ? "commit " : "rollback ").
	    "failed: ".$dbh->errstr;
    }
    $dbh->disconnect() unless defined($commit);
    
}

sub in_format_check {
    # TODO: Need to convert this to has lookup
    # This will try to make sense of the format string
    # that is being passed at the command line
    my ($In) = @_;  # Format string coming into the subfunction
    my $Out;         # Format string returned from the subfunction
    
    # NEXUS FORMAT
    if ( ($In eq "nexus") || ($In eq "NEXUS") || 
	 ($In eq "nex") || ($In eq "NEX") ) {
	return "nexus";
    };

    # NEWICK FORMAT
    if ( ($In eq "newick") || ($In eq "NEWICK") || 
	 ($In eq "new") || ($In eq "NEW") ) {
	return "newick";
    };

    # NEW HAMPSHIRE EXTENDED
    if ( ($In eq "nhx") || ($In eq "NHX") ) {
	return "nhx";
    };
    
    # LINTREE FORMAT
    if ( ($In eq "lintree") || ($In eq "LINTREE") ) {
	return "lintree";
    }

    die "Can not intrepret file format:$In\n";

}

sub connect_to_db {
    my ($cstr) = @_;
    return connect_to_mysql(@_) if $cstr =~ /:mysql:/i;
    return connect_to_pg(@_) if $cstr =~ /:pg:/i;
    die "can't understand driver in connection string: $cstr\n";
}

sub connect_to_pg {

	my ($cstr, $user, $pass) = @_;
	
	my $dbh = DBI->connect($cstr, $user, $pass, 
                               {PrintError => 0, 
                                RaiseError => 1,
                                AutoCommit => 0});
	$dbh || &error("DBI connect failed : ",$dbh->errstr);

	return($dbh);
} # End of ConnectToPG subfunction


sub connect_to_mysql {
    
    my ($cstr, $user, $pass) = @_;
    
    my $dbh = DBI->connect($cstr, 
			   $user, 
			   $pass, 
			   {PrintError => 0, 
			    RaiseError => 1,
			    AutoCommit => 0});
    
    $dbh || &error("DBI connect failed : ",$dbh->errstr);
    
    return($dbh);
}

sub prepare_sth {
    my $dbh = shift;
#    my ($dbh) = @_;
    my $sth = $dbh->prepare(@_);
    die "failed to prepare statement '$_[0]': ".$dbh->errstr."\n" unless $sth;
    return $sth;
}

sub execute_sth {
    
    # I would like to return the statement string here to figure 
    # out where problems are.
    
    # Takes a statement handle
    my $sth = shift;

    my $rv = $sth->execute(@_);
    unless ($rv) {
	$dbh->disconnect();
	die "failed to execute statement: ".$sth->errstr."\n"
    }
    return $rv;
} # End of execute_sth subfunction

sub last_insert_id {

    #my ($dbh,$table_name,$driver) = @_;
    
    # The use of last_insert_id assumes that the no one
    # is interleaving nodes while you are working with the db
    my $dbh = shift;
    my $table_name = shift;
    my $driver = shift;

    # The following replace by sending driver info to the sufunction
    #my $driver = $dbh->get_info(SQL_DBMS_NAME);
    if (lc($driver) eq 'mysql') {
	return $dbh->{'mysql_insertid'};
    } elsif ((lc($driver) eq 'pg') || ($driver eq 'PostgreSQL')) {
	my $sql = "SELECT currval('${table_name}_pk_seq')";
	my $stmt = $dbh->prepare_cached($sql);
	my $rv = $stmt->execute;
	die "failed to retrieve last ID generated\n" unless $rv;
	my $row = $stmt->fetchrow_arrayref;
	$stmt->finish;
	return $row->[0];
    } else {
	die "don't know what to do with driver $driver\n";
    }
} # End of last_insert_id subfunction

# The following pulled directly from the DBI module
# this is an attempt to see if I can get the DSNs to parse 
# for some reason, this is returning the driver information in the
# place of scheme

sub parse_dsn {
    my ($dsn) = @_;
    $dsn =~ s/^(dbi):(\w*?)(?:\((.*?)\))?://i or return;
    my ($scheme, $driver, $attr, $attr_hash) = (lc($1), $2, $3);
    $driver ||= $ENV{DBI_DRIVER} || '';
    $attr_hash = { split /\s*=>?\s*|\s*,\s*/, $attr, -1 } if $attr;
    return ($scheme, $driver, $attr, $attr_hash, $dsn);
}


sub user_feedback
{
#-----------------------------+
# USER FEEDBACK SUBFUNCTION   |
#-----------------------------+
    
    my $Question = $_[0];
    my $Answer;
    
    print "\n$Question \n";
    
    while (<>)
    {
	chop;
	if ( ($_ eq 'y') || ($_ eq 'Y') || ($_ eq 'yes') || ($_ eq 'YES') ) {
	    $Answer = "Y";
	    return $Answer;
	}
	elsif ( ($_ eq 'n') || ($_ eq 'N') || ($_ eq 'NO') || ($_ eq 'no') ) {
	    $Answer = "N";
	    return $Answer;
	}
	else{
	    print "\n$Question \n";
	}
    }
    
} # End of UserFeedback subfunction

sub print_help {

    # Print requested help or exit.
    # Options are to just print the full 
    my ($opt) = @_;

    my $usage = "USAGE:\n". 
	"  phymod.pl -i InFile -o OutFile";
    my $args = "REQUIRED ARGUMENTS:\n".
	"  --dsn          # Not really. just here for now.\n".
	"\n".
	"OPTIONS:\n".
	"  --dbname       # Name of the database to connect to\n".
	"  --host         # Database host\n".
	"  --driver       # Driver for connecting to the database\n".
	"  --dbuser       # Name to log on to the database with\n".
	"  --dbpass       # Password to log on to the database with\n".
	"  --tree         # Name of the tree to optimize\n".
	"  --version      # Show the program version\n".     
	"  --usage        # Show program usage\n".
	"  --help         # Show this help message\n".
	"  --man          # Open full program manual\n".
	"  --verbose      # Run the program with maximum output\n". 
	"  --quiet        # Run program with minimal output\n";
	
    if ($opt =~ "full") {
	print "\n$usage\n\n";
	print "$args\n\n";
    }
    else {
	print "\n$usage\n\n";
    }
    
    exit;
}

=head1 NAME 

phymod.pl - Modifiy trees in the PhyloDB database

=head1 VERSION

This documentation refers to phymod.pl version 1.0.

=head1 SYNOPSIS

  Usage: phymod.pl

    REQUIRED ARGUMENTS:
        --dsn        # The DSN string for the DB connection
        --dbuser     # User name to connect with
        --dbpass     # User password to connect with
        --infile     # Full path to the tree file to import to the db
        --format     # "newick", "nexus" (default "newick")
    ALTERNATIVE TO --dsn:
        --driver     # DB Driver "mysql", "Pg", "Oracle" 
        --dbname     # Name of database to use
        --host       # Host to connect with (ie. localhost)
    ADDITIONAL OPTIONS:
        --tree       # Tree name to use
        --quiet      # Run the program in quiet mode.
	--verbose    # Run the program in verbose mode.
    ADDITIONAL INFORMATION:
        --version    # Show the program version     
	--usage      # Show program usage
        --help       # Print short help message
	--man        # Open full program manual

=head1 DESCRIPTION

Modify trees in a PhyloDB database. Since the current version of the program
requires that node IDs be passed, the names of the trees do not need to be
passed to the program. The down side is that you must know the unique ID
for the name used by the database. These can be obtained by running the
phyexport command with the ____ option. This will produce a tree
with nodes labeled by the name given in the original tree, as well as the
node ids used in the database.

=head1 COMMAND LINE ARGUMENTS

=head2 Required Arguments

=over 2

=item -d, --dsn

the DSN of the database to connect to; default is the value in the
environment variable DBI_DSN. If DBI_DSN has not been defined and
the string is not passed to the command line, the dsn will be 
constructed from --driver, --dbname, --host

Example: DBI:mysql:database=biosql;host=localhost

=item -u, --dbuser

The user name to connect with; default is the value in the environment
variable DBI_USER.

This user must have permission to add data to tables.

=item -p, --dbpass

password to connect with; default is the value in the environment
variable DBI_PASSWORD. If this is not provided at the command line
the user is prompted.

=item -x, --cut-node

The source node that will be cut from the tree. When passed witout a paste
the data will be deleted from the database. B<There is currently no
way to undelete a node that was cut.>

=item -c, --copy-node

The source node that will be copied.

=item -v, --paste-node

Currently it is only possible to paste a node onto an existing node.

=back

=head2 Alternative to --dsn

=over 2

=item --host

The database host to connect to; default is localhost.

=item --dbname

The database name to connect to; default is biosql.

=item --driver

The database driver to connect with; default is mysql.
Options other then mysql are currently not supported.

=back

=head2 Additional Options

=over 2

=item -q, --quiet

Print the program in quiet mode. No output will be printed to STDOUT
and the user will not be prompted for intput.

=back

=head2 Additional Information

=over

=item --version

Show the program version.   

=item --usage      

Show program usage statement.

=item --help

Show a short help message.

=item --man

Show the full program manual.

=back

=head1 EXAMPLES

B<Cut branch from tree>

The following command would remove the branch rooted at node 25 from the
tree named cornus.

    phymod.pl -t cornus -x 25

=head1 DIAGNOSTICS

Add diagnostics information here.

=head1 CONFIGURATION AND ENVIRONMENT

Many of the options passed at the command line can be set as 
options in the user's environment. 

=over 2

=item DBI_USER

User name to connect to the database.

=item DBI_PASSWORD

Password for the database connection

=item DBI_DSN

DSN for database connection.

=back

For example in the bash shell this would be done be editing your .bashrc file
to contain:

    export DBI_USER=yourname
    export DBI_PASS=yourpassword
    export DBI_DSN='DBI:mysql:database=biosql;host-localhost'

=head1 DEPENDENCIES

The phyinit program is dependent on the following PERL modules:

=over 2

=item DBI - L<http://dbi.perl.org>

The PERL Database Interface (DBI) module allows for connections 
to multiple databases.

=item DBD:MySQL - 
L<http://search.cpan.org/~capttofu/DBD-mysql-4.005/lib/DBD/mysql.pm>

MySQL database driver for DBI module.

=item DBD:Pg -
L<http://search.cpan.org/~rudy/DBD-Pg-1.32/Pg.pm>

PostgreSQL database driver for the DBI module.

=item Getopt::Long - L<http://perldoc.perl.org/Getopt/Long.html>

The Getopt module allows for the passing of command line options
to perl scripts.

=back

A RDBMS is also required. This can be one of:

=over 2

=item MySQL - L<http://www.mysql.com>

=item PostgreSQL - L<http://www.postgresql.org>

=back


=head1 BUGS AND LIMITATIONS

Known Limitations:

=over 2

=item *
Currently only stable with the MySQL Database driver.

=item *
DSN string must currently be in the form:
DBI:mysql:database=biosql;host=localhost

=back

=head1 SEE ALSO

The program phyinit.pl is a component of a package of comand line programs
for PhyloDB management. Additional programs include:

=over

=item phyimport.pl

Import common phylogenetic file formats.

=item phyexport.pl

Export tree data in PhyloDB to common file formats.

=item phyopt.pl

Compute optimization values for a PhyloDB database.

=item phyqry.pl

Return a standard report of information for a given tree.

=item phymod.pl

Modify an existing phylogenetic database by deleting, adding or
copying branches.

=back

=head1 LICENSE

This file is part of BioSQL.

BioSQL is free software: you can redistribute it and/or modify it
under the terms of the GNU Lesser General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

BioSQL is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with BioSQL. If not, see <http://www.gnu.org/licenses/>.

=head1 AUTHORS

James C. Estill E<lt>JamesEstill at gmail.comE<gt>

Hilmar Lapp E<lt>hlapp at gmx.netE<gt>

William Piel E<lt>william.piel at yale.eduE<gt>

=head1 HISTORY

Started: 07/06/2007

Updated: 08/19/2007

=cut
