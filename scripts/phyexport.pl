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
# phyexport.pl - Export phylodb data to common file formats |
#                                                           |
#-----------------------------------------------------------+
#                                                           |
# CONTACT: JamesEstill_at_gmail.com                         |
# STARTED: 06/18/2007                                       |
# UPDATED: 08/19/2007                                       |
#                                                           |
# DESCRIPTION:                                              | 
#  Export data from the PhyloDb database to common file     |
#  file formats.                                            |
#                                                           |
#-----------------------------------------------------------+
#
# TO DO:
# - PGSQL support
# - Allow for using a root_name to name all of the output trees
#   or use the tree_name from the database as the output name
#   when exporting trees.
# - Fix exit handler
# - Add support for subtree export
# - Fix dsn to match the way that Hilmar is doing it
# - Add diagnostics information
# - Use hash for in_format_check
# - Find a better way to use the tree object without making it a
#   package level variable
 
#Package this as PhyloDB for now

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
my $VERSION = "1.0";           # Program version

my $usrname = $ENV{DBI_USER};  # User name to connect to database
my $pass = $ENV{DBI_PASSWORD}; # Password to connect to database
my $dsn = $ENV{DBI_DSN};       # DSN for database connection
my $outfile;                   # Full path to output file to create
my $format = 'newick';         # Data format used in infile
my $db;                        # Database name (ie. biosql)
my $host;                      # Database host (ie. localhost)
my $driver;                    # Database driver (ie. mysql)
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

my $root;                       # The node_id of the root of the tree
                                # that will be exported
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

# BOOLEANS
my $show_help = 0;             # Display help
my $quiet = 0;                 # Run the program in quiet mode
                               # will not prompt for command line options
my $show_node_id = 0;          # Include the database node_id in the output
my $show_man = 0;              # Show the man page via perldoc
my $show_usage = 0;            # Show the basic usage for the program
my $show_version = 0;          # Show the program version
my $verbose;                   # Boolean, but chatty or not

#-----------------------------+
# COMMAND LINE OPTIONS        |
#-----------------------------+
my $ok = GetOptions("d|dsn=s"       => \$dsn,
                    "u|dbuser=s"    => \$usrname,
                    "o|outfile=s"   => \$outfile,
                    "f|format=s"    => \$format,
                    "p|dbpass=s"    => \$pass,
		    "driver=s"      => \$driver,
		    "dbname=s"      => \$db,
		    "host=s"        => \$host,
		    "t|tree=s"      => \$tree_name,
		    "parent-node=s" => \$parent_node,
		    "db-node-id"    => \$show_node_id,
		    "q|quiet"       => \$quiet,
                    "verbose"       => \$verbose,
		    "version"       => \$show_version,
		    "man"           => \$show_man,
		    "usage"         => \$show_usage,
		    "h|help"        => \$show_help);

# TO DO: Normalize format to 

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
    print "\n$0:\nVersion: $VERSION\n\n";
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

# The following works in MySQL 06/20/2007
my $sel_trees = &prepare_sth($dbh, "SELECT name FROM tree");

# The following works in MySQL 06/20/2007
my $sel_root = &prepare_sth($dbh, 
			    "SELECT n.node_id, n.label FROM tree t, node n "
			    ."WHERE t.node_id = n.node_id AND t.name = ?");

# Select the child nodes
my $sel_chld = &prepare_sth($dbh, 
			    "SELECT n.node_id, n.label, e.edge_id "
			    ."FROM node n, edge e "
			    ."WHERE n.node_id = e.child_node_id "
			    ."AND e.parent_node_id = ?");

# Select edge attribute values
my $sel_attrs = &prepare_sth($dbh,
			     "SELECT t.name, eav.value "
			     ."FROM term t, edge_attribute_value eav "
			     ."WHERE t.term_id = eav.term_id "
			     ."AND eav.edge_id = ?");

# Currently doing the following as a fetch_node_label subfunction 
## Select the node label 
#my $sel_label = &prepare_sth($dbh,
#			     "SELECT label FROM node WHERE node_id = ?");

#-----------------------------+
# GET THE TREES TO PROCESS    |
#-----------------------------+
# Check to see if the tree does exist in the database
# throw error message if it does not

# Multiple trees can be passed in the command lined
# we therefore need to split tree name into an array
if ($tree_name) {
    @trees = split( /\,/ , $tree_name );
} else {
    print "No tree name issued at the command line.\n";
}


if (! (@trees && $trees[0])) {
    @trees = ();
    execute_sth($sel_trees);
    while (my $row = $sel_trees->fetchrow_arrayref) {
	push(@trees,$row->[0]);
    }
}


# Add warning here to tell the user how many trees will be 
# created if a single tree was not specified


## SHOW THE TREES THAT WILL BE PROCESSED
my $num_trees = @trees;
print "TREES TO EXPORT ($num_trees)\n";
foreach my $IndTree (@trees) {
    print "\t$IndTree\n";
}

