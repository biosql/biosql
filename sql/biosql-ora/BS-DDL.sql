--
-- SQL script to instantiate the SYMGENE/BioSQL database schema.
--
--
-- $Id$
--

--
-- (c) Hilmar Lapp, hlapp at gnf.org, 2002.
-- (c) GNF, Genomics Institute of the Novartis Research Foundation, 2002.
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

-- load definitions first
@BS-defs

-- instantiate the schema:

DROP SEQUENCE SG_Sequence ;
DROP SEQUENCE SG_Sequence_Fea ;
DROP SEQUENCE SG_Sequence_EntA ;
DROP SEQUENCE SG_Sequence_Rank ;

CREATE SEQUENCE SG_Sequence 
INCREMENT BY 1 
START WITH 1 
NOMAXVALUE 
NOMINVALUE 
NOCYCLE
NOORDER
;
CREATE SEQUENCE SG_Sequence_Fea 
INCREMENT BY 1 
START WITH 1 
NOMAXVALUE 
NOMINVALUE
NOCYCLE
NOORDER
;
CREATE SEQUENCE SG_Sequence_EntA 
INCREMENT BY 1 
START WITH 1 
NOMAXVALUE 
NOMINVALUE 
NOCYCLE
NOORDER
;
CREATE SEQUENCE SG_Sequence_Rank
INCREMENT BY 1 
START WITH 1 
NOMAXVALUE 
NOMINVALUE 
NOCYCLE
NOORDER
;


DROP TABLE SG_Biodatabase CASCADE CONSTRAINTS;

CREATE TABLE SG_Biodatabase (
       Oid                  INTEGER NOT NULL,
       Name                 VARCHAR2(32) NOT NULL,
       Authority            VARCHAR2(32) NULL,
       Acronym              VARCHAR2(6) NULL,
       URI                  VARCHAR2(128) NULL,
       CONSTRAINT XPKBiodatabase 
              PRIMARY KEY (Oid)
       USING INDEX
       TABLESPACE &biosql_index
       ,
       CONSTRAINT XAK1Biodatabase
       UNIQUE (
              Name
       )
       USING INDEX
       TABLESPACE &biosql_index
       ,
       CONSTRAINT XAK2Biodatabase
       UNIQUE (
              Acronym
       )
       USING INDEX
       TABLESPACE &biosql_index
       --
);


DROP TABLE SG_Taxon CASCADE CONSTRAINTS;

CREATE TABLE SG_Taxon (
       Oid                  INTEGER NOT NULL,
       Name                 VARCHAR2(96) NOT NULL,
       Variant              VARCHAR2(64) NOT NULL,
       Common_Name          VARCHAR2(96) NULL,
       NCBI_Taxon_ID        NUMBER(8) NULL,
       Full_Lineage         VARCHAR2(512) NOT NULL,
       CONSTRAINT XPKTaxon 
              PRIMARY KEY (Oid)
       USING INDEX
       TABLESPACE &biosql_index
       ,
       CONSTRAINT XAK1Taxon
       UNIQUE (
              Name,
              Variant
       )
       USING INDEX
       TABLESPACE &biosql_index
       ,
       CONSTRAINT XAK3Taxon
       UNIQUE (
              NCBI_Taxon_ID
       )
       USING INDEX
       TABLESPACE &biosql_index
       --
)
;

CREATE INDEX XIFTaxon ON SG_Taxon
(
       Common_Name
)
    	 TABLESPACE &biosql_index
;


DROP TABLE SG_Ontology_Term CASCADE CONSTRAINTS;

