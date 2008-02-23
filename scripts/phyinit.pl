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
# phyinit.pl - Initialize a PhyloDB database                |
#                                                           |
#-----------------------------------------------------------+
#                                                           |
# CONTACT: JamesEstill_at_gmail.com                         |
# STARTED: 05/30/2007                                       |
# UPDATED: 10/23/2007                                       |
#                                                           |
# DESCRIPTION:                                              | 
#  Initialize a BioSQL database with the phyloinformatics   |
#  tables. This will initially only work with MySQL, but    |
#  other RDMS will be made available. I will also           | 
#  initially assume that BioSQL already exists, and will    |
#  just add the phyloinforamtics tables                     |
#                                                           |
# LICENSE:                                                  |
#  GNU Lesser Public License                                |
#  http://www.gnu.org/licenses/lgpl.html                    |  
#                                                           |
#-----------------------------------------------------------+
#
# THIS SOFTWARE COMES AS IS, WITHOUT ANY EXPRESS OR IMPLIED
# WARRANTY. USE AT YOUR OWN RISK.

# TO DO:
# - Add STDERR to error info print statements
# - PGSQL support
# - Create the non-phylo tables components of BioSQL
# - Run appropriate SQL code in sqldir if desired
#   Can run system cmd like
#   source $sqldie/biosqldb-mysql.sql
#   to establish the SQL schema instead of putting SQL Table create
#   code directly in the perl code.

# NOTE: Variables from command line follow load_ncbi_taxonomy.pl

#-----------------------------+
# INCLUDES                    |
#-----------------------------+
use strict;
use DBI;
use Getopt::Long;

#-----------------------------+
# VARIABLE SCOPE              |
#-----------------------------+
my $VERSION = "1.0";

my $usrname = $ENV{DBI_USER};  # User name to connect to database
my $pass = $ENV{DBI_PASSWORD}; # Password to connect to database
my $dsn = $ENV{DBI_DSN};       # DSN for database connection
my $db;                        # Database name (ie. biosql)
my $host;                      # Database host (ie. localhost)
my $driver;                    # Database driver (ie. mysql)
my $sqldir;                    # Directory that contains the sql to run
                               # to create the tables.
# BOOLEANS
my $help = 0;                  # Display help
my $show_help = 0;             # Display help
my $quiet = 0;                 # Run the program in quiet mode
                               # will not prompt for command line options
my $show_node_id = 0;          # Include the database node_id in the output
my $show_man = 0;              # Show the man page via perldoc
my $show_usage = 0;            # Show the basic usage for the program
my $show_version = 0;          # Show the program version
my $verbose = 0;               # Boolean, but chatty or not

#-----------------------------+
# COMMAND LINE OPTIONS        |
#-----------------------------+
my $ok = GetOptions(# REQUIRED ARGUMENTS
                    "d|dsn=s"    => \$dsn,
                    "u|dbuser=s" => \$usrname,
                    "p|dbpass=s" => \$pass,
		    # ALTERNATIVE TO --dsn
		    "driver=s"   => \$driver,
		    "dbname=s"   => \$db,
		    "host=s"     => \$host,
		    # ADDITIONAL OPTIONS
		    # sqldir will be used when multiple dbases are supported
		    "s|sqldir=s" => \$sqldir,
		    # BOOLEANS
		    "q|quiet"    => \$quiet,
                    "verbose"    => \$verbose,
		    "version"    => \$show_version,
		    "man"        => \$show_man,
		    "usage"      => \$show_usage,
		    "h|help"     => \$show_help,);

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

#-----------------------------+
# DSN STRING                  |
#-----------------------------+
# Alternatives for providing the DSN
# (1) ENV
#     ie. the users .bashrc containsxs
#     DBI_DSN='DBI:mysql:database=biosql;host=localhost'
# (2) Command line string
#     --dsn DBI:mysql:database=biosql;host=localhost
# (3) Command line components
#     --db biosql --host localhost --driver mysql
# A full dsn can be passed at the command line or components
# can be put together

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

