#!/usr/bin/perl -w

use strict;

use DBI;
use Net::FTP;
use Getopt::Long;

my ($help, $db, $host, $port, $user, $pass, $driver, $dir, $download);

GetOptions("help" => \$help,
	   "dbname=s" => \$db,
	   "database=s" => \$db,
	   "host=s" => \$host,
	   "port=i" => \$port,
	   "user=s" => \$user,
	   "password=s" => \$pass,
	   "driver=s" => \$driver,
	   "directory=s" => \$dir,
	   "download" => \$download,
	  );

die <<USAGE if $help;
Usage: $0 
          --dbname     # name of database to use
          --database   # synonym for --dbname
          --driver     # "mysql" or "pg", defaults to "mysql"
          --host       # optional: host to connect with
          --port       # optional: port to connect with
          --user       # optional: user name to connect with
          --password   # optional: password to connect with
          --download   # optional: whether to download new NCBI taxonomy data
          --directory  # optional: where to store/look for the data
USAGE

# defaults:
$driver ||= 'mysql';
$dir ||= "./taxdata";
mkdir $dir unless -e $dir;

die "Must supply --db argument!\n" unless $db;

# remove trailing directory separator, if necessary:
$dir =~ s!/$!!;

# go get the files we need:
if ($download) {
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

my $dsn = "dbi:";
if ($driver =~ /mysql/i) {
    $dsn .= "mysql:database=$db";
} elsif ($driver =~ /pg/i) {
    $dsn .= "Pg:dbname=$db";
} else {
    die "Unknown driver: $driver\n";
}

$dsn .= ";host=$host" if $host;
$dsn .= ";port=$port" if $port;

my $dbh = DBI->connect($dsn,
		       $user,
		       $pass,
		       { RaiseError => 1,
			 AutoCommit => 1,
			 PrintError => 1
		       }
		      ) or die $DBI::errstr;

my %sth = (
	   add_tax => q{
INSERT INTO taxon (taxon_id, ncbi_taxon_id, parent_taxon_id,
                   node_rank, genetic_code, mito_genetic_code
                  ) VALUES (?, ?, ?, ?, ?, ?)
},
           upd_tax => q{
UPDATE taxon SET parent_taxon_id = ?, node_rank = ?, genetic_code = ?, mito_genetic_code = ? WHERE taxon_id = ?
},
           del_tax => q{
DELETE FROM taxon WHERE taxon_id = ?
},

	   add_taxname => q{
INSERT INTO taxon_name (taxon_id, name, name_class) VALUES (?, ?, ?)
},
           upd_taxname => q{
UPDATE taxon_name SET taxon_id, name = ?, name_class = ? WHERE id = ?
},
           del_taxname => q{
DELETE FROM taxon_name WHERE id = ?
},

	   get_children => q{
SELECT taxon_id FROM taxon WHERE parent_taxon_id = ?
},
	   set_left => q{
UPDATE taxon SET left_value = ? WHERE taxon_id = ?
},
	   set_right => q{
UPDATE taxon SET right_value = ? WHERE taxon_id = ?
},
	  );

# prepare all our statements
@sth{keys %sth} = map { $dbh->prepare($_) } values %sth;

my @locktables = qw(taxon taxon_name);
# lock all the tables we'll need, if MySQL:
$dbh->do('LOCK TABLES ' . join(", ", map { $_ .= ' WRITE' } @locktables))
    if $driver =~ m/mysql/i;

my @new;
my @old;
my ($ins, $upd, $del, $nas);

##### enter the taxonomy nodes:

@old = @{
    $dbh->selectall_arrayref(q{SELECT taxon_id, ncbi_taxon_id, parent_taxon_id, node_rank, genetic_code, mito_genetic_code FROM taxon ORDER BY taxon_id}) || []
};

open(TAX, "<$dir/nodes.dmp") or die "Couldn't open data file $dir/nodes.dmp: $!\n";
while (<TAX>) {
    push @new, [ (split(/\s*\|\s*/o, $_))[0, 0..2, 6, 8] ];
}
close(TAX);

($ins, $upd, $del, $nas) =
    handle_diffs(\@old,
		 \@new,
		 sub { return $sth{add_tax}->execute(@_) },
		 sub { return $sth{upd_tax}->execute(@_[1..4,0]) },
		 sub { return $sth{del_tax}->execute(@_[0..0]) }
		);

##### rebuild the nested set left/right id':

my $nodectr = 0;
handle_subtree(1);

##### enter the taxonomy names:

open(NAMES, "<$dir/names.dmp") or die "Couldn't open data file $dir/names.dmp: $!\n";

$dbh->do(q{DELETE FROM taxon_name});

while (<NAMES>) {
    my @data = split(/\s*\|\s*/o, $_);
    $sth{add_taxname}->execute(@data[0, 1, 3]);
}
close(NAMES);

# clean up statement/database handles:
for my $sth (values %sth) {
    $sth->finish()
	if (ref($sth) && $sth->{Active});
}

$dbh->do('UNLOCK TABLES') if $driver =~ m/mysql/i;
$dbh->disconnect();

sub handle_subtree {

    my $id = shift;

    $sth{set_left}->execute(++$nodectr, $id);

    $sth{get_children}->execute($id);
    for my $child ( @{$sth{get_children}->fetchall_arrayref()} ) {
	handle_subtree($child->[0]) unless $child->[0] == $id;
    }

    $sth{set_right}->execute(++$nodectr, $id);

}

sub handle_diffs {

    my ($old, $new, $insert, $update, $delete) = @_;

    my ($is, $ds, $us, $na) = (0, 0, 0, 0);

    # we assume $old is already sorted (came from database).

    # we also assume that $old and $new are both arrays of array
    # references, the first elements of which are the unique id's
    
    # we sort $new by id:
    @$new = sort { $a->[0] <=> $b->[0] } @$new;

    my ($o, $n) = (0, 0);
    my ($odone, $ndone) = (0, 0);
    $odone++ unless @$old;
    $ndone++ unless @$new;
    while ($o < @$old || $n < @$new) {
	if ($odone) {
	    # only new's left to add
	    $insert->(@{$new->[$n]}); $is++;
	    $n++;
	} elsif ($ndone) {
	    # only old's left to remove
	    $delete->(@{$old->[$o]}); $ds++;
	    $o++;
	} else {
	    # both $o and $n are still valid
	    my ($oldentry, $newentry) = ($old->[$o], $new->[$n]);
	    if ($oldentry->[0] == $newentry->[0]) {
		# same id; make sure entry data are identical, otherwise update:
		my $ok = 1;
		CHECK : for my $i (1 .. @$oldentry) {
		    unless ( (defined($oldentry->[$i]) && defined($newentry->[$i]) && $oldentry->[$i] eq $newentry->[$i]) ||
			     (!defined($oldentry->[$i]) && !defined($newentry->[$i]))
			   ) {
			$ok = 0; last CHECK;
		    }
		}
		unless ($ok) {
		    $update->(@{$newentry}); $us++;
		} else {
		    $na++;
		}
		$o++; $n++;
	    } elsif ($oldentry->[0] < $newentry->[0]) {
		# old entry to be removed
		$delete->(@{$oldentry}); $ds++;
		$o++;
	    } else {
		# new entry to be added
		$insert->(@{$newentry}); $is++;
		$n++;
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
