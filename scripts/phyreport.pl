#!/usr/bin/perl -w
#
# $Id$
#
#-----------------------------------------------------------+
#                                                           |
# phyreport.pl - Standard report for database or tree       |
#                                                           |
#-----------------------------------------------------------+
#                                                           |
#  AUTHOR: James C. Estill                                  |
# CONTACT: JamesEstill_at_gmail.com                         |
# STARTED: 07/11/2007                                       |
# UPDATED: 08/24/2007                                       |
#                                                           |
# DESCRIPTION:                                              | 
#  Create a standard report for the entire database, or a   |
#  selected tree within the database. Output will be        |
#  sent to an output file.                                  |
#                                                           |
#-----------------------------------------------------------+
#
# TO DO:
# - PGSQL support
# - Allow for subquery within a tree using an identified node as
#   the query root.
# - Write to STDOUT when an outfile path is not specified.
# - Add support for quiet option
# - Clean out code not currently being used

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
my @trees = ();                # Array holding the names of the trees that
                               # reports will be generate for
my $statement;                 # Var to hold SQL statement string
my $sth;                       # Statement handle for SQL statement object

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
#my $show_help = 0;             # Display help
my $show_man = 0;              # Show the man page via perldoc
my $show_usage = 0;            # Show the basic usage for the program
my $show_version = 0;          # Show the program version
my $verbose = 0;               # Run program in chatty mode
my $show_help = 0;                  # Display help
my $quiet = 0;                 # Run the program in quiet mode
                               # will not prompt for command line options
my $show_node_id = 0;          # Include the database node_id in the output


#-----------------------------+
# COMMAND LINE OPTIONS        |
#-----------------------------+
my $ok = GetOptions(# REQUIRED VARS
                    "d|dsn=s"       => \$dsn,
                    "u|dbuser=s"    => \$usrname,
                    "o|outfile=s"   => \$outfile,
                    "f|format=s"    => \$format,
                    "p|dbpass=s"    => \$pass,
		    "driver=s"      => \$driver,
		    "dbname=s"      => \$db,
		    "host=s"        => \$host,
		    "t|tree=s"      => \$tree_name,
		    "parent-node=s" => \$parent_node,
		    # BOOLEANS
		    "db-node-id"    => \$show_node_id,
		    "q|quiet"       => \$quiet,
		    "verbose"       => \$verbose,
		    "version"       => \$show_version,
		    "man"           => \$show_man,
		    "usage"         => \$show_usage,
		    "h|help"        => \$show_help);

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
    if ($verbose) {
	print "\tDSN:\t$dsn\n";
	print "\tPRE:\t$prefix\n";
	print "\tDRIVER:\t$driver\n";
	print "\tSUF:\t$suffix\n";
	print "\tDB:\t$db\n";
	print "\tHOST:\t$host\n";
	# The following not required
	print "\tTREES\t$tree_name\n" if $tree_name;
    }

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
my $dbh = &connect_to_db($dsn, $usrname, $pass);

#-----------------------------+
# OPEN OUTFILE                |
#-----------------------------+
if ($outfile) {
    open(STDOUT, ">$outfile") ||
	die "ERROR: Can not open outfile:\n$outfile\n";
}

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

#-----------------------------+
# GET THE TREES TO PROCESS    |
#-----------------------------+
# TODO: Check to see if the tree does exist in the database
#       throw error message if it does not

# Multiple trees can be passed in the command lined
# we therefore need to split tree name into an array
if ($tree_name) {
    @trees = split( /\,/ , $tree_name );
} 
else {
    print "No tree name issued at the command line.\n" if $verbose;
}

if (! (@trees && $trees[0])) {
    @trees = ();
    execute_sth($sel_trees);
    while (my $row = $sel_trees->fetchrow_arrayref) {
	push(@trees,$row->[0]);
    }
}

# TODO: Add warning here to tell the user how many trees will be 
#       reported on if a single tree was not specified


## SHOW THE TREES THAT WILL BE PROCESSED
my $num_trees = @trees;
print "TREES TO REPORT ($num_trees)\n";
foreach my $IndTree (@trees) {
    print "\t$IndTree\n";
}