# Show variables for debug
print "DEBUG INFO\n" if $verbose;
print "\tUSER:\t$usrname\n" if $verbose;
print "\tDRIVER:\t$driver\n" if $verbose;
print "\tHOST:\t$host\n" if $verbose;
print "\tDB:\t$db\n" if $verbose;
print "\tDSN:\t$dsn\n" if $verbose;

#-----------------------------+
# CREATE DATABASE IF NEEDED   |
#-----------------------------+
# This will currently only work for mysql
# I don't really know how to do this in PostgresSQL or Oracle
if ($driver =~ "mysql") {
    &CreateMySQLDB($usrname, $pass, $db);
}

#-----------------------------+
# CONNECT TO THE DATABASE     |
#-----------------------------+
my $dbh = &ConnectToDb($dsn, $usrname, $pass);

#-----------------------------+
# CHECK FOR EXISTENCE OF      |
# PHYLO TABLES AND CREATE IF  |
# NEEDED                      |
#-----------------------------+
# If the sqldir is passed, then use the SQL there. However
# I decided to also do this as SQL statements within PERL 
# since that is the way I like to do things. JCE

# CHECK FOR EXISTENCE OF TABLES AND WARN USER THAT
# THE DATA IN THE EXISTING TABLES WILL BE LOST
# This provides a place for the user to back out before
# trashing any hard work that may be stored in existing tables.
# For the full database, this could be done by reading the
# tables from the MySQL database.
#
my @TblList = ("tree",
	       "node",
	       "edge",
	       "node_path",
	       "edge_attribute_value",
	       "node_attribute_value"
	       );

my @Tbl2Del;     # Tables that need to be deleted will be pushed to this list
my $Num2Del = 0; # The number of tables that will be deleted 
my $DelInfo = "";     # Info on the 

# DETERMINE IF ANY TABLES WOULD NEED TO BE DELETED
foreach my $Tbl (@TblList) {
    print "Checking table: $Tbl\n" if $verbose;
    if (&does_table_exist($dbh, $Tbl)) {
	$Num2Del++;
	push @Tbl2Del, $Tbl;
	my $NumRecs = &HowManyRecords($dbh, $Tbl);
	$DelInfo = $DelInfo."\t".$Tbl."( ".$NumRecs." Records )\n";
    } # End of does_table_exist
} # End of for each individual table

# WARN THE USER 
# This currently not working on the Mac
# The following gives 0 so this need to 

if ($Num2Del > 0) {

    print "\nThe following tables will be deleted:\n";
    print $DelInfo;
    my $question = "Do you want to delete the existing tables?";
    my $answer = &UserFeedback($question);

    if ($answer =~ "N"){
	print "The database was not create and ".
	    "no changes to the database were made.\n";
	print "Exiting program\n";
	exit;
    } else {

	# TURNING OFF FOREIGN KEYS CHECKS IS A TEMP FIX
	# This allows me to drop tables where 
	# ON DELTE CASCADE has not been set
	$dbh->do("SET FOREIGN_KEY_CHECKS=0;");

	foreach my $Tbl (@Tbl2Del){
	    print "Dropping table: $Tbl\n" if $verbose;
	    my $DropTable = "DROP TABLE $Tbl;";
	    #$dbh->do("DROP TABLE ".$Tbl." CASCADE;");
	    $dbh->do( $DropTable );
	} # End of foreach $Tbl

	$dbh->do("SET FOREIGN_KEY_CHECKS=1;");

    } # End of if answer 

} # End of Num2Del > 0

