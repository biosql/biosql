--
-- SQL script to create public synonyms for the schema objects.
-- 
-- $GNF: projects/gi/symgene/src/DB/BS-create-synonyms.sql,v 1.6 2003/05/02 02:24:44 hlapp Exp $
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

spool _syns

--
-- Synonyms for tables and views
-- 
SELECT 'DROP PUBLIC SYNONYM ' || view_name || ';'
FROM user_views WHERE view_name LIKE 'SG%';
SELECT 'CREATE PUBLIC SYNONYM ' || view_name || ' FOR ' || view_name || ';'
FROM user_views WHERE view_name LIKE 'SG%';

--
-- Synonyms for SymGene API package(s)
-- 
SELECT 'DROP PUBLIC SYNONYM ' || object_name || ';'
FROM user_objects
WHERE object_name LIKE 'SGAPI%' AND object_type = 'PACKAGE'
;
SELECT 'CREATE PUBLIC SYNONYM ' || object_name || ' FOR ' || object_name || ';'
FROM user_objects
WHERE object_name LIKE 'SGAPI%' AND object_type = 'PACKAGE'
;

spool off

set timing on
set heading on
set termout on
set feedback on

start _syns.lst
