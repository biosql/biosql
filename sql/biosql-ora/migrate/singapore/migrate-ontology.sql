--
-- This SQL script is to migrate the Ontology part of the pre-Singapore Oracle
-- version of the BioSQL schema to the so-called Singapore version.
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
-- $GNF: projects/gi/symgene/src/sql/migrate/singapore/migrate-ontology.sql,v 1.2 2003/05/14 07:10:59 hlapp Exp $
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

PROMPT Rolling in Ontology changes.

--
-- We'll large do this via renames.
--
PROMPT Preparing rename operations for tables, indexes, and constraints.

set timing off
set heading off
set termout off
set feedback off

spool _rename_term_objs.sql

-- First, as there is no ontology table yet, we remove 'ontology' from every
-- object name where it is present.
SELECT DECODE(Object_Type,
              'TABLE', 'RENAME ' || Object_Name,
	      'INDEX', 'ALTER INDEX ' || Object_Name || ' RENAME') ||
       ' TO ' ||
       REPLACE(Object_Name, 'ONTOLOGY_') ||
       ';'
FROM user_objects 
WHERE Object_Name LIKE '%ONTOLOGY%'
AND   Object_Type IN ('TABLE','INDEX')
;
SELECT 'ALTER TABLE ' ||
       REPLACE(Table_Name, 'ONTOLOGY_') ||
       ' RENAME CONSTRAINT ' ||
       Constraint_Name ||
       ' TO ' ||
       REPLACE(Constraint_Name, 'ONTOLOGY_') ||
       ';'
FROM user_constraints
WHERE Constraint_Name LIKE '%ONTOLOGY%'
;

-- Also, as we are going to have an ontology table, we need to change the
-- acronym for Ontology_Term from Ont to Trm.
SELECT 'ALTER TABLE ' ||
       REPLACE(Table_Name, 'ONTOLOGY_') ||
       ' RENAME CONSTRAINT ' ||
       Constraint_Name ||
       ' TO ' ||
       REPLACE(Constraint_Name, 'ONT', 'TRM') ||
       ';'
FROM user_constraints
WHERE Constraint_Name LIKE '%ONT%'
AND   Constraint_Name NOT LIKE '%ONTOLOGY%'
;

spool off

set timing on
set heading on
set termout on
set feedback on

-- execute
PROMPT Executing renamings

start _rename_term_objs

-- we need to rename the trigger by recreating it
PROMPT Rename trigger by recreating it

DROP TRIGGER BIR_Ontology_Term;

CREATE OR REPLACE TRIGGER BIR_Term
  BEFORE INSERT
  on SG_Term
  -- 
  for each row
/* Template for auto-generation of primary key (H.Lapp, lapp@gnf.org) */
/* Default body for BIR_Term */
BEGIN
IF :new.Oid IS NULL THEN
    SELECT SG_SEQUENCE.nextval INTO :new.Oid FROM DUAL;
END IF;
END;
/

-- now establish the new Ontology table
PROMPT Creating Ontology table

CREATE TABLE SG_Ontology (
	Oid  		 INTEGER NOT NULL, 
	Name		 VARCHAR2(32) NOT NULL,
	Definition	 VARCHAR2(4000),
	CONSTRAINT XPKOntology
		PRIMARY KEY (Oid)
	USING INDEX
	TABLESPACE &biosql_index
	,
	CONSTRAINT XAK1Ontology
	UNIQUE (
	        Name
	)
	USING INDEX
	TABLESPACE &biosql_index
	--
)
;

-- Create insert trigger for primary key generation.
PROMPT Creating insert trigger to auto-generate primary key for Ontology

CREATE OR REPLACE TRIGGER BIR_Ontology
  BEFORE INSERT
  on SG_Ontology
  -- 
  for each row
/* Template for auto-generation of primary key (H.Lapp, lapp@gnf.org) */
/* Default body for BIR_Ontology */
BEGIN
IF :new.Oid IS NULL THEN
    SELECT SG_SEQUENCE.nextval INTO :new.Oid FROM DUAL;