unless ($sqldir)
{

    my $AddIndex;       # Var to hold the Add Index statements
    
    #-----------------------------+  
    # TREE TABLE                  |
    #-----------------------------+ 
    my $CreateTree = "CREATE TABLE tree (".
	" tree_id INT(10) UNSIGNED NOT NULL auto_increment,".
	" name VARCHAR(32) NOT NULL,".
	" identifier VARCHAR(32),".
	" is_rooted ENUM ('FALSE', 'TRUE') DEFAULT 'TRUE',". 
	" node_id INT(10) UNSIGNED NOT NULL,".
	" PRIMARY KEY (tree_id),".
	" UNIQUE (name)".
	" ) TYPE=INNODB;";
    $dbh->do($CreateTree);
    
    # Add index to tree(node_id)
    # Index needed for Foreign Keys in INNODB tables
    $AddIndex = "CREATE INDEX node_node_id ON tree(node_id);";
    $dbh->do($AddIndex);

    #-----------------------------+
    # NODE                        |
    #-----------------------------+
    print "Creating table: node\n" if $verbose;
    my $CreateNode = "CREATE TABLE node (".
	" node_id INT(10) UNSIGNED NOT NULL auto_increment,".
	" label VARCHAR(255),".
	" tree_id INT(10) UNSIGNED NOT NULL,".
	" bioentry_id INT(10) UNSIGNED,".
	" taxon_id INT(10) UNSIGNED,".
	" left_idx INT(10) UNSIGNED,".
	" right_idx INT(10) UNSIGNED,".
	" PRIMARY KEY (node_id),".
	" UNIQUE (label,tree_id),".
	" UNIQUE (left_idx,tree_id),".
	" UNIQUE (right_idx,tree_id)".
	" ) TYPE=INNODB;";
    $dbh->do($CreateNode);
    
    $AddIndex = "CREATE INDEX node_tree_id ON node(tree_id);";
    $dbh->do($AddIndex);

    $AddIndex = "CREATE INDEX node_bioentry_id ON node(bioentry_id);";
    $dbh->do($AddIndex);

    $AddIndex = "CREATE INDEX node_taxon_id ON node(taxon_id);";
    $dbh->do($AddIndex);

    #-----------------------------+
    # EDGES                       |
    #-----------------------------+
    print "Creating table: edge\n" if $verbose;
    my $CreateEdge = "CREATE TABLE edge (".
	" edge_id INT(10) UNSIGNED NOT NULL auto_increment,".
	" child_node_id INT(10) UNSIGNED NOT NULL,".
	" parent_node_id INT(10) UNSIGNED NOT NULL,".
	" PRIMARY KEY (edge_id),".
	" UNIQUE (child_node_id,parent_node_id)".
	" ) TYPE=INNODB;";
    $dbh->do($CreateEdge);

    $AddIndex = "CREATE INDEX edge_parent_node_id ON edge(parent_node_id)";
    $dbh->do($AddIndex);
    
    #-----------------------------+
    # NODE PATH                   |
    #-----------------------------+
    print "Creating table: node_path\n" if $verbose;
    #Transitive closure over edges between nodes
    my $CreateNodePath = "CREATE TABLE node_path (".
	" child_node_id INT(10) UNSIGNED NOT NULL,".
	" parent_node_id INT(10) UNSIGNED NOT NULL,".
	" path TEXT,".
	" distance INTEGER,".
	" PRIMARY KEY (child_node_id,parent_node_id,distance)".
	" ) TYPE=INNODB;";
    $dbh->do($CreateNodePath);

    $AddIndex = "CREATE INDEX node_path_parent_node_id ON".
	" node_path(parent_node_id)";
    $dbh->do($AddIndex);

    #-----------------------------+
    # EDGE ATTRIBUTES             |
    #-----------------------------+
    print "Creating table: edge_attribute_value\n" if $verbose;
    my $CreateEdgeAtt = "CREATE TABLE edge_attribute_value (".
	" value text,".
	" edge_id INT(10) UNSIGNED NOT NULL,".
	" term_id INT(10) UNSIGNED NOT NULL,".
	" UNIQUE (edge_id,term_id)".
	" ) TYPE=INNODB;";
    $dbh->do($CreateEdgeAtt);

    $AddIndex = "CREATE INDEX ea_val_term_id ON edge_attribute_value(term_id)";
    $dbh->do($AddIndex);
    
    #-----------------------------+
    # NODE ATTRIBUTE VALUES       |
    #-----------------------------+
    print "Creating table: node_attribute_value\n" if $verbose;
    my $CreateNodeAtt = "CREATE TABLE node_attribute_value (".
	" value text,".
	" node_id INT(10) UNSIGNED NOT NULL,".
	" term_id INT(10) UNSIGNED NOT NULL,".
	" UNIQUE (node_id,term_id)".
	" ) TYPE=INNODB;";
    $dbh->do($CreateNodeAtt);

    $AddIndex = "CREATE INDEX na_val_term_id ON node_attribute_value(term_id)";
    $dbh->do($AddIndex);

    #-----------------------------+
    # SET FOREIGN KEY CONSTRAINTS |
    #-----------------------------+
    print "Adding Foreign Key Constraints.\n" if $verbose;
    my $SetKey; # Var to hold the Set Key SQL string

    # May want to add ON DELETE CASCADE to these so
    # that I can DROP tables later


    # The inability to DEFER foreign KEYS with INNODB is a
    # problem late when trying to add node_id in PhyImport
    # I will attempt to remove this foreign key and see
    # if this fixes things JCE -- 06/06/2007
    $SetKey = "ALTER TABLE tree ADD CONSTRAINT FKnode".
	" FOREIGN KEY (node_id) REFERENCES node (node_id);";
# Deferarable foreign keys are not supported under MySQL InnoDB tables
# this causes problems with 
#	" DEFERRABLE INITIALLY DEFERRED;"; 
    $dbh->do($SetKey);
    
    $SetKey = "ALTER TABLE node ADD CONSTRAINT FKnode_tree".
	" FOREIGN KEY (tree_id) REFERENCES tree (tree_id);";
    $dbh->do($SetKey);
  
    # The following not working on mysql 5.0 on MacOS10.4 $SetKey =
    $SetKey = "ALTER TABLE node ADD CONSTRAINT FKnode_bioentry".  
	" FOREIGN KEY (bioentry_id) REFERENCES bioentry (bioentry_id);";
    $dbh->do($SetKey);

#    $SetKey = "ALTER TABLE node ADD CONSTRAINT FKnode_taxon".
#	" FOREIGN KEY (taxon_id) REFERENCES taxon (taxon_id);";
#    $dbh->do($SetKey);

    $SetKey = "ALTER TABLE edge ADD CONSTRAINT FKedge_child".
	" FOREIGN KEY (child_node_id) REFERENCES node (node_id)".
	" ON DELETE CASCADE;";
    $dbh->do($SetKey);
    
    $SetKey = "ALTER TABLE edge ADD CONSTRAINT FKedge_parent".
	" FOREIGN KEY (parent_node_id) REFERENCES node (node_id)".
	" ON DELETE CASCADE;";
    $dbh->do($SetKey);

    $SetKey = "ALTER TABLE node_path ADD CONSTRAINT FKnpath_child".
	" FOREIGN KEY (child_node_id) REFERENCES node (node_id)".
	" ON DELETE CASCADE;";
    $dbh->do($SetKey);

    $SetKey = "ALTER TABLE node_path ADD CONSTRAINT FKnpath_parent".
	" FOREIGN KEY (parent_node_id) REFERENCES node (node_id)".
	" ON DELETE CASCADE;";
    $dbh->do($SetKey);

    $SetKey = "ALTER TABLE edge_attribute_value ADD CONSTRAINT FKeav_edge".
	" FOREIGN KEY (edge_id) REFERENCES edge (edge_id)".
	" ON DELETE CASCADE;";
    $dbh->do($SetKey);

    $SetKey = "ALTER TABLE edge_attribute_value ADD CONSTRAINT FKeav_term".
	" FOREIGN KEY (term_id) REFERENCES term (term_id);";
    $dbh->do($SetKey);

    $SetKey = "ALTER TABLE node_attribute_value ADD CONSTRAINT FKnav_node".
	" FOREIGN KEY (node_id) REFERENCES node (node_id)".
	" ON DELETE CASCADE;";
    $dbh->do($SetKey);

    $SetKey = "ALTER TABLE node_attribute_value ADD CONSTRAINT FKnav_term".
	" FOREIGN KEY (term_id) REFERENCES term (term_id);";
    $dbh->do($SetKey);


    # Commit changes, This is new as of 06/07/2007 since I
    # had AutoCommit on by default previosly
    $dbh->commit();

} # End of Unless $sqldir
# If sqldir is provided, then just create based on that
# This is better for maintenance since only the SQL
# code would need to be modified

