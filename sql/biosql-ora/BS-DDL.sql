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
DROP SEQUENCE SG_Sequence_ID ;

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
CREATE SEQUENCE SG_Sequence_ID 
INCREMENT BY 1 
START WITH 1 
NOMAXVALUE 
NOMINVALUE 
NOCYCLE
NOORDER
;

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
       Tgt_Frame            NUMBER(1) NULL,
       CONSTRAINT XPKSimilarity 
              PRIMARY KEY (Oid)
       USING INDEX
    	 TABLESPACE &biosql_index
 	 --
)
;


DROP TABLE SG_Chr_Map_Assoc CASCADE CONSTRAINTS;

CREATE TABLE SG_Chr_Map_Assoc (
       Oid                  INTEGER NOT NULL,
       Chr_Start_Pos        NUMBER(15,4) NOT NULL,
       Chr_End_Pos          NUMBER(11,0) NULL,
       Ent_End_Pos          NUMBER(9,0) NULL,
       Ent_Start_Pos        NUMBER(9,0) NULL,
       Strand               NUMBER(1) DEFAULT 0 NOT NULL
                                   CONSTRAINT Strand23
                                          CHECK (Strand IN (-1, 0, 1)),
       Num_Mismatch         NUMBER(3,0) NULL,
       Ent_Oid              INTEGER NOT NULL,
       Chr_Oid              INTEGER NOT NULL,
       Rel_Oid              INTEGER NOT NULL,
       CONSTRAINT XPKChr_Map_Assoc 
              PRIMARY KEY (Oid)
       USING INDEX
    	 TABLESPACE &biosql_index
	 ,
       CONSTRAINT XAK1Chr_Map_Assoc
       UNIQUE (
              Ent_Oid,
              Chr_Oid,
	      Rel_Oid
       )
       USING INDEX
    	 TABLESPACE &biosql_index
 	 --
)
;

CREATE INDEX XIF803Chr_Map_Assoc ON SG_Chr_Map_Assoc
(
       Chr_Oid
)
    	 TABLESPACE &biosql_index
;

CREATE INDEX XIF36Chr_Map_Assoc ON SG_Chr_Map_Assoc
(
       Rel_Oid
)
    	 TABLESPACE &biosql_index
;


DROP TABLE SG_Bioentry_Rel_Assoc CASCADE CONSTRAINTS;

CREATE TABLE SG_Bioentry_Rel_Assoc (
       Rel_Oid              INTEGER NOT NULL,
       Ent_Oid              INTEGER NOT NULL,
       CONSTRAINT XPKBioentry_Rel_Assoc 
              PRIMARY KEY (Rel_Oid, Ent_Oid)
       USING INDEX
    	 TABLESPACE &biosql_index
 	 --
)
;

CREATE INDEX XIF802Bioentry_Rel_Assoc ON SG_Bioentry_Rel_Assoc
(
       Ent_Oid
)
    	 TABLESPACE &biosql_index
;


DROP TABLE SG_DB_Release CASCADE CONSTRAINTS;

CREATE TABLE SG_DB_Release (
       Oid                  INTEGER NOT NULL,
       Version              VARCHAR2(16) NOT NULL,
       Rel_Date             DATE NULL,
       DB_Oid               INTEGER NOT NULL,
       CONSTRAINT XPKDB_Release 
              PRIMARY KEY (Oid)
       USING INDEX
    	 TABLESPACE &biosql_index
 	 ,
       CONSTRAINT XAK1DB_Release
       UNIQUE (
              Version,
              DB_Oid
       )
       USING INDEX
    	 TABLESPACE &biosql_index
 	 --
)
;

CREATE INDEX XIF799DB_Release ON SG_DB_Release
(
       DB_Oid 
)
    	 TABLESPACE &biosql_index
;


DROP TABLE SG_Chromosome CASCADE CONSTRAINTS;

CREATE TABLE SG_Chromosome (
       Oid                  INTEGER NOT NULL,
       Name                 VARCHAR2(12) NOT NULL,
       Length               INTEGER NULL,
       Tax_Oid              INTEGER NOT NULL,
       CONSTRAINT XPKChromosome 
              PRIMARY KEY (Oid)
       USING INDEX
    	 TABLESPACE &biosql_index
 	 ,
       CONSTRAINT XAK1Chromosome
       UNIQUE (
              Name,
              Tax_Oid
       )
       USING INDEX
    	 TABLESPACE &biosql_index
 	 --
)
;

CREATE INDEX XIF798Chromosome ON SG_Chromosome
(
       Tax_Oid
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
)
;

