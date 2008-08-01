#
# By Peter Eisentraut
# See http://people.planetpostgresql.org/peter/index.php?/archives/18-Readding-implicit-casts-in-PostgreSQL-8.3.html
# for context and usage. The output of the script is included here as well.
#
psql82="psql -p 5433"
psql83="psql -p 5432"

query="SELECT DISTINCT ON (castfunc) castsource, casttarget, castfunc::regprocedure, castcontext FROM pg_cast WHERE castcontext <> 'e' ORDER BY castfunc, 1, 2, 3"

diff <($psql82 -At -F ':' -c "$query") <($psql83 -At -F ':' -c "$query") | fgrep '<' | sed 's/^..//' \
| while IFS=':' read SOURCE TARGET FUNC CONTEXT; do
    case $CONTEXT in
	i) c='IMPLICIT';;
	a) c='ASSIGNMENT';;
    esac
    source_out_proc=$($psql83 -At -c "SELECT typoutput FROM pg_type WHERE oid = $SOURCE")
    target_in_proc=$($psql83 -At -c "SELECT typinput FROM pg_type WHERE oid = $TARGET")
    source_name=$($psql83 -At -c "SELECT $SOURCE::regtype;")
    target_name=$($psql83 -At -c "SELECT $TARGET::regtype;")
    echo "CREATE FUNCTION pg_catalog.$FUNC RETURNS $target_name STRICT IMMUTABLE LANGUAGE SQL AS 'SELECT $target_in_proc($source_out_proc(\$1));';"
    echo "CREATE CAST ($source_name AS $target_name) WITH FUNCTION pg_catalog.$FUNC AS $c;"
done