# PRINT EXIT STATUS AND CLOSE DOWN SHOP
print "\nThe database $db has been initialized.\n";
$dbh->disconnect;

exit;

#-----------------------------------------------------------+
# SUBFUNCTIONS                                              |
#-----------------------------------------------------------+
# I will try to use the database connection code from the
# existing BioSQL PERL code.

sub ConnectToDb {
    my ($cstr) = @_;
    return connect_to_mysql(@_) if $cstr =~ /:mysql:/i;
    return ConnectToPg(@_) if $cstr =~ /:pg:/i;
    die "can't understand driver in connection string: $cstr\n";
}

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

sub CreateMySQLDB {
    #-----------------------------+
    # CREATE MySQL DATABASE IF IT |
    # DOES NOT EXIST              |
    #-----------------------------+
    my $CrUser = $_[0];           # User name for creating MySQL DB
    my $CrPass = $_[1];           # User password for creaing MySQL DB
    my $CrDB = $_[2];             # Name of the database to create

    print "Checking status of database\n";
    
    my $ShowDb = "mysqlshow -u $CrUser -p$CrPass";
    my @DbList = `$ShowDb`;
    chomp( @DbList );
    
    my $DbExists = '0';
    
    #-----------------------------+
    # DOES THE DB ALREADY EXIST   |
    #-----------------------------+
    my $IndDb;                     # Individual DB in the mysql DB list
    foreach $IndDb (  @DbList ) { 
	if ( $IndDb =~ /$CrDB/ ) {
	    # Print statements for debug
	    #print "\a";            # Sounds alarm
	    #print "The database does exist.\n";
	    $DbExists = '1';
	} # End of check DbName 
    } # End of For each Individual Database
    
    #-----------------------------+
    # CREATE DB IF NEEDED         |
    #-----------------------------+
    # This currently assumes that $CrUser has the ability to create databases
    unless ($DbExists) {
	print "The database $CrDB does not exist.\n";

	my $Question = "Do you want to create a new database named $CrDB?";
	my $MakeDb =  &UserFeedback ($Question);
	
	if ($MakeDb =~ "Y"){
	    my $CreateDBCmd = "mysqladmin create $CrDB -u $CrUser -p$CrPass";
	    system ($CreateDBCmd);
	} else {
	    # If the user does not want to create the databse,
	    # exit the program. This could happen if there was a 
	    # a simple typo in the database name.
	    exit;
	}

    } # End of unless $DbExists
    
} # End of CreateMySQLDB subfunction


