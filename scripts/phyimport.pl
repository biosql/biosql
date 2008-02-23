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
# phyimport.pl - Import data from common file formats       |
#                                                           |
#-----------------------------------------------------------+
#                                                           |
# CONTACT: JamesEstill_at_gmail.com                         |
# STARTED: 06/01/2007                                       |
# UPDATED: 09/19/2007                                       |
#                                                           |
# DESCRIPTION:                                              | 
#  Import NEXUS and Newick files from text files to the     |
#  PhyloDB. This incorporates code from parseTreesPG.pl     |
#  but used the bioperl Tree object to work with trees.     |
#                                                           |
# LICENSE:                                                  |
#  GNU Lesser Public License                                |
#  http://www.gnu.org/licenses/lgpl.html                    |  
#                                                           |
#-----------------------------------------------------------+
#
# THIS SOFTWARE COMES AS IS, WITHOUT ANY EXPRESS OR IMPLIED
# WARRANTY. USE AT YOUR OWN RISK.

#
# TO DO:
# - PGSQL Support
# - The internal nodes used by TreeI will not be the same
#   as the nodes used in the database so the DB ID will
#   need to be fetched when adding edges to the database.
# - Add taxa to the biosql database and add taxa information
#   from the tree to the PhyloDB node table. This would required
#   using the taxon_id field in the node table
# - Add edge_attribute data when available

#-----------------------------+
# INCLUDES                    |
#-----------------------------+
use strict;
use DBI;
use Getopt::Long;
use Bio::TreeIO;                # creates Bio::Tree::TreeI objects
use Bio::Tree::TreeI;

#-----------------------------+
# VARIABLE SCOPE              |
#-----------------------------+
my $VERSION = "1.0";           # Program version

my $usrname = $ENV{DBI_USER};  # User name to connect to database
my $pass = $ENV{DBI_PASSWORD}; # Password to connect to database
my $dsn = $ENV{DBI_DSN};       # DSN for database connection
my $infile;                    # Full path to the input file to parse
my $format = 'newick';         # Data format used in infile
my $db;                        # Database name (ie. biosql)
my $host;                      # Database host (ie. localhost)
my $driver;                    # Database driver (ie. mysql)
my $sqldir;                    # Directory that contains the sql to run
                               # to create the tables.
my $tree_name;                 # The name of the tree
                               # For files with multiple trees, this may
                               # be used as a base name to name the trees with
my $statement;                 # Var to hold SQL statement string
my $sth;                       # Statement handle for SQL statement object

# BOOLEANS
my $verbose = 0;
my $show_help = 0;             # Display help
my $show_man = 0;              # Show the man page via perldoc
my $show_usage = 0;            # Show the basic usage for the program
my $show_version = 0;          # Show the program version
my $quiet = 0;                 # Run the program in quiet mode
                               # will not prompt for command line options

#-----------------------------+
# COMMAND LINE OPTIONS        |
#-----------------------------+
my $ok = GetOptions(# REQUIRED ARGUMENTS
                    "d|dsn=s"    => \$dsn,
                    "u|dbuser=s" => \$usrname,
                    "p|dbpass=s" => \$pass,
                    "i|infile=s" => \$infile,
                    "f|format=s" => \$format,
		    # ALTERNATIVE TO --dsn 
		    "driver=s"   => \$driver,
		    "dbname=s"   => \$db,
		    "host=s"     => \$host,
		    # ADDITIONAL OPTIONS
		    "t|tree=s"   => \$tree_name,
		    # BOOLEANS
		    "q|quiet"    => \$quiet,
		    "verbose"    => \$verbose,
		    "version"    => \$show_version,
		    "man"        => \$show_man,
		    "usage"      => \$show_usage,
		    "h|help"     => \$show_help,);

# Exit if format string is not recognized
print "Requested format: $format\n" if $verbose;
$format = &in_format_check($format);

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