CREATE TABLE SG_Ontology_Term (
       Oid                  INTEGER NOT NULL,
       Name                 VARCHAR2(256) NOT NULL,
       Identifier           VARCHAR2(16) NULL,
       Definition           VARCHAR2(2000) NULL,
       Ont_Oid              INTEGER NULL,
       CONSTRAINT XPKOntology_Term 
              PRIMARY KEY (Oid)
       USING INDEX
    	 TABLESPACE &biosql_index
 	 ,
       CONSTRAINT XAK1Ontology_Term
       UNIQUE (
              Name,
              Ont_Oid
       )
       USING INDEX
    	 TABLESPACE &biosql_index
 	 ,
       CONSTRAINT XAK2Ontology_Term
       UNIQUE (
              Identifier
       )
       USING INDEX
    	 TABLESPACE &biosql_index
 	 --
)
;


DROP TABLE SG_Ontology_Term_Assoc CASCADE CONSTRAINTS;

CREATE TABLE SG_Ontology_Term_Assoc (
       Src_Ont_Oid          INTEGER NOT NULL,
       Type_Ont_Oid         INTEGER NOT NULL,
       Tgt_Ont_Oid          INTEGER NOT NULL,
       CONSTRAINT XPKOntology_Term_Assoc 
              PRIMARY KEY (Tgt_Ont_Oid, Type_Ont_Oid, Src_Ont_Oid)
       USING INDEX
       TABLESPACE &biosql_index
       --
);


DROP TABLE SG_Bioentry CASCADE CONSTRAINTS;

CREATE TABLE SG_Bioentry (
       Oid                  INTEGER NOT NULL,
       Accession            VARCHAR2(32) NOT NULL,
       Identifier           VARCHAR2(32) NULL,
       Display_ID           VARCHAR2(32) NOT NULL,
       Description          VARCHAR2(512) NULL,
       Version              NUMBER(2) DEFAULT 0 NOT NULL,
       DB_Oid               INTEGER NOT NULL,
       Tax_Oid              INTEGER NULL,
       CONSTRAINT XPKBioentry 
              PRIMARY KEY (Oid)
       USING INDEX
    	 TABLESPACE &biosql_index
 	 ,
       CONSTRAINT XAK1Bioentry
       UNIQUE (
              Accession,
              DB_Oid,
              Version
       )
       USING INDEX
    	 TABLESPACE &biosql_index
 	 ,
       CONSTRAINT XAK2Bioentry
       UNIQUE (
              Identifier
       )
       USING INDEX
    	 TABLESPACE &biosql_index
 	 --
)
;

CREATE INDEX XIF569Bioentry ON SG_Bioentry
(
       Tax_Oid
)
    	 TABLESPACE &biosql_index
;

CREATE INDEX XIE1Bioentry ON SG_Bioentry
(
       Display_ID               
)
    	 TABLESPACE &biosql_index
;

CREATE INDEX XIE2Bioentry ON SG_Bioentry
(
       DB_Oid
)
    	 TABLESPACE &biosql_index
;


DROP TABLE SG_Bioentry_Assoc CASCADE CONSTRAINTS;

CREATE TABLE SG_Bioentry_Assoc (
       Oid                  INTEGER NOT NULL,
       Src_Ent_Oid          INTEGER NOT NULL,
       Ont_Oid              INTEGER NOT NULL,
       Tgt_Ent_Oid          INTEGER NOT NULL,
       CONSTRAINT XPKBioentry_Assoc 
              PRIMARY KEY (Oid)
       USING INDEX
    	 TABLESPACE &biosql_index
	 ,
       CONSTRAINT XAK1Bioentry_Assoc
       UNIQUE (
	      Src_Ent_Oid,
	      Tgt_Ent_Oid,
	      Ont_Oid
       )
       USING INDEX
    	 TABLESPACE &biosql_index
 	 --
)
;

CREATE INDEX XIF1Bioentry_Assoc ON SG_Bioentry_Assoc
(
       Tgt_Ent_Oid
)
    	 TABLESPACE &biosql_index
;

-- CREATE INDEX XIF2Bioentry_Assoc ON SG_Bioentry_Assoc
-- (
--        Ont_Oid
-- )
--     	 TABLESPACE &biosql_index
-- ;


DROP TABLE SG_Similarity CASCADE CONSTRAINTS;

