#!/usr/local/bin/perl
#
# sql processor for biosql-db
# uses parse::recdescent to make a nested list, each elt preceeded by
# type.
# list is then recursively descended pushing it through a database specific
# processor
#
# yes this could be made more clever, feel free to go ahead...
# TODO - alert user to errors in source sql - currently silent
#
# since most people don't think in lisp, we should maybe convert
# this so that it creates either objects or xml style events + SAX/XSLT
#
# the data structure used for a tree right now is a nested array
# where the first element is always the node type

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
sub cdr {
    my @arr = @{shift || []};
    @arr[1..scalar(@arr)];
}
sub null {
    return [@{shift || []}] ;
}
sub xml {
    my $ir = shift;
    my $c = shift @$ir;
    my @i = @$ir;
    @i = ("<$c>",@i, "</$c>") if @i && $i[0];
    push(@i, "\n") if grep {/^$c$/} qw(stmt);
    push(@i, "\n") if grep {/^$c$/} qw(createtable);
    unshift(@i, "\n") if grep {/^$c$/} qw(coldef);
    return [@i];
}
sub mysql {
    my $ir = shift;
    my $c = shift @$ir;
    my @i = grep { !(/\(/||/\)/) } @$ir;
    push(@i, "\n") if grep {/^$c$/} qw(stmt);
    push(@i, "\n") if grep {/^$c$/} qw(createtable);
    unshift(@i, "\n\t") if grep {/^$c$/} qw(coldef);
    return [@i];
}
sub pg {
    my $ir = shift;
    my $c = shift @$ir;
    my @i = @$ir;
    if ($c eq "comment") {
        $i[0] =~ s/^\#/\-\-\-/;
    }
    if ($c eq "coltype") {
        if ($i[0]->[1]->[0] eq "inttype") {
            # ints don't have size in postgres
            $i[1] = [];
        }
        my $q = $i[2];
        if ($q && $q->[1]) {
            my @qs = @{$q->[1]};
#            print Dumper $q->[1];
#            print Dumper \@qs;
            if (grep {/^auto_increment$/i} map {$_->[1]}@qs) {
                $i[0]->[1] = ['inttype', 'serial'];
                splice(@i,1);
            }
        }
    }
    if ($c eq "texttype") {
        @i = ('text');
    }
    if ($c eq "qualif") {
        $i[0] =~ s/unsigned//i;
    }
    push(@i, "\n") if grep {/^$c$/} qw(stmt);
    push(@i, "\n") if grep {/^$c$/} qw(createtable);
    unshift(@i, "\n\t") if grep {/^$c$/} qw(coldef);
    return [@i];
}
my $target = $opth->{target} || "mysql";
my $transform = \&$target;
sub process {
    @_;
#    &$transform(@_);
}
#$::RD_AUTOACTION = q { ::process([@item]) };
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
   qualifs: qualif(s?)
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
print "\n";
open(F, shift @ARGV);
my $str = join("",<F>);
close(F);
my $rf = $parser->schema($str);
#print Dumper $rf;
my $new = &mydesc($rf);
print $new;

sub mydesc {
    my $r = shift;
    if (ref($r)) {
        if (ref($r) eq "ARRAY") {
#            my @elts = map {mydesc($_)} map {&$transform($_) }@$r;
            my @elts = ();
            if (ref($r->[0])) {
                @elts = map {mydesc($_)} @$r;
            }
            else {
                @elts = map {mydesc($_)} @{&$transform($r)};
            }
            my $str = join(" ", grep {$_} @elts);
            $str =~ s/\n /\n/g;
            return $str;
        }
        else {
            die $r;
        }
    }
    else {
        return $r;
    }
}

sub usage {
    print <<EOM;
transform_sql.pl [-target|t TARGET] <sql-file>

parses (mysql flavour) SQL and transforms the resulting tree through a processor.

available processors:

mysql (for completion)
pg    (postgres)

WARNING: the parser is currently silent on errors in the source sql

EOM

}
