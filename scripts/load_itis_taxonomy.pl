#!/usr/local/bin/perl -w
#
# $Id$
#
# (c) Hilmar Lapp, hlapp at gmx.net, 2007
# (c) National Evolutionary Synthesis Center (NESCent), 2007
#
# This program may be used, distributed or modified under the same
# terms as Perl itself. Please consult the Perl Artistic License
# (http://www.perl.com/pub/a/language/misc/Artistic.html) for the
# terms under which you may use, modify, or distribute this script.

=head1 NAME

load_itis_taxonomy.pl

=head1 SYNOPSIS

  Usage: load_itis_taxonomy.pl
        --directory  # the directory containing the files in the ITIS download
        --dbname     # name of database to use
        --dsn        # the DSN of the database to connect to
        --driver     # "mysql" or "Pg"
        --host       # optional: host to connect with
        --port       # optional: port to connect with
        --dbuser     # optional: user name to connect with
        --dbpass     # optional: password to connect with
        --download   # optional: whether to download new ITIS taxonomy data
        --schema     # optional: Pg only, load using given schema
        --encoding   # optional: Pg only, client encoding to set

=head1 DESCRIPTION

This script loads or updates a biosql schema with phylodb extension
with the ITIS taxonomy as a phylogenetic trees, one tree for each
kingdom. There are a number of options to do with where the biosql
database is (i.e., database name, hostname, user for database,
password, database name).

