--
-- SQL script to create a BioSQL-compliant API on top of the Symgene
-- schema.
--
--
-- $GNF: projects/gi/symgene/src/DB/BS-create-Biosql-usersyns.sql,v 1.5 2003/07/08 22:48:35 hlapp Exp $
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

-- load definitions
@BS-defs-local

--
-- generate file for users to execute
--
set timing off
set heading off
set termout off
set feedback off

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