CREATE TABLE SG_Similarity (
       Oid                  INTEGER NOT NULL,
       Score                NUMBER(10) NULL,
       Expect_Mantissa      FLOAT NULL,
       Expect_Exponent	    NUMBER(3) NULL,
       Pct_Identity         NUMBER(5,2) NULL,
       Pct_Coverage         NUMBER(5,2) NULL,
       Src_Start_Pos        NUMBER(10) NOT NULL,
       Src_End_Pos          NUMBER(10) NOT NULL,
       Src_Strand           NUMBER(1) NULL
                                   CONSTRAINT Strand22
                                          CHECK (Src_Strand IN (-1, 0, 1)),
       Src_Frame            NUMBER(1) NULL
                                   CONSTRAINT Frame8
                                          CHECK (Src_Frame IN (0, 1, 2)),
       Tgt_Start_Pos        NUMBER(10) NOT NULL,
       Tgt_End_Pos          NUMBER(10) NOT NULL,
       Tgt_Strand           NUMBER(1) NULL,
       Tgt_Frame            NUMBER(1) NULL
                                   CONSTRAINT Frame9
                                          CHECK (Tgt_Frame IN (0, 1, 2)),
       CONSTRAINT XPKSimilarity 
              PRIMARY KEY (Oid)
       USING INDEX
    	 TABLESPACE &biosql_index
 	 --
)
;


DROP TABLE SG_Bioentry_Qualifier_Assoc CASCADE CONSTRAINTS;

CREATE TABLE SG_Bioentry_Qualifier_Assoc (
       Ent_Oid              INTEGER NOT NULL,
       Ont_Oid              INTEGER NOT NULL,
       Rank		    NUMBER(5) NOT NULL,
       Value                VARCHAR2(4000) NULL,
       CONSTRAINT XPKBioentry_Qualifier_Assoc 
              PRIMARY KEY (Ent_Oid, Ont_Oid, Rank)
       USING INDEX
    	 TABLESPACE &biosql_index
 	 --
)
;

CREATE INDEX XIFBioentry_Qualifier_Assoc ON SG_Bioentry_Qualifier_Assoc
(
       Ont_Oid
)
    	 TABLESPACE &biosql_index
;


DROP TABLE SG_Biosequence CASCADE CONSTRAINTS;

CREATE TABLE SG_Biosequence (
       Ent_Oid              INTEGER NOT NULL,
       Version              NUMBER(3,1) NULL,
       Length               INTEGER NULL,
       Alphabet             VARCHAR2(12) NULL
                                   CONSTRAINT Alphabet4
                                          CHECK (Alphabet IN ('dna', 'protein', 'rna')),
       Division             VARCHAR2(6) DEFAULT 'UNK' NULL,
       Seq                  CLOB NULL,
       CONSTRAINT XPKBiosequence 
              PRIMARY KEY (Ent_Oid)
       USING INDEX
    	 TABLESPACE &biosql_index
	 --
)
       LOB (Seq) STORE AS (
	   TABLESPACE &biosql_lob CHUNK 4096
       )
;


DROP TABLE SG_DBXRef CASCADE CONSTRAINTS;

CREATE TABLE SG_DBXRef (
       Oid                  INTEGER NOT NULL,
       DBName               VARCHAR2(32) NOT NULL,
       Accession            VARCHAR2(32) NOT NULL,
       Version              NUMBER(2) DEFAULT 0 NOT NULL,
       CONSTRAINT XPKDBXRef 
              PRIMARY KEY (Oid)
       USING INDEX
    	 TABLESPACE &biosql_index
 	 ,
       CONSTRAINT XAK1DBXRef
       UNIQUE (
              Accession,
              DBName,
              Version
       )
       USING INDEX
    	 TABLESPACE &biosql_index
	 --
);

CREATE INDEX XIE1DBXRef ON SG_DBXRef
(
       DBName
)
      TABLESPACE &biosql_index
