#!/usr/local/bin/perl
#
# sql processor for biosql-db
# uses parse::recdescent to make a parse tree
#
# list is then recursively descended pushing it through a database specific
# processor
#
# TODO - alert user to errors in source sql - currently silent
#
# main data structure is a tree-node, which has data/type and
# children which are themselves tree-nodes

use Parse::RecDescent;
use Data::Dumper;
use Getopt::Long;
use strict;
#$::RD_HINT = 1;
my $opth = {};
GetOptions($opth,
           "help|h",
           "target|t=s");
if ($opth->{help} || !@ARGV) {
    usage();
    exit 0;
}
my $target = $opth->{target} || "mysql";
my $transform = \&$target;

# ------------------------------------------
# SQL GRAMMAR
# ------------------------------------------

$::RD_AUTOACTION = q { [@item] };
# is there a better way of making it case insensitive?
my $parser = new Parse::RecDescent
  (q{
     schema : stmt(s)
     stmt   : createtable
     stmt   : createindex
     stmt   : insertstmt
     stmt   : comment
     createtable : createkwd tablekwd tableid '(' coldefs ');'
     createindex : createkwd indexkwd indexid onkwd tableid '(' colids ');'
     insertstmt  : insertkwd intokwd tableid '(' colids ')' valueskwd '(' values ');'
     insertstmt  : insertkwd intokwd tableid '(' values ');'
     values: /\'.*\'/
     createkwd: 'CREATE' | 'create'
     tablekwd: 'TABLE'| 'table'
     indexkwd: 'INDEX'| 'index'
     onkwd: 'ON'| 'on'
     intokwd: 'INTO'| 'into'
     insertkwd: 'INSERT' | 'insert'
     valueskwd: 'VALUES' | 'values'
     comment: /#[^\n]*/
     coldefs: coldef(s)
     coldef : cd /\,/ | cd
     cd     : colid coltype | keydef | constraint
     colid  : /\w+/
     indexid: /\w+/
     colids : cj(s?) colid
     cj     : colid /\,/
     tableid: /\w+/
   coltype: maintype size(?) qualifs
   coltype: maintype size(?)
   qualifs: qualif(s)
   maintype: inttype | chartype | varchartype | texttype
   inttype: 'int' | 'integer' | 'INT' | 'INTEGER'
   chartype: 'char' | 'CHAR'
   varchartype: 'varchar' | 'VARCHAR'
   texttype: 'text' | 'longtext' | 'mediumtext' | 'TEXT' | 'LONGTEXT' | 'MEDIUMTEXT'
   size: '(' /\d+/ ')'
   qualif: 'unsigned' | 'not' 'null' | 'auto_increment' | pk
   qualif: 'UNSIGNED' | 'NOT' 'NULL' | 'AUTO_INCREMENT' | pk
   k: 'key' | 'KEY'
   pk: 'primary' 'key'
   pk: 'PRIMARY' 'KEY'
   fk: 'foreign' 'key'
   fk: 'FOREIGN' 'KEY'
   keydef: pk '(' colids ')'
   keydef: k '(' colids ')'
   keydef: fk '(' colid ')' references tableid '(' colid ')'
   references: 'references' | 'REFERENCES'
   constraint: uconstraint
   uconstraint: u '(' colids ')'
   u: 'unique' | 'UNIQUE'
   });

# ------------------------------------------
# read in the input file
# parse it
# process and flatten the tree
# ------------------------------------------
open(F, shift @ARGV);
my $str = join("",<F>);
close(F);
my $rf = $parser->schema($str);
my $tree = node->new(@$rf);
my $flat = &flatten($tree);
print $flat;

# ------------------------------------------
# flatten($node)
# recursively flattens a tree,
# applying $transform processor to
# every node
# ------------------------------------------
sub flatten {
    my $node = shift;
    UNIVERSAL::isa($node, "node") or die("uh oh ", Dumper $node);
    if ($node->is_terminal) {
        return $node->data;
    }
    else {
        my @elts = ();
        &$transform($node);
        @elts = map {flatten($_)} @{$node->children};
        my $str = join(" ", grep {$_} @elts);
        $str =~ s/\n /\n/g;
        return $str;
    }
}

# ------------------------------------------

sub usage {
    print <<EOM;
transform_sql.pl [-target|t TARGET] <sql-file>

parses (mysql flavour) SQL and transforms the resulting tree through a processor.

available processors:

mysql (for completion)
pg    (postgres)

WARNING: the parser is currently silent on errors in the source sql;
check your output is complete

EOM

}
# ------------------------------------------
# node processors.
#
# these are applied to every node, they
# can look down the tree and make
# modifications anywhere beneath them
# ------------------------------------------
sub null {
}
sub xml { # needs work!
    my $node = shift;
    my $type = $node->type;
    my @c = @{$node->children};
    @c = (node->new("<$type>"),@c,  node->new( "</$type>" )) if @c;
    push(@c, new node "\n") if grep {/^$type$/} qw(stmt);
    push(@c, new node "\n") if grep {/^$type$/} qw(createtable);
    unshift(@c, new node "\n") if grep {/^$type$/} qw(coldef);
    $node->children(@c);
}
sub prettify {
    my $node = shift;
    my $type = $node->type;
    my @c = @{$node->children};
    push(@c, node->new("\n")) if $type eq 'stmt';
    push(@c, new node "\n") if grep {/^$type$/} qw(createtable);
    unshift(@c, new node"\n\t") if grep {/^$type$/} qw(coldef);
    $node->children(@c);
}
sub mysql {
    my $node = shift;
    prettify($node);
    1;
}
sub pg {
    my $node = shift;
    prettify($node);
    my $type = $node->type;
    my @c = @{$node->children};
    my $data = $c[0]->data;
    if ($type eq "comment") {
        $data =~ s/^\#/\-\-\-/;
        $c[0]->data($data);
    }
    if ($type eq "coltype") {
        my $q = $c[2]; # get the qualifier
        if ($q && $q->children->[0] && $q->children->[0]->children) {
            my @qs = @{$q->children->[0]->children};
            if (grep {/^auto_increment$/i} map {$_->children->[0]->data}@qs) {
                @c = (new node ['inttype', 'serial']);
            }
        }
        if ($c[0]->children->[0]->type eq "inttype") {
            # ints don't have size in postgres
            splice(@c, 1, 1, (new node "")); # splice out size decl
        }
    }
    if ($type eq "texttype") {
        # turn all funky text types into 'text'
        @c = (new node 'text');
    }
    if ($type eq "qualif") {
        $data =~ s/unsigned//i;
        $c[0]->data($data);
    }
    $node->children(@c);
    1;
}
# ------------------------------------------
# DATA STRUCTURE - tree nodes
# ------------------------------------------
package node;
sub new {
    my $class = shift;
    return undef unless @_;
    if (ref($_[0])) {
        # recdescent deals with (s)
        # by putting extra level of nesting
        unshift(@_, "collection");
    }
    my $self = [shift];
    push(@$self, grep {$_} map {$class->new(ref $_ ? @$_ : $_)} @_);
    bless $self, $class;
    $self;
}
sub type {
    my $self = shift;
    $self->[0] = shift if @_;
    return $self->[0];
}
sub children {
    my $self = shift;
    splice(@$self, 1, scalar(@$self)-1, @_) if @_;
    my @arr = @$self;
    my @rarr = @arr[1..$#arr];
    return [@rarr];
}
sub is_terminal {
    my $self = shift;
    @{$self->children} ? 0:1;
}
sub data {
    my $self = shift;
    $self->is_terminal ? $self->type(@_) : '';
}
1;