#-----------------------------------------------------------+
# FOR EACH INDIVIDUAL TREE IN THE TREES LIST                | 
#-----------------------------------------------------------+
foreach my $ind_tree (@trees) {

    #-----------------------------+
    # CREATE A NEW TREE OBJECT    |
    #-----------------------------+
    print "\tCreating a new tree object.\n";
    $tree = new Bio::Tree::Tree() ||
	die "Can not create the tree object.\n";


    #///////////////////////////////////////////////////
    # WORKING HERE
    # TRYING TO DEFINE ROOT AS THE 
    #\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    
    if ($parent_node) {
	# Set the root to the parent node passed at cmd line
	$root->[0] = $parent_node;
    }
    else {
	# Get the root to the entire tre
	execute_sth($sel_root, $ind_tree);
	$root = $sel_root->fetchrow_arrayref;
    }


    if ($root) {
	print "\nProcessing tree: $ind_tree \n";
	#print "\tRoot Node: ".$root->[0]."\n";
	
	# ADD THE ROOT NODE TO THE TREE OBJECT
	my $node = new Bio::Tree::Node( '-id' => $root->[0]);
	$tree->set_root_node($node);
	
	# test of find node here, this appears to work 06/22/2007
	my @par_node = $tree->find_node( -id => $root->[0] );
	my $num_par_nodes = @par_node;
	
    } 
    else {
	print STDERR "no tree with name '$ind_tree'\n";
	next;
    }

    #-----------------------------+
    # LOAD TREE NODES             |
    #-----------------------------+
    # This will need to load the tree nodes to the tre1e object
    #&load_tree_nodes($sel_chld,$root,$sel_attrs, $tree);
    &load_tree_nodes($sel_chld,$root,$sel_attrs);

    #-----------------------------+
    # LOAD NODE VARIABLES         | 
    #-----------------------------+
    # At this point, all of the nodes should be loaded to the tree object
    my @all_nodes = $tree->get_nodes;
    
    foreach my $ind_node (@all_nodes) {
	
        &execute_sth($sel_attrs,$ind_node);
	
        my %attrs = ();

        while (my $row = $sel_attrs->fetchrow_arrayref) {
            $attrs{$row->[0]} = $row->[1];
        }

	#-----------------------------+
	# BOOTSTRAP                   |
	#-----------------------------+
	# Example of adding the boostrap info
	#$ind_node->bootstrap('99');
	# Example of fetching support value from the attrs
        #$attrs{'support value'} if $attrs{'support value'};
	if ( $attrs{'support value'} ) {
	    #print "\t\tSUP:".$attrs{'support value'}."\n";
	    $ind_node->bootstrap( $attrs{'support value'} );
	}
	
	#-----------------------------+
	# BRANCH LENGTH               |
	#-----------------------------+
	# Example of adding the branch length info 
	#$ind_node->branch_length('10');
	# Example of fetching the branch length from the attrs
        #print ":".$attrs{'branch length'} if $attrs{'branch length'}
	if ($attrs{'branch length'} ) {
	    $ind_node->branch_length( $attrs{'branch length'} );
	}

	#-----------------------------+
	# SET NODE ID                 |
	#-----------------------------+
	# TO DO 
	# INCLUDE OPTION TO USE DB ID'S FOR INTERNAL NODES
	# If null in the original tree, put null here
	#my $sql = "SELECT label FROM node WHERE node_id = $ind_node";
	
	if ($show_node_id) {

	    my $node_label = fetch_node_label($dbh, $ind_node->id());
	    
	    # If a node label exists in the database, show the 
	    # database node id in parenthesis
	    if ($node_label) {
		# At this point the node id in the database is saved
		# as $ind_node->id, the node label from the original
		# tree is stored as $node_label
		my $new_node_id = $node_label."_node_".$ind_node->id;
		$ind_node->id($new_node_id);
	    }
	}
	else {
	    
	    # Otherwise overwrite the node id with the value in
	    # the node_label field of the node table
	    my $node_label = fetch_node_label($dbh, $ind_node->id());
	    
	    if ($node_label) {
		$ind_node->id($node_label);
	    } 
	    else {
		$ind_node->id('');
	    }

	} # End of  if show_node_id
	
    }
    
    #-----------------------------+
    # EXPORT TREE FORMAT          |
    #-----------------------------+
    # The following two lines used for code testing
    #my $treeio = new Bio::TreeIO( '-format' => $format );
    #print "OUTPUT TREE AS $format:\n";
    my $treeio = Bio::TreeIO->new( -format => $format,
				   -file => '>'.$outfile)
	|| die "Could not open output file:\n$outfile\n";
    
    
    # The following code writes the tree out to the STDOUT
    my $treeout_here = Bio::TreeIO->new( -format => $format );
    
    $treeout_here->write_tree($tree); 

    $treeio->write_tree($tree);

#    # The follwoing writes the code to the output file
#    # but for some reason it does not return true ..
#    if ( $treeio->write_tree($tree) ) {
#	print "\tTree exported to:\n\t$outfile\n";
#    };
    
#    $treeio->write_tree($PhyloDB::tree) ||
#	die "Cound not write tree to output file.";

#    print "\tTree exported to:\n\t$outfile\n";
    

} # End of for each tree


