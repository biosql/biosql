--
-- This SQL script is to migrate the Bioentry table from the pre-Singapore
-- Oracle version of the BioSQL schema to the so-called Singapore version.
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
-- $GNF: projects/gi/symgene/src/sql/migrate/singapore/migrate-bioentry.sql,v 1.1 2003/05/02 02:08:27 hlapp Exp $
--

--
-- (c) Hilmar Lapp, hlapp at gnf.org, 2003.
-- (c) GNF, Genomics Institute of the Novartis Research Foundation, 2003.
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

--
-- Add the division column to Bioentry.
--
PROMPT Migrating division from Biosequence to Bioentry
PROMPT     - add column to Bioentry

ALTER TABLE SG_Bioentry ADD (
	Division             VARCHAR2(6) DEFAULT 'UNK' NULL
);

--
-- Migrate the values from Biosequence
--
PROMPT     - migrate data

UPDATE SG_Bioentry e SET
	Division = (
		SELECT Division FROM SG_Biosequence s
		WHERE s.Ent_Oid = e.Oid
	)
;

COMMIT;

--
-- drop the old column on Biosequence
--
PROMPT     - drop column on Biosequence

ALTER TABLE SG_Biosequence DROP COLUMN Division;