if ( ($db) & ($host) & ($driver) ) {
    # Set default values if none given at command line
    $db = "biosql" unless $db; 
    $host = "localhost" unless $host;
    $driver = "mysql" unless $driver;
    $dsn = "DBI:$driver:database=$db;host=$host";
} 
elsif ($dsn) {
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
    print "\tPRE:\t$prefix\n" if $verbose;
    print "\tDRIVER:\t$driver\n" if $verbose;
    print "\tSUF:\t$suffix\n" if $verbose;
    print "\tDB:\t$db\n" if $verbose;
    print "\tHOST:\t$host\n" if $verbose;
}
else {
    # The variables to create a dsn have not been passed
    print "ERROR: A valid dsn can not be created\n";
    exit;
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
END {
    &end_work($dbh);
}

#-----------------------------+
# LOAD THE INPUT FILE         |
#-----------------------------+
print "\nLoading tree...\n";

my $tree_in = new Bio::TreeIO(-file   => "$infile",
			      -format => $format) ||
    die "Can not open $format format tree file:\n$infile";

my $tree;
my $tree_num = 1;

my $count_trees = 0;

# The following used for testing if trees are in the file
#while( $tree = $tree_in->next_tree ) {
#    $count_trees++;
#}
#print "$count_trees were found in the file:\n$infile.\n";
#exit;

# Need to check out the tree here

while( $tree = $tree_in->next_tree ) {

    my $tree_db_id;          # integer ID of the tree in the database
    my $node_db_id;          # integer ID of a node in the database
    my $edge_db_id;          # integer ID of an edge in the database

    print "PROCESSING TREE NUM: $tree_num\n";

# It may be useful to print the number of leaf nodes here
#    my @taxa = $tree->get_leaf_nodes;
#    my $NumTax = @taxa;    
    my @taxa = $tree->get_leaf_nodes;
    my $num_tax = @taxa;  
    print "NUM TAXA:\t$num_tax\n";
    
    #-----------------------------+
    # TREE NAME                   |
    #-----------------------------+
    # If the tree has an id, then use the internal id
    # otherwise set to a new id. This will also need to
    # check to see if the id is already used in the database
    # If there are multiple trees in the database, and no
    # tree name has already been used, then append the tree num
    # to the $tree_name variable
    if ($tree->id) {
	#print $tree->id."\n";
    } 
    elsif ($tree_name){
	$tree->id($tree_name);
	print "\tNo tree id was given.\n";
	print "\tTree name set to: ".$tree->id."\n";
    } 
    else {
	print "\a"; # Sound alarm
	print "\nERROR: A tree name must be part of the input file or".
	    " entered at the command line using the --tree option.\n".
	    " For more information use:\n$0 -h\n\n";
	$dbh->disconnect();
	exit;
    }
    
    #//////////////////////////////////////////////////////
    # TO DO: Add check here to see if name already exists
    #        in the DB and allow user to set new name if
    #        a conflict exists. 
    #\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    print "TREE NAME:\t".$tree->id."\n";
    
    # Add the Tree info to the tree table
    # Commented out while I work on the getting the
    # rest of the info
    $dbh->do("SET FOREIGN_KEY_CHECKS=0;");
    
    $statement = "INSERT INTO tree".
	" (name,node_id)".
	" VALUES ('".$tree->id."',0)";
    
    # The following for debug
    #print "\nSTATEMENT:\n$statement\n\n";
    $sth = &prepare_sth($dbh,$statement);
    &execute_sth($sth);
    $tree_db_id = &last_insert_id($dbh,"tree", $driver);
    
    # Print TreeId for Debug
    print "TREE DB_ID:\t$tree_db_id\n";
    
    # TURN FK CHECKS BACK ON
    $dbh->do("SET FOREIGN_KEY_CHECKS=0;");
    $dbh->commit();
    
    #-----------------------------+
    # INSERT NODE DATA            |
    #-----------------------------+
    print "PROCESSING NODE DATA\n";

    # Get all nodes from the tree object, load information to the
    # database and reset $tree->id to the id of the node in the
    # biosql databse. This will not and show ancestor
    my @all_nodes = $tree->get_nodes;

    my $num_nodes = @all_nodes;
    print "\tNUM NODES: $num_nodes\n";

    foreach my $ind_node (@all_nodes) {
	
	$statement = "INSERT INTO node (tree_id) VALUES (?)";
	
	$sth = &prepare_sth($dbh,$statement);
	# Jamie replace the following to just use the TreeDbID
	# that is fetched above
	#&execute_sth($sth,$tree->id);
	&execute_sth($sth,$tree_db_id);

	# Get the NodeId for this node in the biosql database
	my $node_db_id = &last_insert_id($dbh, "node", $driver);

	# Add node label if it exists in the tree object
	if ($ind_node->id) {
	    $statement = "UPDATE node SET label = ? WHERE node_id = ?";
	    $sth = &prepare_sth($dbh,$statement);
	    execute_sth($sth, $ind_node->id, $node_db_id );
	}
	
	# Reset the tree object id to the database id
	# this will be used below to add edges to the database so
	# we need to be careful and just die if this does not work
	$ind_node->id($node_db_id) || 
	    die "The Tree Object Node ID can not be set\n";
	
    } # End of for each IndNode
    
    $dbh->commit();

    #-----------------------------+
    # GET EDGES                   |
    #-----------------------------+
    # Need to cycle through the the nodes again since the node ids have
    # been changed to the Node Ids used by the biosql database.

    print "PROCESSING EDGE DATA:\n";
    foreach my $ind_node (@all_nodes) {
	
	# First check to see that an id exists
	if ($ind_node->id) {
	    my $anc = $ind_node->ancestor;
	    
	    # Only add edges when there is an ancestor node that has 
	    # an id.
	    if ($anc)
	    {
		if ($anc->id) {
		    
		    $statement = "INSERT INTO edge".
			" (parent_node_id, child_node_id)".
			" VALUES (?,?)";

		    my $edge_sth = &prepare_sth($dbh,$statement);
		    
		    execute_sth($edge_sth,
				$anc->id,
				$ind_node->id);
		    my $edge_db_id = last_insert_id($dbh,"edge", $driver);
		    
		    # TO DO: Add edge related information here
		    
		    # Print output, node ids printed below
		    # should match the integer ids used in the database
		    # Only do this if verbose

		    if ($verbose) {
			print "\t".$anc->id;
			print "-->";
			print $ind_node->id;
			print "\n";
		    } # End of if verbose

		} # End of if ancestor has id 
	    } # End of if the node has an ancestor
	} # End of if node has id
    } # End of for each IndNode

    $dbh->commit();

    #-----------------------------+
    # ADD TREE ROOT INFO          |
    #-----------------------------+
    # IT may be better to do this after all nodes have been loaded
    # IF THE TREE IS ROOTED GET THE ROOT NODE 
    if ($tree->get_root_node) {
	my $root = $tree->get_root_node;
	# Since all nodes were assigned an id above, using the
	# biosql values, this should return the root id as used
	# in the database
	print "The tree is rooted.\n";
	print "\tRoot:".$root->id."\n";
	# UPDATE tree table
	$statement = "UPDATE tree SET node_id = ".$root->id.
	    " WHERE tree_id = ".$tree_db_id;
	$sth = prepare_sth($dbh,$statement);
	execute_sth($sth);
    } 
    else {
	print "The tree is not rooted.\n";
	
	# QUESTION: WHAT TO ENTER FOR ROOT ID FOR AN UNROOTED TREE

	# THE FOLLOWING WILL ONLY WORK FOR MYSQL
	$statement = "UPDATE tree SET is_rooted = \'FALSE\'".
	    " WHERE tree_id = ".$tree_db_id;
	$sth = prepare_sth($dbh,$statement);
	execute_sth($sth);
	
    }
    $dbh->commit();

    #-----------------------------+
    # INCREMENT TreeNum           |
    #-----------------------------+
    $tree_num++;

} 


# End of program
$dbh->disconnect();
print "\n$0 has finished.\n" if $verbose;
exit;

#-----------------------------------------------------------+
# SUBFUNCTIONS                                              |
#-----------------------------------------------------------+

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
    } 
    elsif ((lc($driver) eq 'pg') || ($driver eq 'PostgreSQL')) {
	my $sql = "SELECT currval('${table_name}_pk_seq')";
	my $stmt = $dbh->prepare_cached($sql);
	my $rv = $stmt->execute;
	die "failed to retrieve last ID generated\n" unless $rv;
	my $row = $stmt->fetchrow_arrayref;
	$stmt->finish;
	return $row->[0];
    } 
    else {
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
	"  phyopt.pl -i infile --dsn DSNString";
    my $args = "REQUIRED ARGUMENTS:\n".
	"  --infile       # File to import to the database.\n".
	"  --dsn          # DSN string for connecting to db\n".
	"\n".
	"OPTIONS:\n".
	"  --dbname       # Name of the database to connect to\n".
	"  --host         # Database host\n".
	"  --driver       # Driver for connecting to the database\n".
	"  --dbuser       # Name to log on to the database with\n".
	"  --dbpass       # Password to log on to the database with\n".
	"  --tree         # Name of the tree to import\n".
	"BOOLEANS:\n".
	"  --version      # Show the program version\n".     
	"  --usage        # Show program usage\n".
	"  --help         # Show this help message\n".
	"  --man          # View the full program manual\n".
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

phyimport.pl - Import phylogenetic trees from common file formats

=head1 VERSION

This documentation refers to phyimport version 1.0.

=head1 SYNOPSIS

  USAGE: phyimport.pl -d 'DBI:mysql:database=biosql;host=localhost' 
                      -u UserName -p dbPass -i InFilePath -f InFileFormat 

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

Import tree files files from text common text files into the PhyloDB.

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

=item -i, --infile

Path to the infile to import to the database

=item -f, --format

Format of the input file. Accepted file format options are: 

nexus (C<-f nex>) - L<http://www.bioperl.org/wiki/NEXUS_tree_format>

newick (C<-f newick>) - L<http://www.bioperl.org/wiki/Newick_tree_format>

nhx (C<-f nhx>) - L<http://www.bioperl.org/wiki/New_Hampshire_extended_tree_format>

lintree (C<-f lintree>) -L<http://www.bioperl.org/wiki/Lintree_tree_format>

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

=item --tree

The name of the tree that will be imported. 

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

B<Import single tree nexus format>

The following example would import the tree stored as MyTree.nex with
the name BigTree.

    phyimport -d 'DBI:mysql:database=biosql;host=localhost'
              -u name -p password -t BigTree -i MyTree.nex
              -f nex

=head1 DIAGNOSTICS

The error messages below are followed by descriptions of the error
and possible solutions.

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

When these are present in the environment, you can initialize a database
with the above variables by simply typing phyinit.pl at the command line.

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

The program phyinit.pl is a component of a package of comand line programs
for PhyloDB management. Additional programs include:

=over

=item phyinit.pl

Initialize a PhyloDB database.

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

Started: 05/30/2007

Updated: 08/17/2007

=cut