# End of program
print "\n$0 has finished.\n";

exit;

#-----------------------------------------------------------+
# SUBFUNCTIONS                                              |
#-----------------------------------------------------------+

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

sub print_help {

    # Print requested help or exit.
    # Options are to just print the full 
    my ($opt) = @_;

    my $usage = "USAGE:\n". 
	"  phyexport.pl -i InFile -o OutFile";
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

=cut

=head1 NAME 

phyexport.pl - Export PhyloDB data to common tree file formats.

=head1 VERSION

This documentation refers to phyexport version 1.0.

=head1 SYNOPSIS

  USAGE: phyexport.pl

    REQUIRED ARGUMENTS:
        --dsn         # The DSN string the database to connect to
                      # Must conform to:
                      # 'DBI:mysql:database=biosql;host=localhost' 
        --dbuser      # User name to connect with
        --dbpass      # Password to connect with
        --outfile     # Full path to output file that will be created.
    ALTERNATIVE TO --dsn:
        --driver     # DB Driver "mysql", "Pg" "Oracle" 
        --dbname     # Name of database to use
        --host       # Host to connect with (ie. localhost)
    ADDITIONAL OPTIONS:
        --format      # "newick", "nexus" (default "newick")
        --tree        # Name of the tree to export
        --parent-node # Node to serve as root for a subtree export
        --help        # Print this help message
        --quiet       # Run the program in quiet mode.
        --db-node-id  # Preserve DB node names in export

=head1 DESCRIPTION

Export a tree stored in a PhyloDB database to a specified output format. 
Currently nexus, newick, lintree and New Hampshire Extended formats are 
supported. However; only the basic tree is currently supported. Branch
data are not exported.

=head1 COMMAND LINE ARGUMENTS

=head2 Required Arguments

=over

=item -d, --dsn

The DSN of the database to connect to; default is the value in the
environment variable DBI_DSN. If DBI_DSN has not been defined and
the string is not passed to the command line, the dsn will be 
constructed from --driver, --dbname, --host

DSN must be in the form:

DBI:mysql:database=biosql;host=localhost

=item -u, --dbuser

The user name to connect with; default is the value in the environment
variable DBI_USER.

This user must have permission to create databases.

=item -p, --dbpass

The password to connect with; default is the value in the environment
variable DBI_PASSWORD. If this is not provided at the command line
the user is prompted.

=item -o, --outfile

The full path of the output file that will be created.

=back

=head2 Alternative to --dsn

An alternative to passing the full dsn at the command line is to
provide the components separately.

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

=item -f, --format

Format of the export file. Accepted file format options are: 

nexus (C<-f nex>) - L<http://www.bioperl.org/wiki/NEXUS_tree_format>

newick (C<-f newick>) - L<http://www.bioperl.org/wiki/Newick_tree_format>

nhx (C<-f nhx>) - 
L<http://www.bioperl.org/wiki/New_Hampshire_extended_tree_format>

lintree (C<-f lintree>) -L<http://www.bioperl.org/wiki/Lintree_tree_format>

=item --parent-node

Node id to serve as the root for a subtree export. B<Currenly not supported>

=item --db-node-id

Preserve database node ids when exporting the tree. For nodes that
have existing labels in the label field, the node_id from the database
will be indicated in parentesis.

=item -h, --help

Print the help message.

=item -q, --quiet

Print the program in quiet mode. No output will be printed to STDOUT
and the user will not be prompted for intput.

=back

=head2 Additional Information

=over 2

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

B<Export a single tree>

The following example would export the single tree named Cornus in the biosql
database to the nexus formatted outfile cornus.nex.

    phyexport.pl -d 'DBI:mysql:database=biosql;host=localhost'
                 -u UserName -p password -t cornus -o cornus.nex
                 -f nex

If you have identified the dsn, username, and password in your environment
this is simplified to.

    phyexport.pl -t cornus -o cornus.nex -f nex

Exporting the same tree in newick format would be

    phyexport.pl -t cornus -o cornus.newick -f new

Exporting in the New Hampshire extended foramt

    phyexport.pl -t cornus -o cornus.nhx -f nhx

=head1 DIAGNOSTICS

The known error messages below are followed by possible descriptions of
the error and possible solutions.

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

=head1 BUGS AND LIMITATIONS

Known Limitations:

=over 2

=item *
Currently only stable with the MySQL Database driver.

=item *
DSN string must currently be in the form:
DBI:mysql:database=biosql;host=localhost

=back

Please report additional problems to 
James Estill E<lt>JamesEstill at gmail.comE<gt>

=head1 SEE ALSO

The program phyinit.pl is a component of a package of comand line programs
for PhyloDB management. Additional programs include:

=over

=item phyinit.pl

Initialize a PhyloDB database.

=item phyimport.pl

Import common phylogenetic file formats.

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

Started: 06/18/2007

Updated: 08/19/2007

=cut