#-----------------------------------------------------------+
# FOR EACH INDIVIDUAL TREE IN THE TREES LIST                | 
#-----------------------------------------------------------+
foreach my $ind_tree (@trees) {
    

    print "\n========================================\n";
    print "\ TREE: $ind_tree\n";
    print "========================================\n";
    my $tree_id = fetch_tree_id($dbh,$ind_tree);
    print "TREE ID:\t$tree_id\n";

    my $num_leaf_nodes = count_leaf_nodes($dbh,$tree_id);
    print "LEAF NODES:\t$num_leaf_nodes\n";

    my $root_node_id = fetch_root_node_id($dbh,$tree_id);
    print "ROOT NODE ID:\t$root_node_id\n";

    my @leaf_node_ids = fetch_leaf_nodes($dbh,$tree_id);

    print "LEAF NODES:\n";
    for my $leaf_node_id (@leaf_node_ids) {
	my $node_label = fetch_node_label ($dbh, $leaf_node_id);

	print "\t$leaf_node_id\t$node_label\n";

    }

} # End of for each tree


# End of program
print "\n$0 has finished.\n" if $verbose;

exit;

#-----------------------------------------------------------+
# SUBFUNCTIONS                                              |
#-----------------------------------------------------------+

#sub fetch_

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

sub count_leaf_nodes {
    
    my ($dbh, $tree_id) = @_;
    my ($sql, $cur, $result, @row);

    $sql = "SELECT COUNT(*) FROM node WHERE(right_idx-left_idx) = 1".
	" AND tree_id=\'$tree_id\'";
    $cur = $dbh->prepare($sql);
    $cur->execute();
    @row=$cur->fetchrow;
    $result=$row[0];
    $cur->finish();
    
    return $result;
    
}

sub fetch_leaf_nodes {

    # Fetch the ids of the leaf nodes
    my ($dbh, $tree_id) = @_;
    my ($sth, $sql, $cur, $result, @row, @nodes);
   
    $sql = "SELECT node_id FROM node WHERE(right_idx-left_idx) = 1".
	" AND tree_id=\'$tree_id\'";
    $sth = $dbh->prepare($sql);
    $sth->execute();
    
    while (my $r = $sth->fetchrow_arrayref) {
	$result = @$r[0];
	push (@nodes,$result);
    }

    return @nodes;

}

sub fetch_tree_id {
    
    #my $result = 0;
    my ($dbh, $tree_name) = @_;
    my ($sql, $cur, $result, @row);
   
    $sql = "SELECT tree_id FROM tree WHERE name =\'".$tree_name."\'";
    $cur = $dbh->prepare($sql);
    $cur->execute();
    @row=$cur->fetchrow;
    $result=$row[0];
    $cur->finish();

    return $result;

}

sub fetch_root_node_id {

    #my $result = 0;
    my ($dbh, $tree_id) = @_;
    my ($sql, $cur, $result, @row);
   
    $sql = "SELECT node_id FROM node WHERE left_idx=\'1\'".
	" AND tree_id=\'$tree_id\'";
    $cur = $dbh->prepare($sql);
    $cur->execute();
    @row=$cur->fetchrow;
    $result=$row[0];
    $cur->finish();

    return $result;

}

