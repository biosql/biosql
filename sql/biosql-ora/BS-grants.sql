--
-- SQL script to assign grants to roles as needed.
-- 
-- $GNF: projects/gi/symgene/src/DB/BS-grants.sql,v 1.7 2003/05/02 02:24:44 hlapp Exp $
--

--
-- (c) Hilmar Lapp, hlapp at gnf.org, 2002.
-- (c) GNF, Genomics Institute of the Novartis Research Foundation, 2002.
--
-- You may distribute this module under the same terms as Perl.
-- Refer to the Perl Artistic License (see the license accompanying this
-- software package, or see http://www.perl.com/language/misc/Artistic.html)
-- for the terms under which you may use, modify, and redistribute this module.
-- 
-- THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
-- WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
-- MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
--

@BS-defs-local

set timing off
set heading off
set termout off
set feedback off

spool _grants

--
-- Grants for the SG_USER: read-only on all SG_ views
-- 
SELECT 'GRANT SELECT ON ' || view_name || ' TO &biosql_user;'
FROM user_views
WHERE view_name LIKE 'SG%' AND NOT view_name LIKE 'SGLD%'
;

--
-- also, execute on the SymGene API package(s)
--
SELECT 'GRANT EXECUTE ON ' || object_name || ' TO &biosql_user;'
FROM user_objects
WHERE object_name LIKE 'SGAPI%' AND object_type = 'PACKAGE'
;

--
-- Grants for SG_LOADER: needs insert and update on all API views.
-- 
SELECT 'GRANT SELECT, INSERT, UPDATE ON ' || view_name || ' TO &biosql_loader;'
FROM user_views
WHERE view_name LIKE 'SGLD%'
;

--
-- Grants for SG_ADMIN: needs insert and update on all API views, and also
-- delete on some.
-- 
SELECT 'GRANT DELETE ON ' || view_name || ' TO &biosql_admin;'
FROM user_views
WHERE view_name LIKE 'SGLD%'
;

--
-- Biosql grants for SG_LOADER: needs insert, update, delete on all BS_
-- objects.
-- 
SELECT 'GRANT INSERT, UPDATE, DELETE ON ' || object_name || 
       ' TO &biosql_loader;'
FROM user_objects
WHERE object_name LIKE 'BS_%' 
AND object_name NOT LIKE '%_PK_SEQ'
AND object_type IN ('VIEW','SYNONYM')
;
-- also, we need select on sequences
SELECT 'GRANT SELECT ON ' || object_name || ' TO &biosql_loader;'
FROM user_objects
WHERE object_name LIKE 'BS_%_PK_SEQ' 
AND object_type IN ('SYNONYM','SEQUENCE')
;

--
-- Biosql grants for SG_USER: needs select on all BS_ objects.
-- 
SELECT 'GRANT SELECT ON ' || object_name || ' TO &biosql_user;'
FROM user_objects
WHERE object_name LIKE 'BS_%' 
AND object_name NOT LIKE '%_PK_SEQ'
AND object_type IN ('VIEW','SYNONYM')
;

spool off

set timing on
set heading on
set termout on
set feedback on

start _grants.lst