CREATE INDEX XIF795Seqfeature_Assoc ON SG_Seqfeature_Assoc
(
       Tgt_Fea_Oid           
)
    	 TABLESPACE &biosql_index
;

CREATE INDEX XIF797Seqfeature_Assoc ON SG_Seqfeature_Assoc
(
       Ont_Oid
)
    	 TABLESPACE &biosql_index
;


DROP TABLE SG_Location_Qualifier_Assoc CASCADE CONSTRAINTS;

CREATE TABLE SG_Location_Qualifier_Assoc (
       Loc_Oid              INTEGER NOT NULL,
       Ont_Oid              INTEGER NOT NULL,
       Value                VARCHAR2(32) NOT NULL,
       CONSTRAINT XPKLocation_Qualifier_Assoc 
              PRIMARY KEY (Loc_Oid, Ont_Oid)
       USING INDEX
    	 TABLESPACE &biosql_index
 	 --
)
;

CREATE INDEX XIFLocation_Qualifier_Assoc ON SG_Location_Qualifier_Assoc
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
                                   CONSTRAINT Strand24
                                          CHECK (Strand IN (-1, 0, 1)),
       Rank                 NUMBER(2) NOT NULL,
       Fea_Oid              INTEGER NOT NULL,
       Ent_Oid              INTEGER NULL,
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

CREATE INDEX XIF575Seqfeature_Location ON SG_Seqfeature_Location
(
       Ent_Oid
)
    	 TABLESPACE &biosql_index
;

CREATE INDEX XIE1Seqfeature_Location ON SG_Seqfeature_Location
(
       Start_Pos             
)
    	 TABLESPACE &biosql_index
 	 -- 
;

CREATE INDEX XIE2Seqfeature_Location ON SG_Seqfeature_Location
(
       End_Pos
)
    	 TABLESPACE &biosql_index
 	 -- 
;


DROP TABLE SG_Seqfeature_Qualifier_Assoc CASCADE CONSTRAINTS;

