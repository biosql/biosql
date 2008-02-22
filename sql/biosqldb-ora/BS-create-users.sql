--
-- SQL script to create the CLONETRAILS users.
--
-- $GNF: projects/gi/symgene/src/DB/BS-create-users.sql,v 1.6 2003/05/02 02:24:44 hlapp Exp $
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

--
-- The Biosql-db reader/loader user for the schema. Note that this is the
-- 'default' user; real users should use their personal login and be granted
-- the respective role.
--
CREATE USER biosql
       PROFILE "DEFAULT" IDENTIFIED BY "biosql"
       DEFAULT TABLESPACE "&biosql_data"
       TEMPORARY TABLESPACE "TEMP" ACCOUNT UNLOCK
;
GRANT &biosql_loader TO biosql;

--
-- This is the schema owner for a test schema which will be more or less
-- empty and only used for the purpose of testing programmatic access
-- (like the bioperl-db test suite). This is such that deleting certain
-- entries for testing purposes does not harm loaded content.
--
CREATE USER biosqltest
       PROFILE "DEFAULT" IDENTIFIED BY "biosql"
       DEFAULT TABLESPACE "&biosql_data"
       TEMPORARY TABLESPACE "TEMP" ACCOUNT UNLOCK
       QUOTA UNLIMITED ON &biosql_data
       QUOTA UNLIMITED ON &biosql_index
       QUOTA UNLIMITED ON &biosql_lob
;
GRANT &biosql_loader TO biosqltest;

--
-- This is the default read-only user.
--
CREATE USER symgene
       PROFILE "DEFAULT" IDENTIFIED BY "symgene"
       DEFAULT TABLESPACE "&biosql_data"
       TEMPORARY TABLESPACE "TEMP" ACCOUNT UNLOCK
;
GRANT &biosql_user TO symgene;
