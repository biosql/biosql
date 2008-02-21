--
-- SQL script to create the SYMGENE/BioSQL schema owner.
--
-- $GNF: projects/gi/symgene/src/DB/BS-create-schema-user.sql,v 1.4 2003/05/02 02:24:44 hlapp Exp $
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

--
-- Definitions for tablespaces and role.
-- 

@BS-defs-local.sql

--
-- The owner of the schema.
--
CREATE USER &biosql_owner
       PROFILE "DEFAULT" IDENTIFIED BY "&biosql_pwd"
       DEFAULT TABLESPACE &biosql_data
       TEMPORARY TABLESPACE "TEMP" ACCOUNT UNLOCK
       QUOTA UNLIMITED ON &biosql_data
       QUOTA UNLIMITED ON &biosql_index
       QUOTA UNLIMITED ON &biosql_lob
;
GRANT &schema_creator TO &biosql_owner;



