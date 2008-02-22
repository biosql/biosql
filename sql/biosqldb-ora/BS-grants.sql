--
-- SQL script to assign grants to roles as needed.
-- 
-- $GNF: projects/gi/symgene/src/DB/BS-grants.sql,v 1.8 2003/07/08 22:48:35 hlapp Exp $
--

--
-- Copyright 2002-2003 Genomics Institute of the Novartis Research Foundation
-- Copyright 2002-2008 Hilmar Lapp
-- 
--  This file is part of BioSQL.
--
--  BioSQL is free software: you can redistribute it and/or modify it
--  under the terms of the GNU Lesser General Public License as
--  published by the Free Software Foundation, either version 3 of the
--  License, or (at your option) any later version.
--
--  BioSQL is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU Lesser General Public License for more details.
--
--  You should have received a copy of the GNU Lesser General Public License
--  along with BioSQL. If not, see <http://www.gnu.org/licenses/>.
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
-- Biosql grants for SG_LOADER: needs insert, update, delete on all views
-- and synonyms that don't follow the SG% convention.
-- 
SELECT 'GRANT INSERT, UPDATE, DELETE ON ' || object_name || 
       ' TO &biosql_loader;'
FROM user_objects
WHERE object_name NOT LIKE 'SG_%' 
AND   object_name NOT LIKE '%$%'
AND   object_name NOT LIKE '%_PK_SEQ'
AND   object_type IN ('VIEW','SYNONYM')
;
-- also, we need select on sequences
SELECT 'GRANT SELECT ON ' || object_name || ' TO &biosql_loader;'
FROM user_objects
WHERE object_name LIKE '%_PK_SEQ' 
AND object_type IN ('SYNONYM','SEQUENCE')
;

--
-- Biosql grants for SG_USER: needs select on all views and synonyms
-- that don't follow the SG% convention.
-- 
SELECT 'GRANT SELECT ON ' || object_name || ' TO &biosql_user;'
FROM user_objects
WHERE object_name NOT LIKE 'SG_%' 
AND   object_name NOT LIKE '%$%'
AND   object_name NOT LIKE '%_PK_SEQ'
AND   object_type IN ('VIEW','SYNONYM')
;

spool off

set timing on
set heading on
set termout on
set feedback on

start _grants.lst