END IF;
END;
/

-- and migrate the data destined for it
PROMPT Migrating data destined for Ontology table

ALTER TABLE SG_Term DROP CONSTRAINT FKTrm_Trm;

INSERT INTO SG_Ontology (Oid, Name, Definition)
SELECT Oid, Name, Definition
FROM  SG_Term t
WHERE Ont_Oid IS NULL
;
-- delete those we just migrated to become Ontology entries
DELETE FROM SG_Term t
WHERE Ont_Oid IS NULL
;

PROMPT Establishing new constraints for Term
-- Adjust the foreign key constraint from Term to Ontology
ALTER TABLE SG_Term
       ADD  ( CONSTRAINT FKOnt_Trm
              FOREIGN KEY (Ont_Oid)
                             REFERENCES SG_Ontology (Oid)
			     ON DELETE CASCADE ) ;

-- Enforce the ontology FK to be present
ALTER TABLE SG_Term MODIFY (Ont_Oid NOT NULL);

-- Amend the term relationship table with a FK to ontology, and add a
-- primary key. We'll do this through a re-creation followed by data
-- migration.
PROMPT Migrating Term Associations
PROMPT     - save old table

CREATE TABLE SGOld_Term_Assoc AS
SELECT * FROM SG_Term_Assoc;

DROP TABLE SG_Term_Assoc;

PROMPT     - create new table

CREATE TABLE SG_Term_Assoc (
       Oid   		    INTEGER NOT NULL,
       Subj_Trm_Oid         INTEGER NOT NULL,
       Pred_Trm_Oid         INTEGER NOT NULL,
       Obj_Trm_Oid          INTEGER NOT NULL,
       Ont_Oid		    INTEGER NOT NULL,
       CONSTRAINT XPKTerm_Assoc 
              PRIMARY KEY (Oid)
       USING INDEX
       TABLESPACE &biosql_index
       ,
       CONSTRAINT XAK1Term_Assoc
              UNIQUE (Subj_Trm_Oid, Pred_Trm_Oid, Obj_Trm_Oid, Ont_Oid)
       USING INDEX
       TABLESPACE &biosql_index
       --
);

-- and sequence
CREATE SEQUENCE SG_Sequence_TrmA 
	INCREMENT BY 1 
	START WITH 1 
	NOMAXVALUE 
	NOMINVALUE 
	NOCYCLE
	NOORDER
;

PROMPT     - create insert trigger

CREATE OR REPLACE TRIGGER BIR_Term_Assoc
  BEFORE INSERT
  on SG_Term_Assoc
  -- 
  for each row
/* Template for auto-generation of primary key (H.Lapp, lapp@gnf.org) */
/* Default body for BIR_Term_Assoc */
BEGIN
IF :new.Oid IS NULL THEN
    SELECT SG_SEQUENCE_TRMA.nextval INTO :new.Oid FROM DUAL;
END IF;
END;
/

PROMPT     - migrate data

-- we'll assume that the ontology is equal to the one of the predicate
INSERT INTO SG_Term_Assoc (Subj_Trm_Oid, 
                           Pred_Trm_Oid,
			   Obj_Trm_Oid,
			   Ont_Oid)
SELECT a.Src_Ont_Oid, a.Type_Ont_Oid, a.Tgt_Ont_Oid, t.Ont_Oid
FROM  SGOld_Term_Assoc a, SG_Term t
WHERE a.Type_Ont_Oid = t.Oid
;

PROMPT     - enforce constraints, build indexes

ALTER TABLE SG_Term_Assoc
       ADD  ( CONSTRAINT FKSubjTrm_TrmA
              FOREIGN KEY (Subj_Trm_Oid)
                             REFERENCES SG_Term (Oid) 
                             ON DELETE CASCADE ) ;
ALTER TABLE SG_Term_Assoc
       ADD  ( CONSTRAINT FKObjTrm_TrmA
              FOREIGN KEY (Obj_Trm_Oid)
                             REFERENCES SG_Term (Oid) 
                             ON DELETE CASCADE ) ;
