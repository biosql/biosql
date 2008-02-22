--
-- SQL script to create the SYMGENE/BioSQL database, views, and API from
-- scratch.
--
--
-- $Id$
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

-- 1) login as DBA
--connect &sysdba/&dbapwd as sysdba

-- 2) create the tablespaces
--@BS-create-tablespaces

-- 3) create the schema user
--@BS-create-schema-user

-- 4) Now we're ready to create our own schema. Connect as the schema owner.
--connect &biosql_owner/&biosql_pwd

-- 5) create the schema
@BS-DDL

-- 6) create the PL/SQL package API and the load API
@BS-create-API

-- 7) create select-views
@BS-create-views

-- 8) Security: create roles and synonyms, issue grants
@BS-create-roles
@BS-create-synonyms
@BS-grants

-- 9) Biosql API: you need to choose yours, and don't forget to re-run
-- the grants at the end (this is fast and running it twice shouldn't
-- hurt - this way we can have somewhat coherent sections here)
--
-- Bioperl:
@BS-create-Biosql-API  
-- all others (Biojava, etc)
--@BS-create-Biosql-API2
-- create the script for users to run so that they don't need to
-- qualify objects with the schema
@BS-create-Biosql-usersyns
-- don't forget this:
@BS-grants

-- 10) create additional users
--connect &sysdba/&dbapwd as sysdba
--@BS-create-users
--connect &biosql_owner/&biosql_pwd

-- 11) pre-populate database as necessary
-- Note: there is a high chance that the seed data is not suitable for you
-- or is not exactly what you want. Check out the script and make sure you
-- really want the seed data, possibly after editing it, before you uncomment
-- the following command.
--
--@BS-prepopulate-db

-- done, except grants of certain roles to certain users

prompt ==================================================================
prompt Do not forget to grant specific roles to specific users as needed.
prompt ==================================================================
