#!/usr/local/bin/perl -w
#
# $Id$
#
# Script to parse trees from NEXUS files and load them into a BioSQL
# database with the phylodb extension.
#
# Copyright 2006-2007 William Piel, william.piel at yale.edu, 2006
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

parseTreesPG.pl

=head1 SYNOPSIS

  Usage: parseTreesPG.pl <options> <nexus-file>
  Options:
        --dsn        # the DSN of the database to connect to
        --dbuser     # user name to connect with
        --dbpass     # password to connect with

=head1 DESCRIPTION

This script parses trees from a given NEXUS file and loads them into a
BioSQL database with the phylodb extension.

Update methods are currently not implemented.

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

=item -h, --help

print this manual and exit

=back

=head1 Authors

William Piel <william.piel at yale.edu>

=head1 Contributors

Hilmar Lapp <hlapp at gmx.net>

=cut

use strict;
use DBI;
use Getopt::Long;
use constant SQL_DBMS_NAME => 17;
use constant EDGE_ATTR_ONTOLOGY => "Edge Attribute Ontology";

my $usrname = $ENV{DBI_USER};
my $pass = $ENV{DBI_PASSWORD};
my $dsn = $ENV{DBI_DSN};

my $ok = GetOptions("d|dsn=s", \$dsn,
                    "u|dbuser=s", \$usrname,
                    "p|dbpass=s", \$pass,
                    "h|help", sub { system("perldoc $0"); exit(0); });

my $file = shift @ARGV;

#print "file = \'$file\'\n";

if (length($file) == 0) {
  print "Input error! Usage: perl parseTreesPG.pl [nexus-file]\n";
  exit;
}

my $taxaListNum = 1;

my (%taxaList, %treeList, %childDB, %nodeDB, %parentDB, %support, %brlength, %taxonTable);
my ($brlen, $suppt, $output, $i, $treeName, $parentID);

my @impTrees = importTrees($file);

my ($currentTreeNode, %treeFromNode);