sub UserFeedback {
#-----------------------------+
# USER FEEDBACK SUBFUNCTION   |
#-----------------------------+
    
    my $Question = $_[0];
    my $Answer;
    
    print "\n$Question \n";
    
    while (<>)
    {
	chop;
	if ( ($_ eq 'y') || ($_ eq 'Y') || ($_ eq 'yes') || ($_ eq 'YES') )
	{
	    $Answer = "Y";
	    return $Answer;
	}
	elsif ( ($_ eq 'n') || ($_ eq 'N') || ($_ eq 'NO') || ($_ eq 'no') )
	{
	    $Answer = "N";
	    return $Answer;
	}
	else
	{
	    print "\n$Question \n";
	}
    }
    
} # End of UserFeedback subfunction

sub does_table_exist {
#-----------------------------+
# CHECK IF THE MYSQL TABLE    |
# ALREADY EXISTS              |
#-----------------------------+
# CODE MODIFIED FROM
# http://lena.franken.de/perl_hier/databases.html

    my ($dbh, $whichtable) = @_;
    my ($table,@alltables,$found);
    @alltables = $dbh->tables();
    $found = 0;
    foreach $table (@alltables) {
	# Since the schema name may be returned as a prefix
	# we may need to  strip the schema name
	if ( $table =~ m/(.*)\.(.*)/ ){
	    # $table in the form of 'biosql'.'node'
	    $found=1 if ($2 eq "`".$whichtable."`");
	}
	else {
	    # $table in the form of 'node'
	    $found=1 if ($table eq "`".$whichtable."`");
	}
    } # End of for each table in the array alltables
    # return true if table was found, false if table was not found
    return $found;
}