CREATE TABLE SG_Seqfeature_Qualifier_Assoc (
       Fea_Oid              INTEGER NOT NULL,
       Ont_Oid              INTEGER NOT NULL,
       Rank                 NUMBER(2) NOT NULL,
       Value                VARCHAR2(32) NOT NULL,
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


DROP TABLE SG_Seqfeature CASCADE CONSTRAINTS;

CREATE TABLE SG_Seqfeature (
       Oid                  INTEGER NOT NULL,
       Rank                 NUMBER(2) NOT NULL,
       Ent_Oid              INTEGER NOT NULL,
       Ont_Oid              INTEGER NOT NULL,
       FSrc_Oid             INTEGER NULL,
       CONSTRAINT XPKSeqfeature 
              PRIMARY KEY (Oid)
       USING INDEX
    	 TABLESPACE &biosql_index
 	 ,
       CONSTRAINT XAK1Seqfeature
       UNIQUE (
              Ent_Oid,
              Rank,
              Ont_Oid
       )
       USING INDEX
    	 TABLESPACE &biosql_index
 	 --
)
;

CREATE INDEX XIFSeqfeature ON SG_Seqfeature
(
       Ont_Oid
)
    	 TABLESPACE &biosql_index
;


DROP TABLE SG_Seqfeature_Source CASCADE CONSTRAINTS;

CREATE TABLE SG_Seqfeature_Source (
       Oid                  INTEGER NOT NULL,
       Name                 VARCHAR2(64) NOT NULL,
       CONSTRAINT XPKSeqfeature_Source 
              PRIMARY KEY (Oid)
       USING INDEX
    	 TABLESPACE &biosql_index
 	 ,
       CONSTRAINT XAK1Seqfeature_Source
       UNIQUE (
              Name
       )
       USING INDEX
    	 TABLESPACE &biosql_index
 	 --
)
;


DROP TABLE SG_Bioentry_Qualifier_Assoc CASCADE CONSTRAINTS;

CREATE TABLE SG_Bioentry_Qualifier_Assoc (
       Ent_Oid              INTEGER NOT NULL,
       Ont_Oid              INTEGER NOT NULL,
       Value                VARCHAR2(48) NULL,
       CONSTRAINT XPKBioentry_Qualifier_Assoc 
              PRIMARY KEY (Ent_Oid, Ont_Oid)
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


DROP TABLE SG_Comment CASCADE CONSTRAINTS;

CREATE TABLE SG_Comment (
       Rank                 NUMBER(2) NOT NULL,
       Comment_Text         VARCHAR2(4000) NOT NULL,
       Ent_Oid              INTEGER NOT NULL,
       CONSTRAINT XAK1Comment
       UNIQUE (
              Ent_Oid,
              Rank
       )
       USING INDEX
    	 TABLESPACE &biosql_index
 	 --
)
    	 TABLESPACE &biosql_lob
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


DROP TABLE SG_Reference CASCADE CONSTRAINTS;

CREATE TABLE SG_Reference (
       Oid                  INTEGER NOT NULL,
       Title                VARCHAR2(256) NOT NULL,
       Authors              VARCHAR2(512) NOT NULL,
       Location             VARCHAR2(256) NOT NULL,
       Document_ID          INTEGER NULL,
       CONSTRAINT XPKReference 
              PRIMARY KEY (Oid)
       USING INDEX
    	 TABLESPACE &biosql_index
 	 ,
       CONSTRAINT XAK1Reference
       UNIQUE (
              Title,
              Authors
       )
       USING INDEX
    	 TABLESPACE &biosql_index
 	 ,
       CONSTRAINT XAK2Reference
       UNIQUE (
              Document_ID
       )
       USING INDEX
    	 TABLESPACE &biosql_index
 	 --
)
;


DROP TABLE SG_Bioentry_Assoc CASCADE CONSTRAINTS;

CREATE TABLE SG_Bioentry_Assoc (
       Oid                  INTEGER NOT NULL,
       Ont_Oid              INTEGER NOT NULL,
       Tgt_Ent_Oid          INTEGER NOT NULL,
       Src_Ent_Oid          INTEGER NOT NULL,
       CONSTRAINT XPKBioentry_Assoc 
              PRIMARY KEY (Oid)
       USING INDEX
    	 TABLESPACE &biosql_index
 	 --
)
;

CREATE INDEX XIFBioentry_Assoc ON SG_Bioentry_Assoc
(
       Src_Ent_Oid           
)
    	 TABLESPACE &biosql_index
;

CREATE INDEX XIF572Bioentry_Assoc ON SG_Bioentry_Assoc
(
       Tgt_Ent_Oid           
)
    	 TABLESPACE &biosql_index
;

CREATE INDEX XIF574Bioentry_Assoc ON SG_Bioentry_Assoc
(
       Ont_Oid
)
    	 TABLESPACE &biosql_index
;


DROP TABLE SG_Biosequence CASCADE CONSTRAINTS;

CREATE TABLE SG_Biosequence (
       Oid                  INTEGER NOT NULL,
       Version              NUMBER(3,1) NULL,
       Length               INTEGER NULL,
       Seq                  CLOB NULL,
       CONSTRAINT XPKBiosequence 
              PRIMARY KEY (Oid)
       USING INDEX
    	 TABLESPACE &biosql_index
 	 --
)
    	 TABLESPACE &biosql_lob
;


DROP TABLE SG_Bioentry CASCADE CONSTRAINTS;

CREATE TABLE SG_Bioentry (
       Oid                  INTEGER NOT NULL,
       Accession            VARCHAR2(32) NOT NULL,
       Identifier           VARCHAR2(32) NULL,
       Name                 VARCHAR2(32) NULL,
       Description          VARCHAR2(128) NULL,
       Version              NUMBER(2) NULL,
       Division             VARCHAR2(3) DEFAULT 'UNK' NOT NULL,
       Molecule             VARCHAR2(6) DEFAULT 'UNK' NOT NULL
                                   CONSTRAINT Molecule8
                                          CHECK (Molecule IN ('DNA', 'mRNA', 'RNA', 'PRT', 'UNK')),
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
              Version,
              DB_Oid
       )
       USING INDEX
    	 TABLESPACE &biosql_index
 	 ,
       CONSTRAINT XAK2Bioentry
       UNIQUE (
              Identifier,
              DB_Oid
       )
       USING INDEX
    	 TABLESPACE &biosql_index
 	 --
)
;

CREATE INDEX XIFBioentry ON SG_Bioentry
(
       DB_Oid
)
    	 TABLESPACE &biosql_index
;

CREATE INDEX XIF569Bioentry ON SG_Bioentry
(
       Tax_Oid
)
    	 TABLESPACE &biosql_index
;

CREATE INDEX XIE1Bioentry ON SG_Bioentry
(
       Name   
)
    	 TABLESPACE &biosql_index
 	 -- 
;

CREATE INDEX XIE2Bioentry ON SG_Bioentry
(
       Accession
)
    	 TABLESPACE &biosql_index
 	 -- 
;


DROP TABLE SG_Ontology_Term_Assoc CASCADE CONSTRAINTS;

CREATE TABLE SG_Ontology_Term_Assoc (
       Src_Ont_Oid          INTEGER NOT NULL,
       Type_Ont_Oid         INTEGER NOT NULL,
       Tgt_Ont_Oid          INTEGER NOT NULL,
       CONSTRAINT XPKOntology_Term_Assoc 
              PRIMARY KEY (Src_Ont_Oid, Type_Ont_Oid, Tgt_Ont_Oid)
       USING INDEX
    	 TABLESPACE &biosql_index
 	 --
)
;

CREATE INDEX XIF30Ontology_Term_Assoc ON SG_Ontology_Term_Assoc
(
       Type_Ont_Oid          
)
    	 TABLESPACE &biosql_index
;

CREATE INDEX XIF31Ontology_Term_Assoc ON SG_Ontology_Term_Assoc
(
       Tgt_Ont_Oid           
)
    	 TABLESPACE &biosql_index
;


DROP TABLE SG_Ontology_Term CASCADE CONSTRAINTS;

CREATE TABLE SG_Ontology_Term (
       Oid                  INTEGER NOT NULL,
       Name                 VARCHAR2(72) NOT NULL,
       Identifier           VARCHAR2(16) NOT NULL,
       Definition           VARCHAR2(1000) NULL,
       CONSTRAINT XPKOntology_Term 
              PRIMARY KEY (Oid)
       USING INDEX
    	 TABLESPACE &biosql_index
 	 ,
       CONSTRAINT XAK1Ontology_Term
       UNIQUE (
              Name
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


DROP TABLE SG_Taxon CASCADE CONSTRAINTS;

CREATE TABLE SG_Taxon (
       Oid                  INTEGER NOT NULL,
       Name                 VARCHAR2(96) NOT NULL,
       Common_Name          VARCHAR2(80) NULL,
       NCBI_Taxon_ID        NUMBER(8) NULL,
       Node_Type            VARCHAR2(16) NULL,
       Tax_Oid              INTEGER NULL,
       CONSTRAINT XPKTaxon 
              PRIMARY KEY (Oid)
       USING INDEX
    	 TABLESPACE &biosql_index
 	 ,
       CONSTRAINT XAK1Taxon
       UNIQUE (
              Name,
	      Tax_Oid
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

CREATE INDEX XIF34Taxon ON SG_Taxon
(
       Tax_Oid
)
    	 TABLESPACE &biosql_index
;

CREATE INDEX XIFTaxon ON SG_Taxon
(
       Common_Name
)
    	 TABLESPACE &biosql_index
;


DROP TABLE SG_Biodatabase CASCADE CONSTRAINTS;

CREATE TABLE SG_Biodatabase (
       Oid                  INTEGER NOT NULL,
       Name                 VARCHAR2(32) NOT NULL,
       Acronym              VARCHAR2(6) NULL,
       Organization         VARCHAR2(32) NULL,
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
)
;


ALTER TABLE SG_Similarity
       ADD  ( CONSTRAINT FKEntA_Sim
              FOREIGN KEY (Oid)
                             REFERENCES SG_Bioentry_Assoc (Oid) 
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Chr_Map_Assoc
       ADD  ( CONSTRAINT FKEnt_ChrEntA
              FOREIGN KEY (Ent_Oid)
                             REFERENCES SG_Bioentry (Oid) 
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Chr_Map_Assoc
       ADD  ( CONSTRAINT FKRel_ChrEntA
              FOREIGN KEY (Rel_Oid)
                             REFERENCES SG_DB_Release (Oid)
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Chr_Map_Assoc
       ADD  ( CONSTRAINT FKChr_ChrEntA
              FOREIGN KEY (Chr_Oid)
                             REFERENCES SG_Chromosome (Oid)  ) ;


ALTER TABLE SG_Bioentry_Rel_Assoc
       ADD  ( CONSTRAINT FKEnt_EntRelA
              FOREIGN KEY (Ent_Oid)
                             REFERENCES SG_Bioentry (Oid) 
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Bioentry_Rel_Assoc
       ADD  ( CONSTRAINT FKRel_EntRelA
              FOREIGN KEY (Rel_Oid)
                             REFERENCES SG_DB_Release (Oid) 
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_DB_Release
       ADD  ( CONSTRAINT FKDB_Rel
              FOREIGN KEY (DB_Oid)
                             REFERENCES SG_Biodatabase (Oid) 
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Chromosome
       ADD  ( CONSTRAINT FKTax_Chr
              FOREIGN KEY (Tax_Oid)
                             REFERENCES SG_Taxon (Oid)  ) ;


ALTER TABLE SG_Seqfeature_Assoc
       ADD  ( CONSTRAINT FKOnt_FeaA
              FOREIGN KEY (Ont_Oid)
                             REFERENCES SG_Ontology_Term (Oid)  ) ;


ALTER TABLE SG_Seqfeature_Assoc
       ADD  ( CONSTRAINT FKSrcFea_FeaA
              FOREIGN KEY (Src_Fea_Oid)
                             REFERENCES SG_Seqfeature (Oid) 
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Seqfeature_Assoc
       ADD  ( CONSTRAINT FKTgtFea_FeaA
              FOREIGN KEY (Tgt_Fea_Oid)
                             REFERENCES SG_Seqfeature (Oid) 
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
       ADD  ( CONSTRAINT FKEnt_Loc
              FOREIGN KEY (Ent_Oid)
                             REFERENCES SG_Bioentry (Oid)  ) ;


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
                             REFERENCES SG_Ontology_Term (Oid)  ) ;


ALTER TABLE SG_Seqfeature
       ADD  ( CONSTRAINT FKEnt_Fea
              FOREIGN KEY (Ent_Oid)
                             REFERENCES SG_Bioentry (Oid) 
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Seqfeature
       ADD  ( CONSTRAINT FKFSrc_Fea
              FOREIGN KEY (FSrc_Oid)
                             REFERENCES SG_Seqfeature_Source (Oid)  ) ;


ALTER TABLE SG_Seqfeature
       ADD  ( CONSTRAINT FKOnt_Fea
              FOREIGN KEY (Ont_Oid)
                             REFERENCES SG_Ontology_Term (Oid)  ) ;


ALTER TABLE SG_Bioentry_Qualifier_Assoc
       ADD  ( CONSTRAINT FKOnt_EntOntA
              FOREIGN KEY (Ont_Oid)
                             REFERENCES SG_Ontology_Term (Oid)  ) ;


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
                             REFERENCES SG_Ontology_Term (Oid)  ) ;


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
              FOREIGN KEY (Oid)
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


ALTER TABLE SG_Taxon
       ADD  ( CONSTRAINT FKTax_Tax
	      FOREIGN KEY (Tax_Oid)
                             REFERENCES SG_Taxon (Oid) ) ;



CREATE TRIGGER BIR_Chr_Map_Assoc
  BEFORE INSERT
  on SG_Chr_Map_Assoc
  -- 
  for each row
/* Template for auto-generation of primary key (H.Lapp, lapp@gnf.org) */
/* Default body for BIR_Chr_Map_Assoc */
BEGIN
IF :new.Oid IS NULL THEN
    SELECT SG_SEQUENCE.nextval INTO :new.Oid FROM DUAL;
END IF;
END;
/


CREATE TRIGGER BIR_DB_Release
  BEFORE INSERT
  on SG_DB_Release
  -- 
  for each row
/* Template for auto-generation of primary key (H.Lapp, lapp@gnf.org) */
/* Default body for BIR_DB_Release */
BEGIN
IF :new.Oid IS NULL THEN
    SELECT SG_SEQUENCE.nextval INTO :new.Oid FROM DUAL;
END IF;
END;
/


CREATE TRIGGER BIR_Chromosome
  BEFORE INSERT
  on SG_Chromosome
  -- 
  for each row
/* Template for auto-generation of primary key (H.Lapp, lapp@gnf.org) */
/* Default body for BIR_Chromosome */
BEGIN
IF :new.Oid IS NULL THEN
    SELECT SG_SEQUENCE.nextval INTO :new.Oid FROM DUAL;
END IF;
END;
/


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


CREATE TRIGGER BIR_Seqfeature_Source
  BEFORE INSERT
  on SG_Seqfeature_Source
  -- 
  for each row
/* Template for auto-generation of primary key (H.Lapp, lapp@gnf.org) */
/* Default body for BIR_Seqfeature_Source */
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
    SELECT SG_SEQUENCE.nextval INTO :new.Oid FROM DUAL;
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
-- division must have a value
IF :new.Division IS NULL THEN
   :new.Division := 'UNK';
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
IF :new.Identifier IS NULL THEN
   :new.Identifier := 'GNF:' || LTRIM(TO_CHAR(:new.Oid,'0000000'));
END IF;
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


