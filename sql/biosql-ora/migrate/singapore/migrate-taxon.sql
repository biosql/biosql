--
-- This SQL script migrates the Taxon part of the pre-Singapore Oracle version
-- of the BioSQL schema to the so-called Singapore version.
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
-- $GNF: projects/gi/symgene/src/sql/migrate/singapore/migrate-taxon.sql,v 1.4 2003/06/12 01:03:40 hlapp Exp $
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

PROMPT Rolling in Taxon changes (1 old table becomes 2 new tables)
PROMPT - saving old taxon table

-- drop the old foreign key constraint from Bioentry
ALTER TABLE SG_Bioentry DROP CONSTRAINT FKTax_Ent;

-- save the old table to a temporary copy
CREATE TABLE SGOld_Taxon AS
SELECT * FROM SG_Taxon;

-- drop the old table
DROP TABLE SG_Taxon;

-- create the two new tables
PROMPT Creating new taxon tables
PROMPT - Taxon:

CREATE TABLE SG_Taxon (
	Oid			INTEGER NOT NULL , 
	NCBI_Taxon_ID		NUMBER(8), 
	Node_Rank		VARCHAR2(32), 
	Genetic_Code		NUMBER(2), 
	Mito_Genetic_Code 	NUMBER(2), 
	Left_Value 		INTEGER, 
	Right_Value 		INTEGER, 
	Tax_Oid			INTEGER, 
	CONSTRAINT XPKTaxon 
		PRIMARY KEY (Oid)
	USING INDEX
	TABLESPACE &biosql_index
	,
	CONSTRAINT XAK1Taxon
	UNIQUE (
	        NCBI_Taxon_ID
	)
	USING INDEX
	TABLESPACE &biosql_index
	,
	CONSTRAINT XAK2Taxon
	UNIQUE (
	       Left_Value
	)
	USING INDEX
	TABLESPACE &biosql_index
	,
	CONSTRAINT XAK3Taxon
	UNIQUE (
	       Right_Value
	)
	USING INDEX
	TABLESPACE &biosql_index
	--
)
;

-- corresponds to the names table of the NCBI taxonomy database 
PROMPT - Taxon_Name:

CREATE TABLE SG_Taxon_Name ( 
	Tax_Oid		   INTEGER NOT NULL, 
	Name		   VARCHAR2(128) NOT NULL, 
	Name_Class	   VARCHAR2(32) NOT NULL, 
	CONSTRAINT XAK1Taxon_Name
	UNIQUE (
	       Name,
	       Name_Class,
	       Tax_Oid
	)
	USING INDEX
	TABLESPACE &biosql_index
	--
)
;

-- Now migrate the content from the old table to the two new tables.
PROMPT Migrating old taxon table to new tables

INSERT INTO SG_Taxon (
	Oid,
	NCBI_Taxon_ID,
	Node_Rank
)
SELECT Oid, NCBI_Taxon_ID, 'species'
FROM SGOld_Taxon WHERE variant = '-'
;
INSERT INTO SG_Taxon (
	Oid,
	NCBI_Taxon_ID
)
SELECT Oid, NCBI_Taxon_ID
FROM SGOld_Taxon WHERE variant != '-'
;
INSERT INTO SG_Taxon_Name (
	Tax_Oid,
	Name,
	Name_Class
)
SELECT Oid, Name, 'scientific name' FROM SGOld_Taxon
;
INSERT INTO SG_Taxon_Name (
	Tax_Oid,
	Name,
	Name_Class
)
SELECT Oid, Common_Name, 'common name'
FROM SGOld_Taxon WHERE common_name IS NOT NULL
;

-- To make things a bit easier, we re-use the NCBI Taxon ID as primary key
-- where available.
--
-- In order to maintain FK integrity, we need to migrate this change
-- to the foreign keys pointing to taxon.

PROMPT Migrating Bioentry Tax_Oid foreign key values

UPDATE SG_Bioentry e SET
	Tax_Oid = (
       	       SELECT NCBI_Taxon_ID FROM SG_Taxon t
	       WHERE t.oid = e.tax_oid
	)
WHERE Tax_Oid IN (
        SELECT Oid FROM SG_Taxon WHERE NCBI_Taxon_ID IS NOT NULL
)
;

PROMPT Migrating SG_Taxon_Name Tax_Oid foreign key values

UPDATE SG_Taxon_Name tn SET
	Tax_Oid = (
       	       SELECT NCBI_Taxon_ID FROM SG_Taxon t
	       WHERE t.oid = tn.tax_oid
	)
WHERE Tax_Oid IN (
        SELECT Oid FROM SG_Taxon WHERE NCBI_Taxon_ID IS NOT NULL
)
;

-- now migrate the parent table primary key itself
PROMPT Migrating primary key of taxon to NCBI Taxon ID

UPDATE SG_Taxon SET
	Oid = NCBI_Taxon_ID
WHERE NCBI_Taxon_ID IS NOT NULL
;

-- Done with table creation and data migration. Now enforce the foreign keys
-- and create indexes where sensible. Let's hope FKs aren't violated.
PROMPT Enforcing foreign key constraints referencing Taxon

ALTER TABLE SG_Bioentry
       ADD  ( CONSTRAINT FKTax_Ent
              FOREIGN KEY (Tax_Oid)
                             REFERENCES SG_Taxon (Oid)  ) ;
-- unfortunately, we can't constrain parent_taxon_id as it is violated
-- occasionally by the downloads available from NCBI
-- ALTER TABLE SG_Taxon
--        ADD  ( CONSTRAINT FKTax_Tax
--               FOREIGN KEY (Tax_Oid)
--                              REFERENCES SG_Taxon (Oid) DEFERRED ) ;
ALTER TABLE SG_Taxon_Name
       ADD  ( CONSTRAINT FKTax_Tnm
              FOREIGN KEY (Tax_Oid)
                             REFERENCES SG_Taxon (Oid)
			     ON DELETE CASCADE ) ;

-- Create remaining indexes.
PROMPT Creating indexes on Taxon and Taxon Name

CREATE INDEX XIF1Taxon ON SG_Taxon
(
       Tax_Oid
)
    	 TABLESPACE &biosql_index
;

CREATE INDEX XIF1Taxon_Name ON SG_Taxon_Name (
       Tax_Oid
)
	 TABLESPACE &biosql_index
; 

-- Create insert trigger for primary key generation.
PROMPT Creating insert trigger to auto-generate primary key for taxon

CREATE OR REPLACE TRIGGER BIR_Taxon
  BEFORE INSERT
  on SG_Taxon
  -- 
  for each row
/* Template for auto-generation of primary key (H.Lapp, lapp@gnf.org) */
/* Default body for BIR_Taxon */
BEGIN
IF :new.Oid IS NULL THEN
    SELECT SG_SEQUENCE.nextval INTO :new.Oid FROM DUAL;
END IF;
END;
/
