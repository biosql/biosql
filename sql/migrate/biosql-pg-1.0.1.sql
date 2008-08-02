--
-- Script for migrating a BioSQL database from version 1.0.0 to 1.0.1.
--
-- You DO NOT need this if you installed BioSQL v1.0.1 or later. This
-- script will not check the installed version - if you run it on a
-- newer version than 1.0.0 you may revert changes made in later
-- versions.
--
-- It is strongly recommended to 1) backup your database first, and 2)
-- to run this script within a transaction so you can roll it back
-- when something goes wrong.
--
-- comments to biosql - biosql-l@open-bio.org 
--
-- ========================================================================
--
-- Copyright 2008 Hilmar Lapp 
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
-- ========================================================================
--

-- we need to drop the RULEs for the table we are altering, unfortunately
DROP RULE rule_dbxref_i ON dbxref;

-- widen the column width constraint on dbxref.accession
ALTER TABLE dbxref ALTER COLUMN accession TYPE VARCHAR(128);

-- recreate the INSERT rule
CREATE RULE rule_dbxref_i
       AS ON INSERT TO dbxref
       WHERE (
       	     SELECT dbxref_id FROM dbxref
	     WHERE accession = new.accession
	     AND   dbname    = new.dbname
	     AND   version   = new.version
	     )
	     IS NOT NULL
       DO INSTEAD NOTHING
;

-- drop the RULEs for the table we are altering
DROP RULE rule_bioentry_i1 ON bioentry;
DROP RULE rule_bioentry_i2 ON bioentry;

-- correspondingly, do the same for bioentry.accession
ALTER TABLE bioentry ALTER COLUMN accession TYPE VARCHAR(128);

-- recreate the RULEs
CREATE RULE rule_bioentry_i1
       AS ON INSERT TO bioentry
       WHERE (
             SELECT bioentry_id FROM bioentry
             WHERE identifier     = new.identifier
             AND   biodatabase_id = new.biodatabase_id
             ) 
	     IS NOT NULL
       DO INSTEAD NOTHING
;
CREATE RULE rule_bioentry_i2
       AS ON INSERT TO bioentry
       WHERE (
       	     SELECT bioentry_id FROM bioentry
	     WHERE accession      = new.accession
	     AND   biodatabase_id = new.biodatabase_id
	     AND   version	  = new.version
	     ) 
	     IS NOT NULL
       DO INSTEAD NOTHING
;