sub HowManyRecords {
#-----------------------------+
# COUNT HOW MANY RECORDS      |
# EXIST IN THE MYSQL TABLE    |
#-----------------------------+
# CODE FROM
# http://lena.franken.de/perl_hier/databases.html

    my ($dbh, $whichtable) = @_;
    #my ($whichtable) = @_;
    my ($result,$cur,$sql,@row);

    $sql = "select count(*) from $whichtable";
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
	"  phyinit.pl";
    my $args =       "REQUIRED ARGUMENTS:\n".
      "  --dsn        # The DSN string for the DB connection\n".
      "  --dbuser     # User name to connect with\n".
      "  --dbpass     # User password to connect with\n".
      "ALTERNATIVE TO --dsn:\n".
      "  --driver     # DB Driver \"mysql\", \"Pg\", \"Oracle\"\n". 
      "  --dbname     # Name of database to use\n".
      "  --host       # Host to connect with (ie. localhost)\n".
      "ADDITIONAL OPTIONS:\n".
      "  --sqldir     # SQL Dir that contains the SQL to create tables\n".
      "  --quiet      # Run the program in quiet mode.\n".
      "  --verbose    # Run the program with maximum output\n".
      "ADDITIONAL INFORMATION:\n".
      "  --version    # Show the program version\n".     
      "  --usage      # Show program usage\n".
      "  --help       # Show a short help message\n".
      "  --man        # Show full program manual\n";
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

phyinit.pl - Initialize a PhyloDB database.

=head1 VERSION

This documentation refers to phyinit version 1.0.

=head1 SYNOPSIS
  
  USAGE: phyinit.pl -d 'DBI:mysql:database=biosql;host=localhost' 
                    -u UserName -p dbPass

      REQUIRED ARGUMENTS:
        --dsn        # The DSN string for the DB connection
        --dbuser     # User name to connect with
        --dbpass     # User password to connect with
      ALTERNATIVE TO --dsn:
        --driver     # DB Driver "mysql", "Pg", "Oracle" 
        --dbname     # Name of database to use
        --host       # Host to connect with (ie. localhost)
      ADDITIONAL OPTIONS:
        --sqldir     # SQL Dir that contains the SQL to create tables
        --quiet      # Run the program in quiet mode.
	--verbose    # Run the program with maximum output
      ADDITIONAL INFORMATION:
	--version    # Show the program version     
	--usage      # Show program usage
        --help       # Show a short help message
	--man        # Show full program manual

=head1 DESCRIPTION

Initialize the PhyloDB table in a BioSQL database. 
All required tables and foreign keys will be created.
The user will be warned before any existing data is deleted. 
This will initially only work with MySQL, but other databases drivers will 
later be made available with the driver argument.

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

=item -s, --sqldir

Directory containing the sql code for PhyloDB initialization.

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

B<The --dsn argument>

Example initializing a database using the --dsn argument. 
You will be prompted for the user
password when one is not provided at the command line. You would of course
replace name with your user name.

    phyinit.pl -u name --dsn 'DBI:mysql:database=biosql;host=localhost'

B<Command line alternative to --dsn>

Creating the same database as above using the dsn components passed
at the comand line. 

    phyinit.pl -u name --host localhost --dbname biosql --driver mysql

=head1 DIAGNOSTICS

The known error messages below are followed by possible descriptions of
the error and possible solutions:

=over 2

=item B<C<DBD::mysql::db do failed: Can't create table 
'./biosql/#sql-d2_b.frm' (errno: 150) at ./phyinit.pl 
line 416, line 1.>>

B<Description:> MySQL Error messages that make reference to errno: 150 are 
related to problems with foreign keys. 
This will occur when you attempt to initialize the PhyloDB tables in a database
database that does not already contain a BioSQL schema.

B<Solution:> Run the proper SQL script to create the BioSQL database.

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

When these are present in the environment, you can initialize a database
with the above variables by simply typing phyinit.pl at the command line.

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

=item *
Currently assumes that a valid BioSQL schema exists for the 
database named. There is currently not check for complience to 
this restriction.

=back

Please report additional problems to 
James Estill E<lt>JamesEstill at gmail.comE<gt>

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

Started: 05/30/2007

Updated: 08/17/2007

=cut