;


DROP TABLE SG_Bioentry_DBXRef_Assoc CASCADE CONSTRAINTS;

CREATE TABLE SG_Bioentry_DBXRef_Assoc (
       DBX_Oid              INTEGER NOT NULL,
       Ent_Oid              INTEGER NOT NULL,
       CONSTRAINT XPKBioentry_DBXRef_Assoc 
              PRIMARY KEY (Ent_Oid, DBX_Oid)
       USING INDEX
    	 TABLESPACE &biosql_index
 	 --
);

CREATE INDEX XIE1Bioentry_DBXRef_Assoc ON SG_Bioentry_DBXRef_Assoc
(
       DBX_Oid
)
      TABLESPACE &biosql_index
;


DROP TABLE SG_Comment CASCADE CONSTRAINTS;

CREATE TABLE SG_Comment (
       Oid                  INTEGER NOT NULL,
       Rank                 NUMBER(2) NOT NULL,
       Comment_Text         CLOB NOT NULL,
       Ent_Oid              INTEGER NOT NULL,
       CONSTRAINT XPKComment 
              PRIMARY KEY (Oid)
       USING INDEX
       TABLESPACE &biosql_index
       ,
       CONSTRAINT XAK1Comment
       UNIQUE (
              Ent_Oid,
              Rank
       )
       USING INDEX
    	 TABLESPACE &biosql_index
 	 --
)
       LOB (Comment_Text) STORE AS (
	   TABLESPACE &biosql_lob CHUNK 4096
       )
;


DROP TABLE SG_Reference CASCADE CONSTRAINTS;

CREATE TABLE SG_Reference (
       Oid                  INTEGER NOT NULL,
       Title                VARCHAR2(1000) NULL,
       Authors              VARCHAR2(4000) NOT NULL,
       Location             VARCHAR2(512) NOT NULL,
       Document_ID          VARCHAR2(32) NULL,
       CRC                  VARCHAR2(32) NULL,
       CONSTRAINT XPKReference 
              PRIMARY KEY (Oid)
       USING INDEX
    	 TABLESPACE &biosql_index
 	 ,
       CONSTRAINT XAK2Reference
       UNIQUE (
              Document_ID
       )
       USING INDEX
    	 TABLESPACE &biosql_index
 	 ,
       CONSTRAINT XAK3Reference
       UNIQUE (
              CRC
       )
       USING INDEX
    	 TABLESPACE &biosql_index
 	 --
)
;

CREATE INDEX XIEReference ON SG_Reference
(
       Location
)
    	 TABLESPACE &biosql_index
;


DROP TABLE SG_Bioentry_Ref_Assoc CASCADE CONSTRAINTS;

CREATE TABLE SG_Bioentry_Ref_Assoc (
       Ent_Oid              INTEGER NOT NULL,
       Ref_Oid              INTEGER NOT NULL,
       Rank                 NUMBER(2) NOT NULL,
       End_Pos              NUMBER(10) NULL,
       Start_Pos            NUMBER(10) NULL,
       CONSTRAINT XPKBioentry_Ref_Assoc 
              PRIMARY KEY (Ent_Oid, Ref_Oid, Rank)
       USING INDEX
    	 TABLESPACE &biosql_index
 	 --
)
;

CREATE INDEX XIFBioentry_Ref_Assoc ON SG_Bioentry_Ref_Assoc
(
       Ref_Oid
)
    	 TABLESPACE &biosql_index
;


DROP TABLE SG_Seqfeature CASCADE CONSTRAINTS;

CREATE TABLE SG_Seqfeature (
       Oid                  INTEGER NOT NULL,
       Rank                 NUMBER(9) NOT NULL,
       Ent_Oid              INTEGER NOT NULL,
       Ont_Oid              INTEGER NULL,
       FSrc_Oid             INTEGER NULL,
       CONSTRAINT XPKSeqfeature 
              PRIMARY KEY (Oid)
       USING INDEX
    	 TABLESPACE &biosql_index
 	 ,
       CONSTRAINT XAK1Seqfeature
       UNIQUE (
              Ent_Oid,
              Ont_Oid,
	      FSrc_Oid,
              Rank
       )
       USING INDEX
    	 TABLESPACE &biosql_index
 	 --
)
;