ALTER TABLE SG_Term_Assoc
       ADD  ( CONSTRAINT FKPredTrm_TrmA
              FOREIGN KEY (Pred_Trm_Oid)
                             REFERENCES SG_Term (Oid)  ) ;
ALTER TABLE SG_Term_Assoc
       ADD  ( CONSTRAINT FKOnt_TrmA
              FOREIGN KEY (Ont_Oid)
                             REFERENCES SG_Ontology (Oid)
			     ON DELETE CASCADE ) ;

CREATE INDEX XIF1Term_Assoc ON SG_Term_Assoc
(
       Obj_Trm_Oid
)
    	 TABLESPACE &biosql_index
;
-- not sure this index is a wise one - it's not going to be very distinctive
-- for large ontologies, but could be helpful for small ones
CREATE INDEX XIF2Term_Assoc ON SG_Term_Assoc
(
       Ont_Oid
)
    	 TABLESPACE &biosql_index
;

--
-- Now add the path table.
--
PROMPT Creating transitive closure table for term relationships

PROMPT     - create new table

CREATE TABLE SG_Term_Path (
        Oid   		     INTEGER NOT NULL,
        Subj_Trm_Oid         INTEGER NOT NULL,
        Pred_Trm_Oid         INTEGER NOT NULL,
        Obj_Trm_Oid          INTEGER NOT NULL,
        Distance	     NUMBER(3) NOT NULL,
        Ont_Oid		     INTEGER NOT NULL,
        CONSTRAINT XPKTerm_Path 
              PRIMARY KEY (Oid)
        USING INDEX
        TABLESPACE &biosql_index
        ,
        CONSTRAINT XAK1Term_Path
        UNIQUE (
		Subj_Trm_Oid,
	        Pred_Trm_Oid,
		Obj_Trm_Oid,
		Distance,
		Ont_Oid
	)
       	USING INDEX
       	TABLESPACE &biosql_index
       	--
);

PROMPT     - create insert trigger

CREATE OR REPLACE TRIGGER BIR_Term_Path
  BEFORE INSERT
  on SG_Term_Path
  -- 
  for each row
/* Template for auto-generation of primary key (H.Lapp, lapp@gnf.org) */
/* Default body for BIR_Term_Path */
BEGIN
IF :new.Oid IS NULL THEN
    SELECT SG_SEQUENCE_TRMA.nextval INTO :new.Oid FROM DUAL;
END IF;
END;
/

PROMPT     - enforce constraints, build indexes

ALTER TABLE SG_Term_Path
       ADD  ( CONSTRAINT FKSubjTrm_TrmP
              FOREIGN KEY (Subj_Trm_Oid)
                             REFERENCES SG_Term (Oid) 
                             ON DELETE CASCADE ) ;
ALTER TABLE SG_Term_Path
       ADD  ( CONSTRAINT FKObjTrm_TrmP
              FOREIGN KEY (Obj_Trm_Oid)
                             REFERENCES SG_Term (Oid) 
                             ON DELETE CASCADE ) ;
ALTER TABLE SG_Term_Path
       ADD  ( CONSTRAINT FKPredTrm_TrmP
              FOREIGN KEY (Pred_Trm_Oid)
                             REFERENCES SG_Term (Oid)  ) ;
ALTER TABLE SG_Term_Path
       ADD  ( CONSTRAINT FKOnt_TrmP
              FOREIGN KEY (Ont_Oid)
                             REFERENCES SG_Ontology (Oid)
			     ON DELETE CASCADE ) ;

CREATE INDEX XIF1Term_Path ON SG_Term_Path
(
       Obj_Trm_Oid
)
    	 TABLESPACE &biosql_index
;
-- not sure this index is a wise one - it's not going to be very distinctive
-- for large ontologies, but could be helpful for small ones
CREATE INDEX XIF2Term_Path ON SG_Term_Path
(
       Ont_Oid
)
    	 TABLESPACE &biosql_index
;

PROMPT Done with Ontology and Term.
