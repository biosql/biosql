--
-- This SQL script is to migrate the relationship tables in the pre-Singapore
-- Oracle version of the BioSQL schema to the so-called Singapore version.
-- In addition, adds the transitive closure path tables.
--
-- We don't migrate the term relationship table here, as it is migrated in
-- the script that rolls in the ontology-related changes.
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
-- $GNF: projects/gi/symgene/src/sql/migrate/singapore/migrate-rels.sql,v 1.1 2003/05/02 02:08:27 hlapp Exp $
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
-- Migrate bioentry relationship table.
--
-- Since we had already a primary key there, it's just a matter of renaming
-- columns to upgrade it.
PROMPT Migrating bioentry relationship table
PROMPT - renaming columns

ALTER TABLE SG_Bioentry_Assoc RENAME COLUMN Src_Ent_Oid TO Subj_Ent_Oid;
ALTER TABLE SG_Bioentry_Assoc RENAME COLUMN Tgt_Ent_Oid TO Obj_Ent_Oid;
ALTER TABLE SG_Bioentry_Assoc RENAME COLUMN Ont_Oid TO Trm_Oid;

PROMPT - add rank column

ALTER TABLE SG_Bioentry_Assoc ADD (
       Rank		    NUMBER(6) NULL
)
;

-- Add the transitive closure table
PROMPT Adding transitive closure table for bioentry relationships

CREATE TABLE SG_Bioentry_Path (
       Subj_Ent_Oid         INTEGER NOT NULL,
       Trm_Oid              INTEGER NOT NULL,
       Obj_Ent_Oid          INTEGER NOT NULL,
       Distance		    NUMBER(3),
       CONSTRAINT XAK1Bioentry_Path
       UNIQUE (
	      Subj_Ent_Oid,
	      Obj_Ent_Oid,
	      Trm_Oid,
	      Distance
       )
       USING INDEX
    	 TABLESPACE &biosql_index
 	 --
)
;

CREATE INDEX XIF1Bioentry_Path ON SG_Bioentry_Path
(
       Obj_Ent_Oid
)
    	 TABLESPACE &biosql_index
;

-- CREATE INDEX XIF2Bioentry_Path ON SG_Bioentry_Path
-- (
--        Trm_Oid
-- )
--     	 TABLESPACE &biosql_index
-- ;

ALTER TABLE SG_Bioentry_Path
       ADD  ( CONSTRAINT FKSubjEnt_EntP
              FOREIGN KEY (Subj_Ent_Oid)
                             REFERENCES SG_Bioentry (Oid) 
                             ON DELETE CASCADE ) ;
ALTER TABLE SG_Bioentry_Path
       ADD  ( CONSTRAINT FKObjEnt_EntP
              FOREIGN KEY (Obj_Ent_Oid)
                             REFERENCES SG_Bioentry (Oid) 
                             ON DELETE CASCADE ) ;
ALTER TABLE SG_Bioentry_Path
       ADD  ( CONSTRAINT FKTrm_EntP
              FOREIGN KEY (Trm_Oid)
                             REFERENCES SG_Term (Oid)  ) ;

-- Now seqfeature relationships. Since we didn't have a primary key column
-- there before, let's migrate this one via saving the old and create from
-- scratch.
PROMPT Migrating seqfeature relationship table.

-- Nothing depends on it, so we can take the short-hand approach of just
-- saving the content and dropping it.
PROMPT     - saving old data

CREATE TABLE SGOld_Seqfeature_Assoc AS
SELECT * FROM SG_Seqfeature_Assoc;

COMMIT;

DROP TABLE SG_Seqfeature_Assoc CASCADE CONSTRAINTS;

PROMPT     - creating new table, sequence, and insert trigger

CREATE TABLE SG_Seqfeature_Assoc (
	Oid			INTEGER NOT NULL,
	Subj_Fea_Oid          	INTEGER NOT NULL,
       	Obj_Fea_Oid          	INTEGER NOT NULL,
       	Trm_Oid              	INTEGER NOT NULL,
       	Rank                 	NUMBER(3) NOT NULL,
       	CONSTRAINT XPKSeqfeature_Assoc 
              PRIMARY KEY (Oid)
       	USING INDEX
       	TABLESPACE &biosql_index
	,
       	CONSTRAINT XAK1Seqfeature_Assoc 
        UNIQUE (
		Subj_Fea_Oid,
		Obj_Fea_Oid,
		Trm_Oid
	)
       	USING INDEX
       	TABLESPACE &biosql_index
       	--
);

