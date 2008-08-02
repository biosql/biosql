#
# By Peter Eisentraut (2008)
# See http://people.planetpostgresql.org/peter/index.php?/archives/18-Readding-implicit-casts-in-PostgreSQL-8.3.html
# for the context. This is the result produced by the also included shell
# script pg83-add-old-casts.sh.
#
# Use at your own risk. Version 8.3+ of PostgreSQL has not been tested yet with
# these casts added. Adding them might make v8.3 work with bioperl-db, but it
# is not tested.
#
# Obviously, DO NOT run this in PostgreSQL prior to v8.3. It's not needed, and
# hence if anything will cause damage.
#
CREATE FUNCTION pg_catalog.text(integer) RETURNS text STRICT IMMUTABLE LANGUAGE SQL AS 'SELECT textin(int4out($1));';
CREATE CAST (integer AS text) WITH FUNCTION pg_catalog.text(integer) AS IMPLICIT;
CREATE FUNCTION pg_catalog.text(smallint) RETURNS text STRICT IMMUTABLE LANGUAGE SQL AS 'SELECT textin(int2out($1));';
CREATE CAST (smallint AS text) WITH FUNCTION pg_catalog.text(smallint) AS IMPLICIT;
CREATE FUNCTION pg_catalog.text(oid) RETURNS text STRICT IMMUTABLE LANGUAGE SQL AS 'SELECT textin(oidout($1));';
CREATE CAST (oid AS text) WITH FUNCTION pg_catalog.text(oid) AS IMPLICIT;
CREATE FUNCTION pg_catalog.text(date) RETURNS text STRICT IMMUTABLE LANGUAGE SQL AS 'SELECT textin(date_out($1));';
CREATE CAST (date AS text) WITH FUNCTION pg_catalog.text(date) AS IMPLICIT;
CREATE FUNCTION pg_catalog.text(double precision) RETURNS text STRICT IMMUTABLE LANGUAGE SQL AS 'SELECT textin(float8out($1));';
CREATE CAST (double precision AS text) WITH FUNCTION pg_catalog.text(double precision) AS IMPLICIT;
CREATE FUNCTION pg_catalog.text(real) RETURNS text STRICT IMMUTABLE LANGUAGE SQL AS 'SELECT textin(float4out($1));';
CREATE CAST (real AS text) WITH FUNCTION pg_catalog.text(real) AS IMPLICIT;
CREATE FUNCTION pg_catalog.text(time with time zone) RETURNS text STRICT IMMUTABLE LANGUAGE SQL AS 'SELECT textin(timetz_out($1));';
CREATE CAST (time with time zone AS text) WITH FUNCTION pg_catalog.text(time with time zone) AS IMPLICIT;
CREATE FUNCTION pg_catalog.text(time without time zone) RETURNS text STRICT IMMUTABLE LANGUAGE SQL AS 'SELECT textin(time_out($1));';
CREATE CAST (time without time zone AS text) WITH FUNCTION pg_catalog.text(time without time zone) AS IMPLICIT;
CREATE FUNCTION pg_catalog.text(timestamp with time zone) RETURNS text STRICT IMMUTABLE LANGUAGE SQL AS 'SELECT textin(timestamptz_out($1));';
CREATE CAST (timestamp with time zone AS text) WITH FUNCTION pg_catalog.text(timestamp with time zone) AS IMPLICIT;
CREATE FUNCTION pg_catalog.text(interval) RETURNS text STRICT IMMUTABLE LANGUAGE SQL AS 'SELECT textin(interval_out($1));';
CREATE CAST (interval AS text) WITH FUNCTION pg_catalog.text(interval) AS IMPLICIT;
CREATE FUNCTION pg_catalog.text(bigint) RETURNS text STRICT IMMUTABLE LANGUAGE SQL AS 'SELECT textin(int8out($1));';
CREATE CAST (bigint AS text) WITH FUNCTION pg_catalog.text(bigint) AS IMPLICIT;
CREATE FUNCTION pg_catalog.text(numeric) RETURNS text STRICT IMMUTABLE LANGUAGE SQL AS 'SELECT textin(numeric_out($1));';
CREATE CAST (numeric AS text) WITH FUNCTION pg_catalog.text(numeric) AS IMPLICIT;
CREATE FUNCTION pg_catalog.text(timestamp without time zone) RETURNS text STRICT IMMUTABLE LANGUAGE SQL AS 'SELECT textin(timestamp_out($1));';
CREATE CAST (timestamp without time zone AS text) WITH FUNCTION pg_catalog.text(timestamp without time zone) AS IMPLICIT;
