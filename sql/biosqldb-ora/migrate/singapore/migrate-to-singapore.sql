--
-- This SQL script is to migrate the pre-Singapore Oracle version of the
-- BioSQL schema to the so-called Singapore version (even though it is
-- being finalized a while after the 2003 Hackathon ended).
--
-- Disclaimer: This script and scripts it launches will modify the schema. It
-- will modify and drop tables, indexes, column names, triggers, sequences,
-- and possibly more. YOU SHOULD BACKUP YOUR DATABASE BEFORE RUNNING THIS
-- SCRIPT, or any of the scripts it launches. You should also verify that
-- you can actually restore from your backup. If you fail to properly take
-- a backup that restores the database to its prior status, serious
-- consequences up to and including complete loss of your data may result
-- from the operation of this script. THIS PACKAGE IS PROVIDED WITHOUT ANY
-- WARRANTIES WHATSOEVER. Please read the license under which you may use
-- this script and those that come with it.
--
-- $GNF: projects/gi/symgene/src/sql/migrate/singapore/migrate-to-singapore.sql,v 1.3 2003/05/21 06:47:24 hlapp Exp $
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

-- load definitions first
@BS-defs-local

-- make sure the above works first before you run the whole script! once
-- you've verified that, just comment out the line below.
exit

--
-- if there's any error we better stop and rollback what can be rolled
-- back in order to limit the damage
WHENEVER sqlerror EXIT FAILURE ROLLBACK;

--
-- 1) Roll in the Taxon changes
-- 
@@migrate-taxon

-- Done. If we've got this far, let's commit everything that is still
-- uncommitted (due to the DDL statements, shouldn't be anything actually).
COMMIT;

--
-- 2) Roll in the Ontology changes.
--
@@migrate-ontology

-- Done. If we've got this far, let's commit everything that is still
-- uncommitted (due to the DDL statements, shouldn't be anything actually).
COMMIT;

--
-- 3) Roll in the Reference changes.
--
@@migrate-refs

-- Done. If we've got this far, let's commit everything that is still
-- uncommitted (due to the DDL statements, shouldn't be anything actually).
COMMIT;

--
-- 4) Migrate relationship tables that haven't been migrated yet (i.e.,
-- seqfeature and bioentry relationships). Also, adds the path tables for
-- the transitive closures.
--
@@migrate-rels

-- Done. If we've got this far, let's commit everything that is still
-- uncommitted (due to the DDL statements, shouldn't be anything actually).
COMMIT;

--
-- 5) Migrate the bioentry table. This is basically a column name change,
-- and moving division from Biosequence to Bioentry.
--
@@migrate-bioentry

--
-- 6) Now for table by table changes of column names, or column additions which
-- were not convered yet.
--
@@migrate-colnames

--
-- 7) Add tables that are new but weren't included in any of the steps before
--
@@migrate-add-tables

--
-- Don't forget to remove temporary location or name for now obsoleted tables.
--
PROMPT 
PROMPT ======================================================================
PROMPT You should drop the following tables after you convinced yourself that
PROMPT the migration was successful.
PROMPT ======================================================================
PROMPT

SELECT Table_Name FROM user_tables WHERE Table_Name LIKE 'SGOLD%';