sub print_help {

    # Print requested help or exit.
    # Options are to just print the full 
    my ($opt) = @_;

    my $usage = "USAGE:\n". 
	"  phyreport.pl -o PhyloDBReport.txt";
    my $args = 
	"REQUIRED ARGUMENTS:\n".
        "    --dsn         # The DSN string the database to connect to\n".
	"                  # Must conform to:\n".
	"                  # \'DBI:mysql:database=biosql;host=localhost\'\n".
        "    --dbuser      # User name to connect with\n".
        "    --dbpass      # Password to connect with\n".
        "    --outfile     # Full path to output file that will be created.\n".
	"ALTERNATIVE TO --dsn:\n".
        "    --driver      # DB Driver \"mysql\", \"Pg\", \"Oracle\"\n". 
        "    --dbname      # Name of database to use\n".
        "    --host        # Host to connect with (ie. localhost)\n".
	"ADDITIONAL OPTIONS:\n".
        "    --tree        # Name of the tree to report on\n".
        "                  # Otherwise generate report for all trees\n".
        "    --quiet       # Run the program in quiet mode.\n".
	"    --verbose     # Run the program in verbose mode.\n".
	"ADDITIONAL INFORMATION:\n".
        "    --version     # Show the program version\n".     
	"    --usage       # Show program usage\n".
        "    --help        # Print short help message\n".
	"    --man         # Open full program manual\n";

	
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

phyreport.pl - Create a standard report for a PhyloDB database or tree

=head1 VERSION

This documentation refers to phyreport version 1.0.

=head1 SYNOPSIS

  Usage: phyreport.pl -o PhyloDbReport.txt

    REQUIRED ARGUMENTS:
        --dsn         # The DSN string the database to connect to
                      # Must conform to:
                      # 'DBI:mysql:database=biosql;host=localhost' 
        --dbuser      # User name to connect with
        --dbpass      # Password to connect with
        --outfile     # Full path to output file that will be created.
    ALTERNATIVE TO --dsn:
        --driver      # DB Driver "mysql", "Pg", "Oracle" 
        --dbname      # Name of database to use
        --host        # Host to connect with (ie. localhost)
    ADDITIONAL OPTIONS:
        --tree        # Name of the tree to report on
                      # Otherwise generate report for all trees
        --quiet       # Run the program in quiet mode.
	--verbose     # Run the program in verbose mode.
    ADDITIONAL INFORMATION:
        --version     # Show the program version     
	--usage       # Show program usage
        --help        # Print short help message
	--man         # Open full program manual

=head1 DESCRIPTION

Generate a summary report for a tree or the entire PhyloDB database. Not
a very exciting program, but givies a short overview of the trees that
are stored in the PhyloDB database. This will only work correctly
for trees that have been optimized with the phyopt program.

=head1 COMMAND LINE ARGUMENTS

=head2 Required Arguments

=over 2

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

=item --parent-node

Node id to serve as the root for a subtree report. B<CURRENTLY NOT IMPLEMENTED.>

=item -q, --quiet

Run the program in quiet mode. No output will be printed to STDOUT
and the user will not be prompted for intput. B<CURRENTLY NOT IMPLEMENTED.>

=item --verbose

Execute the program in verbose mode.

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

B<Generate report for entire database>

The following commands would generate a report for the entire biosql database.
The results would be saved to BiosqlReprot.txt.

    phyreport.pl -d 'DBI:mysql:database=biosql;host=localhost'
                 -u name -p password -o BiosqlReport.txt

If the dsn, user name and password are defined as environmental variables
then the following command would yield the same result.

    phyreport.pl -o BiosqlReport.txt

B<Generate report for a single tree>

The following would generate a report for the tree named cats in the
database name biosql. The results would be saved to the text file
CatsReport.txt

    phyreport.pl -d 'DBI:mysql:database=biosql;host=localhost'
                 -u name -p password -t cats -o CatsReport.txt 

=head1 DIAGNOSTICS

The error messages below are followed by descriptions of the error
and possible solutions.

=over 2

=item B<C<ERROR: Can not open outfile: /some/file/path/outfile.txt>>

B<Description:> The outfile specified at the command line is not
available to write to. This may possiby be because the file path
that was specified does not exist.

B<Solution:>It is possible to write the file to the current working
directory by simply using a file name without a full path. You should
also check that you have write access to the directory that you
are trying to write your output file to.

=back

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

The phyimport.pl program is dependent on the following PERL modules:

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

=item Bio::Tree - L<http://www.bioperl.org>

The Bio::Tree module is part of the bioperl package.

=back

A RDBMS is also required. This can be one of:

=over 2

=item MySQL - L<http://www.mysql.com>

=item PostgreSQL - L<http://www.postgresql.org>

=back

=head1 BUGS AND LIMITATIONS

Known limitations:

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

The program phyreport.pl is a component of a package of comand line programs
for PhyloDB management. Additional programs include:

=over

=item phyinit.pl

Initialize a PhyloDB database.

=item phyimport.pl

Import trees into the PhyloDB database.

=item phyexport.pl

Export tree data in PhyloDB to common file formats.

=item phyopt.pl

Compute optimization values for a PhyloDB database.

=item phymod.pl

Modify an existing phylogenetic database by deleting, adding or
copying branches.

=back

=head1 LICENSE

This program may be used, distributed or modified under the same
terms as Perl itself. Please consult the Perl Artistic License
(http://www.perl.com/pub/a/language/misc/Artistic.html) for the
terms under which you may use, modify, or distribute this script.

THIS SOFTWARE COMES AS IS, WITHOUT ANY EXPRESS OR IMPLIED
WARRANTY. USE AT YOUR OWN RISK.

=head1 AUTHORS

James C. Estill E<lt>JamesEstill at gmail.comE<gt>

Hilmar Lapp E<lt>hlapp at gmx.netE<gt>

William Piel E<lt>william.piel at yale.eduE<gt>

=head1 HISTORY

Started: 07/11/2007

Updated: 08/24/2007

=cut
