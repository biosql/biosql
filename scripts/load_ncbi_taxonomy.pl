#!/usr/bin/perl -w
#
# $Id$
#

=head1 NAME

load_ncbi_taxonomy.pl

=head1 SYNOPSIS

  Usage: load_ncbi_taxonomy.pl
        --dbname     # name of database to use
        --dsn        # the DSN of the database to connect to
        --driver     # "mysql" or "pg", defaults to "mysql"
        --host       # optional: host to connect with
        --port       # optional: port to connect with
        --dbuser     # optional: user name to connect with
        --dbpass     # optional: password to connect with
        --download   # optional: whether to download new NCBI taxonomy data
        --directory  # optional: where to store/look for the data

=head1 DESCRIPTION

This script loads or updates a biosql schema with the NCBI Taxon
Database. There are a number of options to do with where the biosql
database is (i.e., database name, hostname, user for database,
password, database name).

This script may download the NCBI Taxon Database from the NCBI FTP
server on-the-fly (ftp://ftp.ncbi.nih.gov/pub/taxonomy/). Otherwise it
expects the files to be downloaded already.

You can use this script to load taxon data into a fresh instance of
biosql, or to update the taxon content of an already populated biosql
database. Because it updates taxon nodes rather than dumping and
re-inserting them, bioentries referencing those existing taxon nodes
are unaffected. An update will erase all changes you made on taxon
nodes and their names which have an NCBI TaxonID set. Names of nodes
that do not have an NCBI TaxonID will be left untouched.

Note that by convention we re-use the NCBI TaxonID as the primary key
of the taxon table.

=head1 ARGUMENTS

=over

=item --dbname

name of database to use

=item --sid

synonym for --dbname for Oracle folks

=item --dsn

the DSN of the database to connect to, overrides --dbname, --driver,
--host, and --port

=item --driver

the DBD driver, one of mysql, Pg, or Oracle. If your driver is not
listed here, use --dsn instead.

=item --host

optional: host to connect with

=item --port

optional: port to connect with

=item --dbuser

optional: user name to connect with

=item --dbpass

optional: password to connect with

=item --download

optional: whether to download new NCBI taxonomy data, default is no
download

=item --directory

optional: where to store/look for the data, default is ./taxdata

=item --nodelete

Flag meaning don't delete retired nodes.

You may want to specify this if you have sequence records referencing
the retired nodes if they happen to be leafs.  Otherwise you'll get a
foreign key constraint failure saying something like 'child record
found' if there is a bioentry for that species. The retired nodes will
still be printed, so that you can then decide for yourself afterwards
what to do with the bioentries that reference them.

=item --verbose=n

Sets the verbosity level, default is 1.

0 = silent,
1 = print current step,
2 = print current step and progress statistics.

=item --help

print this manual and exit

=item --allow_truncate

Flag to allow for non-transactional TRUNCATE.

This presently applies only to deleting and re-loading taxon names
table. The script will attempt to perform the much faster TRUNCATE
operation instead of a DELETE.  Some RDBMSs, like PostgreSQL, however
prohibit TRUNCATE from within a transactions, because they cannot roll
it back. If this flag is specified, the TRUNCATE will still be
performed, but then outside of a transaction. This means that between
the this operation is done until the names have been fully loaded
there will be no or only partial taxon names for querying, leading to
inconsistent or incomplete answers to queries. This is therefore
disabled by default. Note though that for instance in PostgreSQL
TRUNCATE is several orders of magnitude faster.

=item --chunksize

The number of rows after which to commit and possibly recompute
statistics.

This presently only applies to the nested set rebuild phase. It tries
to address the potentially marked performance degradation in
PostgreSQL while updating the taxon rows. The downside of this
approach is that because computing statistics in PostgreSQL cannot run
within a transaction, partially rebuilt nested set values have to be
committed at regular intervals. You can disable the chunked commits by
supplying a value of 0.

If you run on PostgreSQL and you are not sure about the performance
win, try --chunksize=0 --verbose=2. Watch the performance statistics
during the nested set rebuild phase. If you see a marked decrease in
rows/s over time down to values significantly below 100 rows/s, you
may want to run a chunked rebuild. Otherwise keep it disabled. For
database and query consistency disabling it is generally preferrable.

The default presently is to disable it. A suitable value for
PostgreSQL according to test runs would be 40,000.

=back

=head1 Authors

Aaron Mackey E<lt>amackey at virginia.eduE<gt>

=head1 Contributors

Hilmar Lapp E<lt>hlapp at gmx.netE<gt>

=cut

use strict;

use DBI;
use Net::FTP;
use POSIX;
use Getopt::Long;

####################################################################
# Global defaults or definitions, mostly changeable through commandline
####################################################################
my $help = 0;          # whether to display the help page
my $db;                # the name of the database or schema
my $dsn;               # the full DSN -- will be built if not provided
my $host;              # host name of the server
my $port;              # port to which to connect
my $user;              # the user to connect as
my $pass;              # the password for the user
our $driver = "mysql"; # the DBI driver module
my $dir = "taxdata";   # the download and data directory
my $download = 0;      # whether to download from NCBI first
our $allow_truncate = 0; # whether or not to allow the names delete and reload
                       # to span more than one transaction
my $pgchunk = 40000;   # the number of rows after which to vacuum in the
                       # nested set rebuilding phase
our $chunksize = 0;    # disable by default
our $verbose = 1;      # guess what
our $nodelete = 0;     # whether not to delete retired taxon nodes

# not changeable through command-line:
my %tablemaps = (
		 "mysql" => {
		     "taxon" => "taxon",
		     "taxon_name" => "taxon_name",
		 },
		 "Pg" => {
		     "taxon" => "taxon",
		     "taxon_name" => "taxon_name",
		 },
		 "Oracle" => {
		     "taxon" => "bs_taxon",
		     "taxon_name" => "bs_taxon_name",
		     # we can't truncate on a view ...
		     "taxon_name_table" => "taxon_name",
		 },
		 );
my %tablemap;

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
		    "allow_truncate" => \$allow_truncate,
		    "chunksize=i"=> \$chunksize,
		    "directory=s"=> \$dir,
		    "download"   => \$download,
		    "nodelete"   => \$nodelete,
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
if($dir) {
    mkdir $dir unless -e $dir;
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

# chunksize:
if(! defined($chunksize)) {
    $chunksize = ($driver eq "Pg") ? $pgchunk : 0;
}

# tablemap:
if(exists($tablemaps{$driver})) {
    %tablemap = %{$tablemaps{$driver}};
} else {
    # let's use mysql mapping as the default
    %tablemap = %{$tablemaps{"mysql"}};
}

#
# go get the files we need if download requested
#
download_taxondb($dir) if $download;

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

my $taxontbl = $tablemap{taxon};
my $taxonnametbl = $tablemap{taxon_name};

my %sth = (
	   #
	   # insert/update/delete taxon nodes
	   #
	   add_tax => 
'INSERT INTO '.$taxontbl.' (taxon_id, ncbi_taxon_id, parent_taxon_id, node_rank, genetic_code, mito_genetic_code) VALUES (?, ?, ?, ?, ?, ?)'
	   ,
           upd_tax => 
'UPDATE '.$taxontbl.' SET parent_taxon_id = ?, node_rank = ?, genetic_code = ?, mito_genetic_code = ? WHERE taxon_id = ?'
	   ,
           del_tax => 
'DELETE FROM '.$taxontbl.' WHERE taxon_id = ?'
	   ,
	   #
	   # insert/update/delete taxon names
	   #
	   add_taxname => 
'INSERT INTO '.$taxonnametbl.' (taxon_id, name, name_class) VALUES (?, ?, ?)'
	   ,
           upd_taxname =>  # this is actually not used presently
'UPDATE '.$taxonnametbl.' SET taxon_id, name = ?, name_class = ? WHERE id = ?'
	   ,
           del_taxname =>  # this is actually not used presently
'DELETE FROM '.$taxonnametbl.' WHERE id = ?'
	   ,
	   #
	   # rebuild the nested set values
	   #
	   get_children =>
'SELECT taxon_id, left_value, right_value FROM '.$taxontbl.' WHERE parent_taxon_id = ? ORDER BY ncbi_taxon_id'
	   ,
	   set_nested_set => 
'UPDATE '.$taxontbl.' SET left_value = ?, right_value = ? WHERE taxon_id = ?'
	   ,
	   unset_nested_set => $driver eq "mysql" ?
           # Mysql sometimes is horribly broken. The statement that works for
	   # everybody else is horribly slow in MySQL because it does a
	   # full table scan. Ugh.
['UPDATE '.$taxontbl.' SET left_value = NULL, right_value = NULL WHERE left_value = ?',
 'UPDATE '.$taxontbl.' SET left_value = NULL, right_value = NULL WHERE right_value = ?']
	   :
'UPDATE '.$taxontbl.' SET left_value = NULL, right_value = NULL WHERE left_value = ? OR right_value = ?'
	   ,
	   );

# prepare all our statements
@sth{keys %sth} = map { 
    ref($_) ? [map { $dbh->prepare($_); } @$_] : $dbh->prepare($_); 
} values %sth;

# install the exit handler
END {
    end_work($driver, $dbh);
}

my @new;
my @old;
my ($ins, $upd, $del, $nas);

print STDERR "Loading NCBI taxon database in $dir:\n" if $verbose;

##### enter the taxonomy nodes:

print STDERR "\t... retrieving all taxon nodes in the database\n" if $verbose;

# retrieve all nodes currently in the database
@old = @{
    $dbh->selectall_arrayref(
      'SELECT taxon_id, ncbi_taxon_id, parent_taxon_id, node_rank, '.
	     'genetic_code, mito_genetic_code '.
      'FROM '.$taxontbl.' ORDER BY taxon_id'
			     ) || []
};

print STDERR "\t... reading in taxon nodes from nodes.dmp\n" if $verbose;

# slurp in all nodes from the input nodes dump
open(TAX, "<$dir/nodes.dmp") or
    die "Couldn't open data file $dir/nodes.dmp: $!\n";
while (<TAX>) {
    # this needs to be two instructions rather than combining them into one
    # due to the repeated element 0 getting lost otherwise, at least on
    # perl 5.6.0
    my @row = split(/\s*\|\s*/o, $_);
    push @new, [ @row[0, 0..2, 6, 8] ];
}
close(TAX);

print STDERR "\t... insert / update / delete taxon nodes\n" if $verbose;

# start transaction, possibly lock tables, etc.
begin_work($driver, $dbh);

# taxon has a self-referential foreign key, which we need to defer, remove,
# or whatever
unconstrain_taxon($driver, $dbh);

($ins, $upd, $del, $nas) =
    handle_diffs(\@old,
		 \@new,
		 sub { return $sth{add_tax}->execute(@_) },
		 sub { return $sth{upd_tax}->execute(@_[2..5,0]) },
		 sub { return $sth{del_tax}->execute(@_[0..0]) }
		);

#
# Because the commit will enforce the deferred foreign key constraint on
# parent, it may actually take a while. Therefore, let's indicate what's
# holding us up.
#
print STDERR "\t... (committing nodes)\n" if $verbose;
end_work($driver,$dbh,1);

#
# if this is Postgresql, we need to vacuum analyze here, otherwise the
# following updates will be hideously slow
#
if($driver eq "Pg") {
    print STDERR "\t... (vacuuming)\n" if $verbose;
    $dbh->do("VACUUM ANALYZE taxon");
}

# in case un-constraining it required some special action
constrain_taxon($driver,$dbh);

##### rebuild the nested set left/right id':

print STDERR "\t... rebuilding nested set left/right values\n" if $verbose;

begin_work($driver, $dbh);

my $time = time(); # this is for progress timing
handle_subtree(1);

end_work($driver,$dbh,1);

##### enter the taxonomy names:

print STDERR "\t... reading in taxon names from names.dmp\n" if $verbose;

open(NAMES, "<$dir/names.dmp") or
    die "Couldn't open data file $dir/names.dmp: $!\n";

print STDERR "\t... deleting old taxon names\n" if $verbose;

begin_work($driver,$dbh);

# delete all names for taxon nodes with a NCBI taxonID
delete_ncbi_names($driver, $dbh, $taxontbl, $taxonnametbl,
                  $driver eq "Oracle" ? $tablemap{taxon_name_table} : undef);

print STDERR "\t... inserting new taxon names\n" if $verbose;

my $n = 0;
$time = time();
while (<NAMES>) {
    my @data = split(/\s*\|\s*/o, $_);
    $sth{add_taxname}->execute(@data[0, 1, 3]);
    handle_progress($dbh, \$time, ++$n);
}
close(NAMES);

print STDERR "\t... cleaning up\n" if $verbose;

end_work($driver,$dbh,1);

# clean up statement/database handles:
for my $sth (values %sth) {
    my @stmts = ref($sth) eq "ARRAY" ? @$sth : ($sth);
    foreach (@stmts) {
	$_->finish() if ref($_) && $_->{Active};
    }
}

$dbh->disconnect();

print STDERR "Done.\n" if $verbose;

{
    my $nodectr = 0;
    sub handle_subtree {

	my ($id,$left,$right) = @_;
	my $left_value = ++$nodectr;
	$left = -1 unless $left;
	$right = -1 unless $right;

	$sth{get_children}->execute($id);
	for my $child ( @{$sth{get_children}->fetchall_arrayref()} ) {
	    handle_subtree(@$child) unless $child->[0] == $id;
	}

	my $right_value = ++$nodectr;
	if(($left != $left_value) || ($right != $right_value)) {
	    # if this is an update run, we can't just update to any number we
	    # think is right, because another node that we haven't reached
	    # yet for update may carry this value (left_value and right_value
	    # are constrained for uniqueness)
	    if(($driver eq "mysql") && ref($sth{unset_nested_set})) {
		# ugly mysql
		$sth{unset_nested_set}->[0]->execute($left_value);
		$sth{unset_nested_set}->[1]->execute($right_value);
	    } else {
		$sth{unset_nested_set}->execute($left_value, $right_value);
	    }
	    if(!$sth{set_nested_set}->execute($left_value,
					      $right_value, $id)) {
		die "update of nested set values failed (taxonID: $id): ".
		    $sth{set_nested_set}->errstr;
	    }
	}
	handle_progress($dbh, \$time, floor($nodectr/2), undef, $chunksize);
    }
}

sub handle_diffs {

    my ($old, $new, $insert, $update, $delete) = @_;

    my ($is, $ds, $us, $na) = (0, 0, 0, 0);

    # we assume $old is already sorted (came from database).

    # we also assume that $old and $new are both arrays of array
    # references, the first elements of which are the unique id's
    
    # we sort $new by id:
    @$new = sort { $a->[0] <=> $b->[0] } @$new;

    my $time = time();
    my ($o, $n) = (0, 0);
    my ($odone, $ndone) = (0, 0);
    $odone++ unless @$old;
    $ndone++ unless @$new;
    while ($o < @$old || $n < @$new) {
	handle_progress($dbh, \$time, $n, scalar(@$new));
	if ($odone) {
	    # only new's left to add
	    if(!$insert->(@{$new->[$n]})) {
		die "failed to insert node (".join(";",@{$new->[$n]}).
		    "): ".$dbh->errstr;
	    }
	    $is++; $n++;
	} elsif ($ndone) {
	    # only old's left to remove
            if ($nodelete || (!$delete->(@{$old->[$o]}))) {
                print STDERR "note: node (".
                    join(";",map { defined($_) ? $_ : ""; } @{$oldentry}).
                    ") is retired" if $verbose || (!$nodelete);
                if (!$nodelete) {
                    # SQL statement failed
                    print STDERR "; failed to delete: ".$dbh->errstr;
                }
                print STDERR "\n" if $verbose || (!$nodelete);
            }
	    $ds++; $o++;
	} else {
	    # both $o and $n are still valid
	    my ($oldentry, $newentry) = ($old->[$o], $new->[$n]);
	    if ($oldentry->[0] == $newentry->[0]) {
		# same id; make sure entry data are identical, otherwise update:
		my $ok = 1;
		CHECK : for my $i (1 .. @$oldentry-1) {
		    unless ( (defined($oldentry->[$i]) &&
			      defined($newentry->[$i]) &&
			      $oldentry->[$i] eq $newentry->[$i]) ||
			     (!defined($oldentry->[$i]) &&
			      !defined($newentry->[$i]))
			   ) {
			$ok = 0; last CHECK;
		    }
		}
		unless ($ok) {
		    if(!$update->(@{$newentry})) {
			die "failed to update node (".join(";",@{$newentry}).
			    "): ".$dbh->errstr;
		    }
		    $us++;
		} else {
		    $na++;
		}
		$o++; $n++;
	    } elsif ($oldentry->[0] < $newentry->[0]) {
		# old entry to be removed
                if ($nodelete || (!$delete->(@{$oldentry}))) {
		    print STDERR "note: node (".
			join(";",map { defined($_) ? $_ : ""; } @{$oldentry}).
			") is retired" if $verbose || (!$nodelete);
                    if (!$nodelete) {
                        # SQL statement failed
                        print STDERR "; failed to delete: ".$dbh->errstr;
                    }
                    print STDERR "\n" if $verbose || (!$nodelete);
		}
		$ds++; $o++;
	    } else {
		# new entry to be added
		if(!$insert->(@{$newentry})) {
		    die "failed to insert node (".join(";",@{$newentry}).
			"): ".$dbh->errstr;
		}
		$is++; $n++;
	    }
	}

	if ($o == @$old) {
	    $odone++;
	}

	if ($n == @$new) {
	    $ndone++;
	}
    }
    return ($is, $us, $ds, $na);
}

sub download_taxondb{
    my $dir = shift;
    my $ftp = Net::FTP->new('ftp.ncbi.nlm.nih.gov');
    $ftp->login('anonymous', 'anonymous');
    $ftp->cwd('/pub/taxonomy');
    $ftp->binary;	
    $ftp->get('taxdump.tar.gz', "$dir/taxdump.tar.gz");
    $ftp->quit();

    # unpack them; overwrite previous files, if necessary
    system("gunzip -f $dir/taxdump.tar.gz");
    system("cd $dir ; tar -xf taxdump.tar ; rm -f taxdump.tar");
}

sub delete_ncbi_names{
    my ($driver,$dbh,$taxontbl,$taxonnametbl) = @_;
    $taxontbl = "taxon" unless $taxontbl;
    $taxonnametbl = "taxon_name" unless $taxonnametbl;

    #
    # We purge all taxon names first that belong to NCBI taxa, followed by
    # inserting the new names from scratch.
    #
    # TRUNCATE table in most RDBMSs is considerably faster than DELETE. If
    # the taxon data hasn't been tampered with or added to, we could get
    # away with a TRUNCATE.
    #
    my $truncsql = "TRUNCATE TABLE ".$taxonnametbl;
    my $delsql   = 
	'DELETE FROM '.$taxonnametbl.' WHERE taxon_id IN ('.
	'SELECT taxon_id FROM '.$taxontbl.' t '.
	'WHERE t.ncbi_taxon_id IS NOT NULL)';
    # Check which delete path we need to (can) take. Note that with Pg
    # our hands are tied.
    my $purgesql;
    if((!$allow_truncate) &&
       (($driver eq "Pg") || ($driver eq "Oracle"))) {
	$purgesql = $delsql;
    } else {
	my $row = $dbh->selectall_arrayref('SELECT COUNT(*) FROM '.
					   $taxontbl.
					   ' WHERE ncbi_taxon_id IS NULL');
	# need the full DELETE query?
	$purgesql = ($row && @$row && $row->[0]->[0]) ? $delsql : $truncsql;
    }
    # If this is the full DELETE query, we'll just blast ahead assuming that
    # the RDBMS can do subqueries. If it blows up, we'll deal with that later.
    my ($rv,$opentransaction);
    for(;;) {
	eval {
	    $rv = $dbh->do($purgesql);
	};
	if((!$rv) && ($dbh->errstr =~ /transaction/i)) {
	    # this is probably some RDBMS that wants to run truncate outside
	    # of a transaction, because it can't roll it back
	    end_work($driver, $dbh, 0);
	    if(!$allow_truncate) {
		# resort to a full delete; this allows it to run within a
		# transaction
		$purgesql = $delsql;
		begin_work($driver, $dbh);
	    } else {
		# indicate that we need to re-open the transaction afterwards
		$opentransaction = 1;
	    }
	    next;
	}
	last; # exit otherwise, as there is no simple help to make this succeed
    }
    if($@ || (!$rv)) {
	# This must be MySQL still being in the 19th century of RDBMSs.
	# 25 years after everyone else they implemented subqueries - but this
	# version may not be the latest.
	if($driver ne "mysql") {
	    die "unexpected failure when trying to delete ".
		"existing taxon names (query was '$purgesql'):\n".
		$dbh->errstr();
	}
	# save the ones we want to keep
	$dbh->do('CREATE TEMPORARY TABLE tname_temp AS '.
		 'SELECT tnm.* '.
		 'FROM '.$taxonnametbl.' tnm, '.$taxontbl.' tn '.
		 'WHERE tnm.taxon_id = tn.taxon_id '.
		 'AND tn.ncbi_taxon_id IS NULL');
	# delete all
	$dbh->do('TRUNCATE TABLE '.$taxonnametbl);
	# restore the saved ones
	$dbh->do('INSERT INTO '.$taxonnametbl.' SELECT * FROM tname_temp');
	# whew! isn't there an easier way?
    } elsif($opentransaction) {
	begin_work($driver,$dbh);
    }
}

sub handle_progress{
    my ($dbh, $time, $n, $total, $commit) = @_;
    our $last_n = 0 if (!defined($last_n)) || ($n < $last_n);
    if($n && ($n - 10000 >= $last_n)) {
	my $elapsed = time() - $$time;
	if($verbose > 1) {
	    my $fmt = "\t\t%d";
	    $fmt .= "/%d" if $total;
	    $fmt .= " done (in %d secs, %4.1f rows/s)\n";
	    if($total) {
		printf STDERR $fmt,
		       $n, $total, $elapsed, ($n-$last_n)/($elapsed||1);
	    } else {
		printf STDERR $fmt,
		       $n, $elapsed, ($n-$last_n)/($elapsed||1);
	    }
	}
	if(defined($commit) && ($commit > 0) && 
	   (($n % $commit) <= ($last_n % $commit))) {
	    end_work($driver, $dbh, 1);
	    if($driver eq "Pg") {
		print STDERR "\t\t(vacuuming)\n" if $verbose;
		$dbh->do("VACUUM ANALYZE taxon");
	    }
	    begin_work($driver, $dbh);
	}
	$$time = time() if $elapsed;
	$last_n = $n;
    }
}

sub constrain_taxon{
    my ($driver,$dbh) = @_;

    # The deal is that we get here *after* a commit or rollback, so the
    # transaction in which we deferred or disabled FK checking is already
    # terminated. All we need to take care of here is therefore
    # re-establishing the constraints we removed before in Pg
    if($driver eq "Pg") {
	print STDERR "\t... (re-constraining taxon)\n" if $verbose;
	$dbh->do('SELECT constrain_taxon()');
	# we ignore a possible failure -- maybe we should at least make
	# some noise about it?
    }
}

sub unconstrain_taxon{
    my ($driver,$dbh) = @_;

    # if this is MySQL we need to temporarily disable foreign key constraint
    # checking because MySQL can't defer foreign key validation - ugly
    # (and potentially dangerous as I guess cascading deletes will be disabled
    # while this in effect)
    if($driver eq "mysql") {
	#if(!$dbh->do('SET FOREIGN_KEY_CHECKS=0')) {
	#    warn "failed to disable foreign key checks: ".$dbh->errstr;
	#}
    }
    # if this is PostgreSQL, it can defer foreign key constraints, but it
    # is for some reason still incredibly slow, with performance degrading
    # rapidly and steeply during the upload. We need to remove the foreign
    # key constraint temporarily. Ugly.
    elsif($driver eq "Pg") {
	if(!$dbh->do('SELECT unconstrain_taxon()')) {
	    warn "failed to un-constrain taxon: ".$dbh->errstr;    
	    end_work($driver,$dbh,0);
	    begin_work($driver,$dbh);
	    $dbh->do('SET CONSTRAINTS ALL DEFERRED');
	}
    } 
    # otherwise let's assume we're fine with just deferring FK constraints
    else {
	# turn on deferrable
	$dbh->do('SET CONSTRAINTS ALL DEFERRED');
    }
}

sub begin_work{
    my ($driver, $dbh, $drop_fk) = @_;

    $dbh->begin_work() if $dbh->{AutoCommit};
    if ($driver eq "mysql") {
        # lock all the tables we'll need, if MySQL:
	# do we really need this?
	#my @locktables = qw(taxon taxon_name);
	#$dbh->do('LOCK TABLES ' .
	#	 join(", ", map { $_ .= ' WRITE' } @locktables));
    }
}

sub end_work{
    my ($driver, $dbh, $commit) = @_;

    # skip if $driver or $dbh not set up yet
    return unless $driver && $dbh && $dbh->{Active};
    if ($driver eq "mysql") {
	# make sure unsetting this is reverted
	#$dbh->do('SET FOREIGN_KEY_CHECKS=1');
	# unlock all the tables, if MySQL:
	$dbh->do('UNLOCK TABLES');
    }
    # end the transaction
    my $rv = $commit ? $dbh->commit() : $dbh->rollback();
    if(!$rv) {
	print STDERR ($commit ? "commit " : "rollback ").
	    "failed: ".$dbh->errstr;
    }
    $dbh->disconnect() unless defined($commit);
}
