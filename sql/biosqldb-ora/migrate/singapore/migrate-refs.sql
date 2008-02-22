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
-- $GNF: projects/gi/symgene/src/sql/migrate/singapore/migrate-refs.sql,v 1.1 2003/05/02 02:08:27 hlapp Exp $
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

PROMPT Migrating Reference table and data

-- The main (well, the only) change here is that Document_ID becomes a
-- foreign key to DBXref.
--
-- We'll migrate this by first adding the new column, then migrating the data,
-- populating the new column, and finally dropping the old column.

ALTER TABLE SG_Reference ADD (DBX_Oid INTEGER);

PROMPT Migrating MEDLINE references to DBXrefs

INSERT INTO SG_DBXRef (Accession, Version, DBName)
SELECT Document_ID, 0, 'MEDLINE'
FROM SG_Reference WHERE Document_ID IS NOT NULL
;

UPDATE SG_Reference r SET
	DBX_Oid = (
		SELECT Oid FROM SG_DBXRef d
		WHERE d.DBName    = 'MEDLINE'
		AND   d.Version   = 0
		AND   d.Accession = r.Document_ID
	)
WHERE Document_ID IS NOT NULL
;

PROMPT Dropping Document_ID 

ALTER TABLE SG_Reference DROP UNIQUE (Document_ID);
ALTER TABLE SG_Reference DROP COLUMN Document_ID;

PROMPT Enforcing foreign key constraint and uniqueness

ALTER TABLE SG_Reference ADD (CONSTRAINT XAK1Reference UNIQUE (DBX_Oid));

ALTER TABLE SG_Reference
       ADD  ( CONSTRAINT FKDBX_Ref
              FOREIGN KEY (DBX_Oid)
                             REFERENCES SG_DBXRef (Oid) 
                             ON DELETE CASCADE ) ;
-- Done!
PROMPT Done with Reference.