CREATE INDEX XIF1Seqfeature ON SG_Seqfeature
(
       Ont_Oid
)
    	 TABLESPACE &biosql_index
;

CREATE INDEX XIF2Seqfeature ON SG_Seqfeature
(
       FSrc_Oid
)
    	 TABLESPACE &biosql_index
;


DROP TABLE SG_Seqfeature_Assoc CASCADE CONSTRAINTS;

CREATE TABLE SG_Seqfeature_Assoc (
       Src_Fea_Oid          INTEGER NOT NULL,
       Tgt_Fea_Oid          INTEGER NOT NULL,
       Ont_Oid              INTEGER NOT NULL,
       Rank                 NUMBER(2) NOT NULL,
       CONSTRAINT XPKSeqfeature_Assoc 
              PRIMARY KEY (Src_Fea_Oid, Tgt_Fea_Oid, Ont_Oid)
       USING INDEX
       TABLESPACE &biosql_index
       --
);

CREATE INDEX XIFSeqfeature_Assoc ON SG_Seqfeature_Assoc
(
       Tgt_Fea_Oid
)
    	 TABLESPACE &biosql_index
;


DROP TABLE SG_Seqfeature_Qualifier_Assoc CASCADE CONSTRAINTS;

CREATE TABLE SG_Seqfeature_Qualifier_Assoc (
       Fea_Oid              INTEGER NOT NULL,
       Ont_Oid              INTEGER NOT NULL,
       Rank                 NUMBER(3) NOT NULL,
       Value                VARCHAR2(4000) NULL,
       CONSTRAINT XPKSeqfeature_Qualifier_Assoc 
              PRIMARY KEY (Fea_Oid, Ont_Oid, Rank)
       USING INDEX
    	 TABLESPACE &biosql_index
 	 --
)
;

CREATE INDEX XIFSeqfeature_Qualifier_Assoc ON SG_Seqfeature_Qualifier_Assoc
(
       Ont_Oid
)
    	 TABLESPACE &biosql_index
;


DROP TABLE SG_Seqfeature_Location CASCADE CONSTRAINTS;

CREATE TABLE SG_Seqfeature_Location (
       Oid                  INTEGER NOT NULL,
       Start_Pos            NUMBER(10) NULL,
       End_Pos              NUMBER(10) NULL,
       Strand               NUMBER(1) DEFAULT 0 NOT NULL
                                   CONSTRAINT Strand62
                                          CHECK (Strand IN (-1, 0, 1)),
       Rank                 NUMBER(4) NOT NULL,
       Fea_Oid              INTEGER NOT NULL,
       DBX_Oid              INTEGER NULL,
       CONSTRAINT XPKSeqfeature_Location 
              PRIMARY KEY (Oid)
       USING INDEX
    	 TABLESPACE &biosql_index
 	 ,
       CONSTRAINT XAK1Seqfeature_Location
       UNIQUE (
              Fea_Oid,
              Rank
       )
       USING INDEX
    	 TABLESPACE &biosql_index
 	 --
)
;

CREATE INDEX XIE0Seqfeature_Location ON SG_Seqfeature_Location
(
       DBX_Oid
)
    	 TABLESPACE &biosql_index
;

CREATE INDEX XIE1Seqfeature_Location ON SG_Seqfeature_Location
(
       Start_Pos             
)
    	 TABLESPACE &biosql_index
;

CREATE INDEX XIE2Seqfeature_Location ON SG_Seqfeature_Location
(
       End_Pos
)
    	 TABLESPACE &biosql_index
;


