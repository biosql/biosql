--
-- SQL script to assign grants to roles as needed.
-- 
-- $Id$
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

@BS-defs

--
-- Grants for the SG_USER: read-only on all tables
-- 
set timing off
set heading off
set termout off
set feedback off

spool _grants

SELECT 'GRANT SELECT ON ' || view_name || ' TO &biosql_user;'
FROM user_views
WHERE view_name LIKE 'SG%' AND NOT view_name LIKE 'SGLD%'
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

spool off

set timing on
set heading on
set termout on
set feedback on

start _grants.lst