CREATE SEQUENCE SG_Sequence_FeaA 
	INCREMENT BY 1 
	START WITH 1 
	NOMAXVALUE 
	NOMINVALUE 
	NOCYCLE
	NOORDER
;

CREATE TRIGGER BIR_Seqfeature_Assoc
  BEFORE INSERT
  on SG_Seqfeature_Assoc
  -- 
  for each row
/* Template for auto-generation of primary key (H.Lapp, lapp@gnf.org) */
/* Default body for BIR_Seqfeature_Assoc */
BEGIN
IF :new.Oid IS NULL THEN
    SELECT SG_SEQUENCE_FEAA.nextval INTO :new.Oid FROM DUAL;
END IF;
END;
/

PROMPT     - restoring data

INSERT INTO SG_Seqfeature_Assoc (Subj_Fea_Oid,
				 Obj_Fea_Oid,
				 Trm_Oid,
				 Rank
)
SELECT Src_Fea_Oid, Tgt_Fea_Oid, Ont_Oid, Rank
FROM SGOld_Seqfeature_Assoc
;

COMMIT;

DROP TABLE SGOld_Seqfeature_Assoc;

PROMPT     - creating indexes, enforcing constraints

CREATE INDEX XIFSeqfeature_Assoc ON SG_Seqfeature_Assoc
(
       Obj_Fea_Oid
)
    	 TABLESPACE &biosql_index
;

ALTER TABLE SG_Seqfeature_Assoc
       ADD  ( CONSTRAINT FKObjFea_FeaA
              FOREIGN KEY (Obj_Fea_Oid)
                             REFERENCES SG_Seqfeature (Oid) 
                             ON DELETE CASCADE ) ;
ALTER TABLE SG_Seqfeature_Assoc
       ADD  ( CONSTRAINT FKTrm_FeaA
              FOREIGN KEY (Trm_Oid)
                             REFERENCES SG_Term (Oid) ) ;
ALTER TABLE SG_Seqfeature_Assoc
       ADD  ( CONSTRAINT FKSubjFea_FeaA
              FOREIGN KEY (Subj_Fea_Oid)
                             REFERENCES SG_Seqfeature (Oid) 
                             ON DELETE CASCADE ) ;

--
-- Now the transitive closure table for seqfeature relationships
--
PROMPT     - adding transitive closure table

CREATE TABLE SG_Seqfeature_Path (
       Subj_Fea_Oid         INTEGER NOT NULL,
       Trm_Oid              INTEGER NOT NULL,
       Obj_Fea_Oid          INTEGER NOT NULL,
       Distance		    NUMBER(3),
       CONSTRAINT XAK1Seqfeature_Path
       UNIQUE (
	      Subj_Fea_Oid,
	      Obj_Fea_Oid,
	      Trm_Oid,
	      Distance
       )
       USING INDEX
    	 TABLESPACE &biosql_index
 	 --
)
;

CREATE INDEX XIF1Seqfeature_Path ON SG_Seqfeature_Path
(
       Obj_Fea_Oid
)
    	 TABLESPACE &biosql_index
;

-- CREATE INDEX XIF2Seqfeature_Path ON SG_Seqfeature_Path
-- (
--        Trm_Oid
-- )
--     	 TABLESPACE &biosql_index
-- ;

ALTER TABLE SG_Seqfeature_Path
       ADD  ( CONSTRAINT FKSubjFea_FeaP
              FOREIGN KEY (Subj_Fea_Oid)
                             REFERENCES SG_Seqfeature (Oid) 
                             ON DELETE CASCADE ) ;
ALTER TABLE SG_Seqfeature_Path
       ADD  ( CONSTRAINT FKObjFea_FeaP
              FOREIGN KEY (Obj_Fea_Oid)
                             REFERENCES SG_Seqfeature (Oid) 
                             ON DELETE CASCADE ) ;
ALTER TABLE SG_Seqfeature_Path
       ADD  ( CONSTRAINT FKTrm_FeaP
              FOREIGN KEY (Trm_Oid)
                             REFERENCES SG_Term (Oid)  ) ;

PROMPT Done with relationship tables migration.