DROP TABLE SG_Location_Qualifier_Assoc CASCADE CONSTRAINTS;

CREATE TABLE SG_Location_Qualifier_Assoc (
       Loc_Oid              INTEGER NOT NULL,
       Ont_Oid              INTEGER NOT NULL,
       Value                VARCHAR2(32) NOT NULL
)
;

CREATE INDEX XIFLocation_Qualifier_Assoc ON SG_Location_Qualifier_Assoc
(
       Loc_Oid, Ont_Oid
)
    	 TABLESPACE &biosql_index
;



ALTER TABLE SG_Similarity
       ADD  ( CONSTRAINT FKEntA_Sim
              FOREIGN KEY (Oid)
                             REFERENCES SG_Bioentry_Assoc (Oid) 
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Bioentry_DBXRef_Assoc
       ADD  ( CONSTRAINT FKEnt_DBXEntA
              FOREIGN KEY (Ent_Oid)
                             REFERENCES SG_Bioentry (Oid) 
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Bioentry_DBXRef_Assoc
       ADD  ( CONSTRAINT FKDBX_DBXEntA
              FOREIGN KEY (DBX_Oid)
                             REFERENCES SG_DBXRef (Oid)
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Location_Qualifier_Assoc
       ADD  ( CONSTRAINT FKOnt_LocOntA
              FOREIGN KEY (Ont_Oid)
                             REFERENCES SG_Ontology_Term (Oid)  ) ;


ALTER TABLE SG_Location_Qualifier_Assoc
       ADD  ( CONSTRAINT FKLoc_LocOntA
              FOREIGN KEY (Loc_Oid)
                             REFERENCES SG_Seqfeature_Location (Oid) 
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Seqfeature_Location
       ADD  ( CONSTRAINT FKDBX_Loc
              FOREIGN KEY (DBX_Oid)
                             REFERENCES SG_DBXRef (Oid) ) ;


ALTER TABLE SG_Seqfeature_Location
       ADD  ( CONSTRAINT FKFea_Loc
              FOREIGN KEY (Fea_Oid)
                             REFERENCES SG_Seqfeature (Oid) 
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Seqfeature_Qualifier_Assoc
       ADD  ( CONSTRAINT FKFea_FeaOntA
              FOREIGN KEY (Fea_Oid)
                             REFERENCES SG_Seqfeature (Oid) 
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Seqfeature_Qualifier_Assoc
       ADD  ( CONSTRAINT FKOnt_FeaOntA
              FOREIGN KEY (Ont_Oid)
                             REFERENCES SG_Ontology_Term (Oid)
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Seqfeature_Assoc
       ADD  ( CONSTRAINT FKTgtFea_FeaA
              FOREIGN KEY (Tgt_Fea_Oid)
                             REFERENCES SG_Seqfeature (Oid) 
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Seqfeature_Assoc
       ADD  ( CONSTRAINT FKOnt_FeaA
              FOREIGN KEY (Ont_Oid)
                             REFERENCES SG_Ontology_Term (Oid)
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Seqfeature_Assoc
       ADD  ( CONSTRAINT FKSrcFea_FeaA
              FOREIGN KEY (Src_Fea_Oid)
                             REFERENCES SG_Seqfeature (Oid) 
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Seqfeature
       ADD  ( CONSTRAINT FKOnt_FSrc
              FOREIGN KEY (FSrc_Oid)
                             REFERENCES SG_Ontology_Term (Oid)
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Seqfeature
       ADD  ( CONSTRAINT FKEnt_Fea
              FOREIGN KEY (Ent_Oid)
                             REFERENCES SG_Bioentry (Oid) 
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Seqfeature
       ADD  ( CONSTRAINT FKOnt_Fea
              FOREIGN KEY (Ont_Oid)
                             REFERENCES SG_Ontology_Term (Oid)  ) ;


ALTER TABLE SG_Bioentry_Qualifier_Assoc
       ADD  ( CONSTRAINT FKOnt_EntOntA
              FOREIGN KEY (Ont_Oid)
                             REFERENCES SG_Ontology_Term (Oid)
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Bioentry_Qualifier_Assoc
       ADD  ( CONSTRAINT FKEnt_EntOntA
              FOREIGN KEY (Ent_Oid)
                             REFERENCES SG_Bioentry (Oid) 
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Comment
       ADD  ( CONSTRAINT FKEnt_Cmt
              FOREIGN KEY (Ent_Oid)
                             REFERENCES SG_Bioentry (Oid) 
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Bioentry_Ref_Assoc
       ADD  ( CONSTRAINT FKRef_EntRefA
              FOREIGN KEY (Ref_Oid)
                             REFERENCES SG_Reference (Oid) 
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Bioentry_Ref_Assoc
       ADD  ( CONSTRAINT FKEnt_EntRefA
              FOREIGN KEY (Ent_Oid)
                             REFERENCES SG_Bioentry (Oid) 
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Bioentry_Assoc
       ADD  ( CONSTRAINT FKOnt_EntA
              FOREIGN KEY (Ont_Oid)
                             REFERENCES SG_Ontology_Term (Oid)
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Bioentry_Assoc
       ADD  ( CONSTRAINT FKTgtEnt_EntA
              FOREIGN KEY (Tgt_Ent_Oid)
                             REFERENCES SG_Bioentry (Oid) 
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Bioentry_Assoc
       ADD  ( CONSTRAINT FKSrcEnt_EntA
              FOREIGN KEY (Src_Ent_Oid)
                             REFERENCES SG_Bioentry (Oid) 
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Biosequence
       ADD  ( CONSTRAINT FKEnt_Seq
              FOREIGN KEY (Ent_Oid)
                             REFERENCES SG_Bioentry (Oid) 
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Bioentry
       ADD  ( CONSTRAINT FKTax_Ent
              FOREIGN KEY (Tax_Oid)
                             REFERENCES SG_Taxon (Oid)  ) ;


ALTER TABLE SG_Bioentry
       ADD  ( CONSTRAINT FKDB_Ent
              FOREIGN KEY (DB_Oid)
                             REFERENCES SG_Biodatabase (Oid) 
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Ontology_Term_Assoc
       ADD  ( CONSTRAINT FKTgtOnt_OntA
              FOREIGN KEY (Src_Ont_Oid)
                             REFERENCES SG_Ontology_Term (Oid) 
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Ontology_Term_Assoc
       ADD  ( CONSTRAINT FKSrcOnt_OntA
              FOREIGN KEY (Tgt_Ont_Oid)
                             REFERENCES SG_Ontology_Term (Oid) 
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Ontology_Term_Assoc
       ADD  ( CONSTRAINT FKTypeOnt_OntA
              FOREIGN KEY (Type_Ont_Oid)
                             REFERENCES SG_Ontology_Term (Oid)  ) ;


ALTER TABLE SG_Ontology_Term
       ADD  ( CONSTRAINT FKOnt_Ont
              FOREIGN KEY (Ont_Oid)
                             REFERENCES SG_Ontology_Term ) ;




CREATE TRIGGER BIR_Seqfeature_Location
  BEFORE INSERT
  on SG_Seqfeature_Location
  -- 
  for each row
/* Template for auto-generation of primary key (H.Lapp, lapp@gnf.org) */
/* Default body for BIR_Seqfeature_Location */
BEGIN
IF :new.Oid IS NULL THEN
    SELECT SG_SEQUENCE_Fea.nextval INTO :new.Oid FROM DUAL;
END IF;
END;
/


CREATE TRIGGER BIR_SeqFeature
  BEFORE INSERT
  on SG_Seqfeature
  -- 
  for each row
/* Template for auto-generation of primary key (H.Lapp, lapp@gnf.org) */
/* Default body for BIR_SeqFeature */
BEGIN
IF :new.Oid IS NULL THEN
    SELECT SG_SEQUENCE.nextval INTO :new.Oid FROM DUAL;
END IF;
END;
/


CREATE TRIGGER BIR_Comment
  BEFORE INSERT
  on SG_Comment
  -- 
  for each row
/* Template for auto-generation of primary key (H.Lapp, lapp@gnf.org) */
/* Default body for BIR_Reference */
BEGIN
IF :new.Oid IS NULL THEN
    SELECT SG_SEQUENCE.nextval INTO :new.Oid FROM DUAL;
END IF;
END;
/


CREATE TRIGGER BIR_Reference
  BEFORE INSERT
  on SG_Reference
  -- 
  for each row
/* Template for auto-generation of primary key (H.Lapp, lapp@gnf.org) */
/* Default body for BIR_Reference */
BEGIN
IF :new.Oid IS NULL THEN
    SELECT SG_SEQUENCE.nextval INTO :new.Oid FROM DUAL;
END IF;
END;
/


CREATE TRIGGER BIR_BioEntry_Assoc
  BEFORE INSERT
  on SG_Bioentry_Assoc
  -- 
  for each row
/* Template for auto-generation of primary key (H.Lapp, lapp@gnf.org) */
/* Default body for BIR_BioEntry_Assoc */
BEGIN
IF :new.Oid IS NULL THEN
    SELECT SG_SEQUENCE_ENTA.nextval INTO :new.Oid FROM DUAL;
END IF;
END;
/


CREATE TRIGGER BIR_BioEntry
  BEFORE INSERT
  on SG_Bioentry
  -- 
  for each row
/* Template for auto-generation of primary key (H.Lapp, lapp@gnf.org) */
/* Default body for BIR_BioEntry */
BEGIN
IF :new.Oid IS NULL THEN
    SELECT SG_SEQUENCE.nextval INTO :new.Oid FROM DUAL;
END IF;
END;
/


CREATE TRIGGER BIR_Ontology_Term
  BEFORE INSERT
  on SG_Ontology_Term
  -- 
  for each row
/* Template for auto-generation of primary key (H.Lapp, lapp@gnf.org) */
/* Default body for BIR_Ontology_Term */
BEGIN
IF :new.Oid IS NULL THEN
    SELECT SG_SEQUENCE.nextval INTO :new.Oid FROM DUAL;
END IF;
-- identifier must be non-empty
--IF :new.Identifier IS NULL THEN
--   :new.Identifier := 'GNF:' || LTRIM(TO_CHAR(:new.Oid,'0000000'));
--END IF;
END;
/


CREATE TRIGGER BIR_Taxon
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


CREATE TRIGGER BIR_BioDatabase
  BEFORE INSERT
  on SG_Biodatabase
  -- 
  for each row
/* Template for auto-generation of primary key (H.Lapp, lapp@gnf.org) */
/* Default body for BIR_BioDatabase */
BEGIN
IF :new.Oid IS NULL THEN
    SELECT SG_SEQUENCE.nextval INTO :new.Oid FROM DUAL;
END IF;
END;
/

CREATE TRIGGER BIR_DBXRef
  BEFORE INSERT
  on SG_DBXRef
  -- 
  for each row
/* Template for auto-generation of primary key (H.Lapp, lapp@gnf.org) */
/* Default body for BIR_DBXRef */
BEGIN
IF :new.Oid IS NULL THEN
    SELECT SG_SEQUENCE.nextval INTO :new.Oid FROM DUAL;
END IF;
END;
/

-- CREATE TRIGGER BIR_Biosequence
--   BEFORE INSERT
--   on SG_Biosequence
--   -- 
--   for each row
-- /* Template for auto-generation of primary key (H.Lapp, lapp@gnf.org) */
-- /* Default body for BIR_DBXRef */
-- BEGIN
-- -- division must have a value
-- IF :new.Division IS NULL THEN
--    :new.Division := 'UNK';
-- END IF;
-- END;
-- /