At present, this script cannot yet download the ITIS taxonomy from the
ITIS HTTP download page on-the-fly (http://www.itis.gov/downloads/),
because the name of the file contains the date and hence isn't fixed.

Hence, for now you need to manually download the taxonomy. Save the
file named 'itisMSmmddyy.TAR.gz' to disk (where mm, dd, and yy are the
numeric month, day, and year in which the snapshot was taken by ITIS),
decompress it using gunzip, and then un-tar using 'tar xvf
<uncompressed_file>. This will create a directory in which the
individual files constituting the ITIS database reside. Provide this
directory to the --directory option. Make sure you download the
SQLServer version of the ITIS database, *not* the Informix version.

You can use this script to load the taxonomy data into a fresh instance of
biosql. Otherwise an already existing ITIS tree will be deleted first.

=head1 ARGUMENTS

=over

=item --dbname

name of database to use

=item --dsn

the DSN of the database to connect to, overrides --dbname, --driver,
--host, and --port. The default is the value of the DBI_DSN
environment variable.

=item --driver

the DBD driver, one of mysql, or Pg. The Oracle version of BioSQL
currently lacks the phylodb extension. If your driver is not listed
here, use --dsn instead.

=item --host

optional: host to connect with

=item --port

optional: port to connect with

=item --dbuser

optional: user name to connect with. The default is the value of the
DBI_USER environment variable.

=item --dbpass

optional: password to connect with. The default is the value of the
DBI_PASSWORD environment variable.

=item --schema

The schema under which the BioSQL tables reside in the database. For
Oracle and MySQL this is synonymous with the user, and won't have an
effect. PostgreSQL since v7.4 supports schemas as the namespace for
collections of tables within a database.

=item --encoding

The client_encoding to use. At present, this only applies to
PostgreSQL. You may need to set this if you receive errors (or wrong
results) upon loading nodes that have special (non-ASCII) characters
in their labels, such as umlauts. The error message will look similar
to "invalid byte sequence for encoding ...". 

If you have umlauts in labels that come out mangled after loading into
the database, you might want to try setting this to iso_8859_1.

=item --download

this is not supported currently

=item --directory

the directory in which the individual files reside that make up the
ITIS taxonomy database

=item --namespace

the namespace for the ITIS trees, defaults to "ITIS"

=item --verbose=n

Sets the verbosity level, default is 1.

0 = silent,
1 = print current step,

=item --help

print this manual and exit

=back

=head1 Authors

Hilmar Lapp E<lt>hlapp at gmx.netE<gt>

=cut

use strict;

use DBI;
use POSIX;
use Getopt::Long;
use File::Spec;

use constant ITIS_SCHEMA_DDL => "itisMS.sql";
use constant ITIS_TAXONOMIC_UNITS_TABLE => "taxonomic_units";
use constant ITIS_KINGDOMS_TABLE => "kingdoms";

####################################################################
# Global defaults or definitions, mostly changeable through commandline
####################################################################
my $help = 0;          # whether to display the help page
my $db;                # the name of the database or schema
my $dsn = $ENV{DBI_DSN};  # the full DSN -- will be built if not provided
my $host;              # host name of the server
my $port;              # port to which to connect
my $user = $ENV{DBI_USER};     # the user to connect as
my $pass = $ENV{DBI_PASSWORD}; # the password for the user
my $driver;            # the DBI driver module
my $encoding;          # a specific client encoding to enable, if any
my $schema;            # for PostgreSQL, the schema to use, if any
my $namespace = "ITIS";# the namespace for the tree
my $dir;               # the download and data directory
my $download = 0;      # whether to download from itis.gov first
my $verbose = 1;       # guess what

####################################################################
# end of global defaults
####################################################################

my $ok = GetOptions("help"       => \$help,
		    "dbname=s"   => \$db,
		    "sid=s"      => \$db,
		    "database=s" => \$db,
		    "dsn=s"      => \$dsn,
		    "host=s"     => \$host,
		    "port=i"     => \$port,
		    "user=s"     => \$user,
		    "dbuser=s"   => \$user,
		    "password=s" => \$pass,
		    "dbpass=s"   => \$pass,
		    "driver=s"   => \$driver,
                    "schema=s"   => \$schema,
                    "encoding=s" => \$encoding,
                    "namespace=s"=> \$namespace,
		    "directory=s"=> \$dir,
		    #"download"   => \$download,
		    "verbose=i"  => \$verbose,
                   );

#
# erroneous arguments or help page requested?
#
if($help || (!$ok)) {
    system("perldoc $0");
    exit($ok ? 0 : 2);
}

#
# setup / massage / sanity-check arguments
#
# download directory:
if ($dir) {
    #mkdir $dir unless -e $dir;
    # remove trailing directory separator, if necessary:
    $dir =~ s!/$!!;
}
# database name:
die "Must supply --dbname argument!\n" unless $db;

# build DSN if not provided, and parse out driver otherwise
if($dsn) {
    my $dummy;
    ($dummy, $driver) = split(/:/,$dsn);
} else {
    $dsn = "dbi:$driver:";
    my %dbparam = ("mysql"  => "database=",
		   "Pg"     => "dbname=",
		   "Oracle" => ($host || $port) ? "sid=" : "");
    die "unrecognized driver '$driver', consider using the --dsn option\n"
	unless exists($dbparam{$driver});
    $dsn .= $dbparam{$driver}.$db;
    $dsn .= ";host=$host" if $host;
    $dsn .= ";port=$port" if $port;
}

#
# go get the files we need if download requested
#
#download_taxondb($dir) if $download;

#
# now connect and setup the SQL statements
#
my $dbh = DBI->connect($dsn,
		       $user,
		       $pass,
		       { RaiseError => 0,
			 AutoCommit => 1,
			 PrintError => 1,
		       }
		      ) or die $DBI::errstr;

# if this is PostgreSQL and a schema was named, make sure it's in the
# search path
if (($driver eq "Pg") && $schema) {
    $dbh->do("SET search_path TO $schema, public") or die $DBI::errstr;
} 

# if this is PostgreSQL and a client encoding was requested, set it
if (($driver eq "Pg") && $encoding) {
    $dbh->do("SET client_encoding TO $encoding") or die $DBI::errstr;
} 

my %sth = (
    #
    # find namespace
    #
    sel_db => "SELECT biodatabase_id FROM biodatabase WHERE name = ?",
    #
    # insert namespace
    #
    ins_db => "INSERT INTO biodatabase (name) VALUES (?)",
    #
    # find tree
    #
    sel_tree => "SELECT tree_id FROM tree WHERE name =? AND biodatabase_id =?",
    #
    # insert tree
    #
    ins_tree => 
    "INSERT INTO tree (name, is_rooted, node_id, biodatabase_id) "
    ."VALUES (?, ?, ?, ?)",
    #
    # update root node of tree
    #
    upd_tree => "UPDATE tree SET node_id = ? WHERE tree_id = ?",
    #
    # update tree name
    #
    upd_treename => "UPDATE tree SET name = ? WHERE tree_id = ?",
    #
    # insert node
    #
    ins_node => "INSERT INTO node (label, tree_id) VALUES (?, ?)",
    #
    # update node
    #
    upd_node => "UPDATE node SET label = ? WHERE node_id = ?",
    #
    # insert edge
    #
    ins_edge => "INSERT INTO edge (child_node_id, parent_node_id) VALUES (?,?)",
    );

# prepare all our statements
@sth{keys %sth} = map { prepare_sth($dbh,$_); } values %sth;

# install the exit handler
END {
    end_work($dbh);
}

print STDERR "Loading taxonomy in $dir:\n" if $verbose;

# we read the schema structure first from the DDL file so that we
# aren't quite as dependent on the version of the ITIS database schema
# that is currently in effect

print STDERR "\t... reading table structures from schema DDL\n" if $verbose;

my $tabledef = read_table_structures($dir);

# trees need to reside in a namespace, so retrieve it, or create if it
# doesn't exist yet

print STDERR "\t... creating or retrieving namespace $namespace\n" if $verbose;

begin_work($dbh);

execute_sth($sth{sel_db},$namespace);
my $ns_id;
if (my $row = $sth{sel_db}->fetchrow_arrayref) {
    $ns_id = $row->[0];
} else {
    execute_sth($sth{ins_db},$namespace);
    $ns_id = last_insert_id($dbh,"biodatabase",$schema);
}
    
end_work($dbh,1);

# Now start to load the actual data: first the trees, then the
# nodes. We do this in one big transaction, so either all data loads
# successfully or none does.

begin_work($dbh);

# ITIS has one root node for each kingdom, so we create a tree for
# each kingdom, and we'll name the trees according to the kingdoms.
#
# We also create the trees initially with temporary names by prefixing
# the kingdom with underscores. This avoids having to delete existing
# trees first before we know that the data load succeeded. The
# alternative would be to update the existing trees, but that's more
# involved (though it can be done).

print STDERR "\t... loading kingdoms as trees\n" if $verbose;

my %id_map = ();
my %kingdoms = ();
my $fh;

open $fh, "<".File::Spec->catfile($dir, ITIS_KINGDOMS_TABLE)
    or die "unable to open ITIS kingdoms table for reading: $!\n";

while (<$fh>) {
    s/\r//; # SQL Server, so this comes from Windows!
    chomp();
    my @cols = split(/\|/,$_);
    my $tree_name = $cols[$tabledef->{+ITIS_KINGDOMS_TABLE}->{kingdom_name}];
    # create trees first under temporary names by prefixing with underscores
    execute_sth($sth{ins_tree}, "__".$tree_name, 1, 0, $ns_id);
    my $tree_id = last_insert_id($dbh, "tree", $schema);
    # store the trees we created, indexed by the ITIS kingdom ID for
    # later lookup when we load the nodes
    $kingdoms{$cols[$tabledef->{+ITIS_KINGDOMS_TABLE}->{kingdom_id}]} = {
        name => $tree_name,
        tree_id => $tree_id,
    };
}
close($fh);

# proceed to loading the nodes: they are in the taxonomic_units table

print STDERR "\t... loading nodes from taxonomic units table\n" if $verbose;

open $fh, "<".File::Spec->catfile($dir, ITIS_TAXONOMIC_UNITS_TABLE)
    or die "unable to open ITIS taxonomic units table for reading: $!\n";

# we construct the label by simply concatenating all non-empty name
# parts; ITIS provides for 4 parts at most (genus, species, variety,
# strain, I suppose)
my @name_inds = (
    $tabledef->{+ITIS_TAXONOMIC_UNITS_TABLE}->{unit_name1},
    $tabledef->{+ITIS_TAXONOMIC_UNITS_TABLE}->{unit_name2},
    $tabledef->{+ITIS_TAXONOMIC_UNITS_TABLE}->{unit_name3},
    $tabledef->{+ITIS_TAXONOMIC_UNITS_TABLE}->{unit_name4},
    );

# loop over all node records (i.e., all taxonomic units)
while (<$fh>) {
    s/\r//; # SQL Server, so this comes from Windows!
    chomp();
    my @cols = split(/\|/,$_);
    # TSN is the ITIS identifier, and the identifier used for indexing parents
    my $tsn = $cols[$tabledef->{+ITIS_TAXONOMIC_UNITS_TABLE}->{tsn}];
    my $parent = $cols[$tabledef->{+ITIS_TAXONOMIC_UNITS_TABLE}->{parent_tsn}];
    # kingdom_id identifies the kingdoms we loaded first as the trees
    my $kingdom = $cols[$tabledef->{+ITIS_TAXONOMIC_UNITS_TABLE}->{kingdom_id}];
    # concatenate all names that are non-empty, using space as delimiter
    my $label = join(" ", (grep { $_; } @cols[@name_inds]));
    # see whether we have created the node already - if it was
    # referenced earlier as a parent, then we did
    my $node_id = $id_map{$tsn};
    if ($node_id) {
        # was created earlier as a parent placeholder, update the label
        execute_sth($sth{upd_node}, $label, $node_id);
    } else {
        # hasn't been created yet, so do so now and add to ID map
        execute_sth($sth{ins_node}, $label, $kingdoms{$kingdom}->{tree_id});
        $node_id = last_insert_id($dbh, "node", $schema);
        $id_map{$tsn} = $node_id;
    }
    # if we have a non-empty and non-zero parent (ITIS is inconsistent
    # about this), then create an edge between this node as child and
    # the parent
    if ($parent) {
        # if the parent node hasn't been created yet, we need to
        # create a placeholder here without a label (only the node
        # record will have the data needed for the label)
        my $parent_node = $id_map{$parent};
        if (!$parent_node) {
            execute_sth($sth{ins_node}, 
                        undef, 
                        $kingdoms{$kingdom}->{tree_id});
            $parent_node = last_insert_id($dbh, "node", $schema);
            $id_map{$parent} = $parent_node;
        }
        # with parent and child in hand, we can create the edge
        execute_sth($sth{ins_edge}, $node_id, $parent_node);
    } elsif ($label eq $kingdoms{$kingdom}->{name}) {
        # if there is no valid parent, and the name of the node is
        # identical to the name of its kingdom, then this is the root node
        # of the tree
        execute_sth($sth{upd_tree}, $node_id, $kingdoms{$kingdom}->{tree_id});
    }
}
close($fh);

#
# Because the commit will enforce the deferred foreign key constraint on
# parent, it may actually take a while. Therefore, let's indicate what's
# holding us up.
#

print STDERR "\t... (committing nodes)\n" if $verbose;
end_work($dbh,1);

#
# if this is Postgresql, we need to vacuum analyze here, otherwise the
# following updates will be hideously slow
#
if($driver eq "Pg") {
    print STDERR "\t... (vacuuming)\n" if $verbose;
    $dbh->do("VACUUM ANALYZE node");
    $dbh->do("VACUUM ANALYZE edge");
    $dbh->do("VACUUM ANALYZE tree");
}

# Check for existing trees in the same namespace that have names equal
# to the kingdoms we have loaded. Those that we find are old versions
# of those we just loaded; we'll rename them by giving them a special
# prefix, and swap in our new trees by removing their temporary prefix
# from their names.

print STDERR "\t... switching new trees with old ones\n" if $verbose;

begin_work($dbh);

my @to_be_deleted = ();

foreach my $kingdom (values(%kingdoms)) {
    execute_sth($sth{sel_tree}, $kingdom->{name}, $ns_id);
    if (my $row = $sth{sel_tree}->fetchrow_arrayref()) {
        my $old_tree = $row->[0];
        # mark as old by prefixing the name
        execute_sth($sth{upd_treename},"OLD:".$kingdom->{name},$old_tree);
        # also remember as one of those we'll delete in the last step
        push(@to_be_deleted, $old_tree);
    }
    # swap in new tree by removing the leading underscores from the name
    execute_sth($sth{upd_treename},$kingdom->{name},$kingdom->{tree_id});
}

end_work($dbh,1);

# At this point the data has successfully loaded, and the names of old
# trees have been changed to indicate their outdated status. We can
# now delete the old trees without changing the results of searches
# against the new trees.

if (@to_be_deleted) {
    print STDERR "\t... deleting old trees\n" if $verbose;

    foreach my $tree_id (@to_be_deleted) {
        begin_work($dbh);
        print STDERR "\t\t... deleting tree with id=$tree_id\n" if $verbose;
        delete_tree($dbh, $tree_id);
        end_work($dbh,1);
    }

    #
    # if this is Postgresql, we need to vacuum analyze here, otherwise the
    # subsequent queries or updates may be very slow
    if($driver eq "Pg") {
        print STDERR "\t... (vacuuming)\n" if $verbose;
        $dbh->do("VACUUM ANALYZE node");
        $dbh->do("VACUUM ANALYZE edge");
        $dbh->do("VACUUM ANALYZE tree");
    }
}

print STDERR "\t... (cleaning up)\n" if $verbose;

# clean up statement/database handles:
for my $sth (values %sth) {
    $sth->finish() if ref($sth) && $sth->{Active};
}
$dbh->disconnect();

print STDERR "Done.\n" if $verbose;

sub delete_tree{
    my ($dbh,$tree_id) = @_;

    # With cascading deletes enabled on the foreign key constraints we
    # could just simply delete the record from the tree table, but the
    # dependent nodes found by the cascading delete get typically
    # deleted one-by-one, and each one in turn triggers a cascading
    # delete to the edge and to the node_path table. Doing this by
    # hand in 4 straight hits will typically be much faster - of
    # course only if done in the right order (i.e., avoiding cascading
    # deletes).
    my @del_queries = (
        "DELETE FROM node_path WHERE child_node_id IN "
        ."(SELECT node_id FROM node WHERE tree_id = ?)",
        "DELETE FROM edge WHERE child_node_id IN "
        ."(SELECT node_id FROM node WHERE tree_id = ?)",
        "DELETE FROM node WHERE tree_id = ?",
        "DELETE FROM tree WHERE tree_id = ?",
        );
    my $sth;
    foreach my $sql (@del_queries) {
        $sth = prepare_sth($dbh,$sql);
        execute_sth($sth,$tree_id);
    }
}

sub last_insert_id {
    my ($dbh,$table_name,$schema) = @_;
    my $driver = $dbh->{Driver}->{Name};
    if (lc($driver) eq 'mysql') {
        return $dbh->{'mysql_insertid'};
    } else {
        return $dbh->last_insert_id(undef,$schema,$table_name,undef);
    }
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

sub constrain_tree{
    my ($driver,$dbh) = @_;

    # The deal is that we get here *after* a commit or rollback, so the
    # transaction in which we deferred or disabled FK checking is already
    # terminated. All we need to take care of here is therefore
    # re-establishing the constraints we removed before

    if($driver eq "mysql") {
	if(!$dbh->do('SET FOREIGN_KEY_CHECKS=1')) {
	    warn "failed to re-enable foreign key checks: ".$dbh->errstr;
	}
    }
}

sub unconstrain_tree{
    my ($driver,$dbh) = @_;

    # if this is MySQL we need to temporarily disable foreign key constraint
    # checking because MySQL can't defer foreign key validation - ugly
    # (and potentially dangerous as I guess cascading deletes will be disabled
    # while this is in effect)
    if($driver eq "mysql") {
	if(!$dbh->do('SET FOREIGN_KEY_CHECKS=0')) {
	    warn "failed to disable foreign key checks: ".$dbh->errstr;
	}
    }
    # if this is PostgreSQL, it can defer foreign key constraints, so
    # right now there's not much we need to do
    elsif($driver eq "Pg") {
    } 
    # otherwise let's assume we're fine with just deferring FK constraints
    else {
	# turn on deferrable
	$dbh->do('SET CONSTRAINTS ALL DEFERRED');
    }
}

sub begin_work{
    my ($dbh) = @_;

    $dbh->begin_work() if $dbh->{AutoCommit};
}

sub end_work{
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

sub read_table_structures{
    my $dir = shift;
    my %tabledefs = ();
    my $schemadef = File::Spec->catfile($dir,ITIS_SCHEMA_DDL);
    my $fh;
    my $table;
    my $colnum;
    open $fh, "<$schemadef" 
        or die "failed to open $schemadef for reading: $!\n";
    while (<$fh>) {
        s/\r//;
        chomp();
        if ($table) {
            if (/^\s*\)\s*$/) {
                $table = undef;
                next;
            }
            s/^\s*//;
            my @columndef = split(/\s+/,$_);
            my $colname = shift(@columndef);
            $colname =~ s/^\[//;
            $colname =~ s/\]$//;
            $tabledefs{$table}->{$colname} = $colnum;
            $colnum++;
        } else {
            if (/^CREATE TABLE \[(.*)\] /) {
                my @tabledef = split(/\]\.\[/,$1);
                $table = pop(@tabledef);
                $tabledefs{$table} = {};
                $colnum = 0;
            }
        }
    }
    close($fh);
    return \%tabledefs;
}