my $node = 0;
my @tree;
foreach my $eachtree (@impTrees) { 

	@tree = ($eachtree=~/\'.+\'|[\(\),]{1}|[^\(\,\)]+/g);
	$tree[0] =~ s/[ \t]+$//;
	$treeList{$node} = $tree[0];
	$currentTreeNode = $node;

	parseTree (@tree);
	
	$node++;
}

#for each parent make a list of children
foreach my $chld (keys (%childDB)) {
	$parentDB{$childDB{$chld}} .= ':'."$chld";
}

$file .= ".tr.nex";
open (OUTPUT, ">$file");

#print "#NEXUS\n\nbegin trees;\n\n";
print OUTPUT "#NEXUS\n\nbegin trees;\n\n";


my @sortedKeys = sort by_nums keys(%taxaList);

#print "\t\t$taxaList{$sortedKeys[0]}\t$sortedKeys[0]";
print OUTPUT "\t\t$taxaList{$sortedKeys[0]}\t$sortedKeys[0]";
	
for (my $cnt=1; $cnt < @sortedKeys; $cnt++) {
	#print ",\n\t\t$taxaList{$sortedKeys[$cnt]}\t$sortedKeys[$cnt]";
	print OUTPUT ",\n\t\t$taxaList{$sortedKeys[$cnt]}\t$sortedKeys[$cnt]";
}

#print "\n\t;\n\n";
print OUTPUT "\n\t;\n\n";

foreach my $prtnode (keys (%treeList)) {
	$output = "\ttree ".$nodeDB{$prtnode}." = ";
	my ($nul,@start) = split (':',$parentDB{$prtnode});
	&PrintTree($start[0]);
	$output .= ";";
	
	#print "$output\n";
	print OUTPUT "$output\n";
}

#print "end;\n\n\n";
print OUTPUT "end;\n\n\n";

my %taxaNum;
foreach my $tx (keys (%taxaList)) {
	if ( defined($taxonTable{$tx}) ) {
		$taxaNum{$taxaList{$tx}} = $taxonTable{$tx};
	} else {
		$taxaNum{$taxaList{$tx}} = $tx;
	}
	$taxaNum{$taxaList{$tx}} =~ s/\n//g;
	$taxaNum{$taxaList{$tx}} =~ s/\'//g;
	$taxaNum{$taxaList{$tx}} =~ s/_/ /g;
}

my %nodeConvert;
my $statement;



# =========== FILL DATABASE =============

my $dbh = connect_to_db($dsn,$usrname,$pass);
my ($sth, $rv);

print "\nPre-Fill Root Nodes and Fill Tree Table:\n";
foreach my $tr (keys (%treeList)) {
    $statement = "INSERT INTO tree (name,node_id) VALUES ('$treeList{$tr}',0)";
    #print "$statement\n";
    
    $sth = prepare_sth($dbh,$statement);
    execute_sth($sth);
    
    my $id = last_insert_id($dbh,"tree");
    $statement = "INSERT INTO node (tree_id) VALUES ($id) ";
    $sth = prepare_sth($dbh,$statement);
    execute_sth($sth);

    $id = last_insert_id($dbh,"node");
    #print q[$nodeConvert{]."$tr".q[} = $id;]."\n";
	
    $nodeConvert{ $tr } = $id;
	
    $statement = "UPDATE tree SET node_id = ? WHERE name = ?";
    $sth = prepare_sth($dbh,$statement);
    execute_sth($sth,$id,$treeList{$tr});

    $dbh->commit;
}

print "\nPre-Fill Nodes:\n";

$statement = 
    "INSERT INTO node (tree_id) SELECT tree_id FROM tree WHERE node_id = ?";
$sth = prepare_sth($dbh,$statement);

foreach my $chld (sort {$a <=> $b} (keys (%childDB))) {
    execute_sth($sth,get_tree_root_for_node($chld));

    $nodeConvert{ $chld } = last_insert_id($dbh,"node");
}
$dbh->commit;

print "\nInsert Edges:\n";

$statement = 
    "INSERT INTO edge (parent_node_id, child_node_id) VALUES (?,?)";
my $edge_sth = prepare_sth($dbh,$statement);
$statement =
    "INSERT INTO edge_attribute_value (edge_id, value, term_id) VALUES (?,?,?)";
my $attr_sth = prepare_sth($dbh,$statement);

my $brlen_term = get_term_id($dbh,"branch length");
my $support_term = get_term_id($dbh,"support value");

foreach my $chld (sort {$a <=> $b} (keys (%childDB))) {
    # insert edge
    execute_sth($edge_sth, 
                $nodeConvert{ $childDB{ $chld } }, $nodeConvert{ $chld });
    my $edge_id = last_insert_id($dbh,"edge");

    # insert branch length and support value (if available)
    if ($brlength{$chld}) {
        execute_sth($attr_sth, $edge_id, $brlength{$chld}, $brlen_term);
    }
    if ($support{$chld}) {
        execute_sth($attr_sth, $edge_id, $support{$chld}, $support_term);
    }
}
$dbh->commit;

print "\nUpdate Labeled Nodes:\n";
$statement = "UPDATE node SET label = ? WHERE node_id = ?";
$sth = prepare_sth($dbh,$statement);

foreach my $chld (sort {$a <=> $b} (keys (%childDB))) {
    if ($taxaNum{$nodeDB{$chld}}) {
        execute_sth($sth, $taxaNum{$nodeDB{$chld}}, $nodeConvert{ $chld });
    }
}
$dbh->commit;

my $rd = $sth->finish;
my $rc = $dbh->disconnect;

print "\n\n";

# print "\n\nSupport:\n";
# 
# my %combined = (%support, %brlength);
# foreach my $nd (sort {$a <=> $b} (keys (%combined))) {
# 	print "Branch Length: '$brlength{$nd}' Support Value: '$support{$nd}' -- at node $nd\n";
# }

# print "\n\nTrees:\n";
# 
# foreach my $tr (keys (%treeList)) {
# 	print "$treeList{$tr} begins at node $tr\n";
# }

# print "\n\nTaxa:\n";
# foreach my $chld (sort {$a <=> $b} (keys (%childDB))) {
# 	if ($taxaNum{$nodeDB{$chld}} ne "") {
# 		print "N: $chld T: $taxaNum{$nodeDB{$chld}}\n";
# 	}
# }

# print "\n\nNodes:\n";
# foreach my $chld (sort {$a <=> $b} (keys (%childDB))) {
# 	print "N: $chld P: $childDB{$chld}\n";
# }


close (OUTPUT);

exit;

#==================================
sub by_nums {
	$taxaList{$a} <=> $taxaList{$b};
}

#==================================
sub PrintTree {

	my $cnt = 0;
	my @branches =();

	my ($prtnode) = $_[0];

	if ($parentDB{$prtnode}) {

		@branches = split (':',$parentDB{$prtnode});
		shift (@branches);
		$output .= "(";
		for ($cnt = 0; $cnt < @branches; $cnt++) {
		
			&PrintTree($branches[$cnt]);
			$output .= "," unless ($cnt == (@branches - 1));
		}
		
		$output .= ")";
	}
	
	if ($nodeDB{$prtnode}) {
		$output .= "$nodeDB{$prtnode}";
	}
}


#==================================
sub parseTree {

	(@tree) = @_;

	$i = 0; #position in tree
	$treeName = $tree[$i];
	$nodeDB{$node} = $tree[$i];  #name the root of the tree
	&BuildTree($node);

}




#==================================
sub BuildTree {
	my ($child);
	my ($nodeStart);
	my ($cumeNames);
	my ($NewName, $numEquiv);
	
	$parentID = $_[0];
	$i++;
	
	
	if ($tree[$i] eq "(") {
	
		#New internal node was found
		$child = &NewNode ();
		$nodeStart = $child;
	
		#Examine each of the remaining branches at this node
		while ($tree[$i] ne ")") {
		  $NewName = &BuildTree($child);
		  $cumeNames = "$cumeNames $NewName";
		  $i++;  #skip over the comma
		}
		
		#We have encountered a bootstrap value
		if (($tree[$i+1] ne ",")&&($tree[$i+1] ne ")")) {
		
			$tree[$i+1] =~ s/\n//;
			$cumeNames =~ s/  / /g;
			my @bits = split(/ /, $cumeNames);
			@bits = sort (@bits);
			$cumeNames = "@bits";
			#$descendants{$child} = $cumeNames;
			
			if ($tree[$i+1] =~ m/^([^:]*):([^:]*)$/) {
				$support{$nodeStart} = "$1";
				$brlength{$nodeStart} = "$2";
			} elsif ($tree[$i+1] ne "") {
				$support{$nodeStart} = "$tree[$i+1]";
			}
			
			$i++;  #skip over the bootstrap
			return($cumeNames);
		 }
		
	  } else {
	
		#Else, new taxon found
	
		#Remove branchlengths for taxa
	
		if ($tree[$i] =~ m/^([^:]+):(\d+\.?\d*)$/) {
			$tree[$i] = "$1";
			$brlength{$node + 1} = "$2";
		}
	
		if ($taxaList{$tree[$i]}) {
			$numEquiv = $taxaList{$tree[$i]};
		} else {
			$taxaList{$tree[$i]} = $taxaListNum;
			$numEquiv = $taxaListNum;
			$taxaListNum++;
		}
		
		
		#&NewNode ($tree[$i]);
		&NewNode ($numEquiv);
		
		#return($tree[$i]);
		return($numEquiv);
	  }
}


#==================================
sub NewNode {

  my $name = $_[0];


#Create a new record in table "nodeDB"

  $node++;
  $nodeDB{$node} = $name;
  $treeFromNode{$node} = $currentTreeNode;
  
#Create new record in table "childDB" so as to link the parent node with the new child node

  $childDB{$node} = $parentID;
 
  return ($node);

}

#==============================================================
sub importTrees {

    my($filename) = @_;
    my @impTrees =();
    my $cnt = 0;
    my $tree_filehandle;
    

    unless(open($tree_filehandle, $filename)) {
        print "Cannot open file $filename\n";
        exit;
    }
	
    while(<$tree_filehandle>) {

        # Discard lines until BEGIN TREES;
        (1 .. /^\s*\t*BEGIN TREES;/i ) and next;
        
        if (/^\s*\t*TRANSLATE/i) {
        	while (<$tree_filehandle>) {
        		while ($_ =~ m/[\s\t]+(\d+)[\s\t]+([^\,]+)[\,\s\t]?/g) {
        			#print "$1 = $2\n";
        			$taxonTable{$1} = "$2";
        		}
        		/;/ and last;
        	}
        }
        
    	if (/^\s*\t*TREE\s*\t*\**\s*\t*(.+)\s*\t*=\s*\t*(\[.*\])*\s*\t*(.+);\s*\t*$/i) {
    		$impTrees[$cnt] = "$1$3\n";
    		$cnt++;
    	}
    	
    	/^\s*\t*END/i and last;
    }
	return(@impTrees);
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


#==============================================================
sub last_insert_id {
	my $dbh = shift;
	my $table_name = shift;
	my $driver = $dbh->get_info(SQL_DBMS_NAME);
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

sub get_term_id {
    my $dbh = shift;
    my $term_name = shift;
    my $sel_term = 
        "SELECT t.term_id FROM term t, ontology o "
        ."WHERE t.ontology_id = o.ontology_id AND t.name = ? AND o.name = ?";
    my $sel_ont = "SELECT ontology_id FROM ontology WHERE name = ?";
    my $ins_ont = "INSERT INTO ontology (name) VALUES (?)";
    my $ins_term = "INSERT INTO term (name, ontology_id) VALUES (?, ?)";
    # does term exist?
    my $sth = prepare_sth($dbh,$sel_term);
    execute_sth($sth, $term_name, EDGE_ATTR_ONTOLOGY);
    if (my $row = $sth->fetchrow_arrayref) {
        return $row->[0];
    }
    # Term does not exist, need to create. Does ontology exist?
    my $ont_id;
    $sth = prepare_sth($dbh,$sel_ont);
    execute_sth($sth,EDGE_ATTR_ONTOLOGY);
    if (my $row = $sth->fetchrow_arrayref) {
        $ont_id = $row->[0];
    } else {
        my $ins_sth = prepare_sth($dbh,$ins_ont);
        execute_sth($ins_sth,EDGE_ATTR_ONTOLOGY);
        $ont_id = last_insert_id($dbh,"ontology");
    }
    # create term
    $sth = prepare_sth($dbh,$ins_term);
    execute_sth($sth,$term_name,$ont_id);
    # commit and return the ID of the term
    my $term_id = last_insert_id($dbh,"term");
    $dbh->commit;
    return $term_id;
}

# get the primary key of the root node, given a node number of a node from the
# same tree
sub get_tree_root_for_node {
    my $node_number = shift;
    return $nodeConvert{$treeFromNode{$node_number}};
} 
