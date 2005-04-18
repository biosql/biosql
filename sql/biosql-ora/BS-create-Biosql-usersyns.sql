--
-- SQL script to create a BioSQL-compliant API on top of the Symgene
-- schema.
--
--
-- $GNF: projects/gi/symgene/src/DB/BS-create-Biosql-usersyns.sql,v 1.5 2003/07/08 22:48:35 hlapp Exp $
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

-- load definitions
@BS-defs-local

--
-- generate file for users to execute
--
set timing off
set heading off
set termout off
set feedback off
set lines 200

spool usersyns.sql

SELECT 'CREATE SYNONYM ' || object_name || 
       ' FOR &biosql_owner..' || object_name || ';' 
FROM user_objects 
WHERE object_name NOT LIKE 'SG%'
AND   object_name NOT LIKE '%$%'
AND   object_type in ('SYNONYM', 'VIEW', 'SEQUENCE')
ORDER BY object_type, object_name;

spool off

set timing on
set heading on
set termout on
set feedback on

