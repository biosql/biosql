--
-- SQL script to instantiate the SYMGENE/BioSQL database schema.
--
--
-- $GNF: projects/gi/symgene/src/DB/BS-DDL.sql,v 1.34 2003/07/08 22:48:35 hlapp Exp $
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
@BS-defs-local

-- instantiate the schema:

DROP SEQUENCE SG_Sequence ;
DROP SEQUENCE SG_Sequence_Fea ;
DROP SEQUENCE SG_Sequence_EntA ;
DROP SEQUENCE SG_Sequence_FeaA ;
DROP SEQUENCE SG_Sequence_TrmA ;
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
CREATE SEQUENCE SG_Sequence_FeaA 
	INCREMENT BY 1 
	START WITH 1 
	NOMAXVALUE 
	NOMINVALUE 
	NOCYCLE
	NOORDER
;
CREATE SEQUENCE SG_Sequence_TrmA 
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
       Description	    VARCHAR2(256) NULL,
       Acronym              VARCHAR2(12) NULL,
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


DROP TABLE SG_Biodatabase_Qualifier_Assoc CASCADE CONSTRAINTS;

CREATE TABLE SG_Biodatabase_Qualifier_Assoc (
	DB_Oid			INTEGER NOT NULL,
	Trm_Oid			INTEGER NOT NULL,
	Rank			NUMBER(3),
	Value			VARCHAR2(512),
	CONSTRAINT XPKBiodatabase_Qualifier_Assoc
		PRIMARY KEY (Trm_Oid, DB_Oid)
	USING INDEX
	TABLESPACE &biosql_index
	--
)
;


DROP TABLE SG_Taxon CASCADE CONSTRAINTS;

CREATE TABLE SG_Taxon (
	Oid			INTEGER NOT NULL , 
	NCBI_Taxon_ID		INTEGER, 
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

CREATE INDEX XIF1Taxon ON SG_Taxon
(
       Tax_Oid
)
    	 TABLESPACE &biosql_index
;


-- corresponds to the names table of the NCBI taxonomy databaase 
DROP TABLE SG_Taxon_Name CASCADE CONSTRAINTS ;

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

CREATE INDEX XIF1Taxon_Name ON SG_Taxon_Name (
       Tax_Oid
)
	 TABLESPACE &biosql_index
; 


DROP TABLE SG_Ontology CASCADE CONSTRAINTS ;

CREATE TABLE SG_Ontology (
	Oid  		 INTEGER NOT NULL, 
	Name		 VARCHAR2(64) NOT NULL,
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


DROP TABLE SG_Term CASCADE CONSTRAINTS;

CREATE TABLE SG_Term (
       Oid                  INTEGER NOT NULL,
       Name                 VARCHAR2(256) NOT NULL,
       Identifier           VARCHAR2(16) NULL,
       Definition           VARCHAR2(4000) NULL,
       Is_Obsolete	    VARCHAR2(1) NULL
       			    	CONSTRAINT IsObsolete1
       			    		CHECK (Is_Obsolete = 'X'),
       Ont_Oid              INTEGER NOT NULL,
       CONSTRAINT XPKTerm 
              PRIMARY KEY (Oid)
       USING INDEX
    	 TABLESPACE &biosql_index
 	 ,
       CONSTRAINT XAK1Term
       UNIQUE (
              Name,
              Ont_Oid
       )
       USING INDEX
    	 TABLESPACE &biosql_index
 	 ,
       CONSTRAINT XAK2Term
       UNIQUE (
              Identifier
       )
       USING INDEX
    	 TABLESPACE &biosql_index
 	 --
)
;


--
-- Ontology Term to DBXref associations
--
DROP TABLE SG_Term_DBXref_Assoc CASCADE CONSTRAINTS ;

CREATE TABLE SG_Term_DBXRef_Assoc ( 
	Trm_Oid		INTEGER NOT NULL, 
	DBX_Oid		INTEGER NOT NULL , 
	Rank 		NUMBER(3), 
	CONSTRAINT XPKTerm_DBXRef_Assoc
		PRIMARY KEY (Trm_Oid , DBX_Oid)
	USING INDEX
	TABLESPACE &biosql_index
	--
)
;

CREATE INDEX XIF1Term_DBXRef_Assoc ON SG_Term_DBXRef_Assoc
(
	DBX_Oid
)
    	 TABLESPACE &biosql_index
;

--
-- Ontology Term synonyms
--
DROP TABLE SG_Term_Synonym CASCADE CONSTRAINTS ;

CREATE TABLE SG_Term_Synonym (
	Name			VARCHAR2(256) NOT NULL,
	Trm_Oid			INTEGER NOT NULL,
       	CONSTRAINT XPKTerm_Synonym
		PRIMARY KEY (Name, Trm_Oid)
	USING INDEX
    	TABLESPACE &biosql_index
	-- 
)
;

CREATE INDEX XIF1Term_Synonym ON SG_Term_Synonym
(
	Trm_Oid
)
    	 TABLESPACE &biosql_index
;


DROP TABLE SG_Term_Assoc CASCADE CONSTRAINTS;

CREATE TABLE SG_Term_Assoc (
       Oid   		    INTEGER NOT NULL,
       Subj_Trm_Oid         INTEGER NOT NULL,
       Pred_Trm_Oid         INTEGER NOT NULL,
       Obj_Trm_Oid          INTEGER NOT NULL,
       Ont_Oid		    INTEGER NOT NULL,
       -- This lets one associate a single term with a term_relationship 
       -- effecively allowing us to treat triples as 1st class terms.
       -- http://www.open-bio.org/pipermail/biosql-l/2003-October/000455.html
       Trm_Oid              INTEGER NULL,
       CONSTRAINT XPKTerm_Assoc 
              PRIMARY KEY (Oid)
       USING INDEX
       TABLESPACE &biosql_index
       ,
       CONSTRAINT XAK1Term_Assoc
              UNIQUE (Subj_Trm_Oid, Pred_Trm_Oid, Obj_Trm_Oid, Ont_Oid)
       USING INDEX
       TABLESPACE &biosql_index
       ,
       CONSTRAINT XAK2Term_Assoc
              UNIQUE (Trm_Oid)
       USING INDEX
       TABLESPACE &biosql_index
       --
);


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


DROP TABLE SG_Term_Path CASCADE CONSTRAINTS ;

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


DROP TABLE SG_Bioentry CASCADE CONSTRAINTS;

CREATE TABLE SG_Bioentry (
       Oid                  INTEGER NOT NULL,
       Accession            VARCHAR2(32) NOT NULL,
       Identifier           VARCHAR2(32) NULL,
       Name           	    VARCHAR2(32) NOT NULL,
       Description          VARCHAR2(512) NULL,
       Version              NUMBER(2) DEFAULT 0 NOT NULL,
       Division             VARCHAR2(6) DEFAULT 'UNK' NULL,
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
       Name
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
       Subj_Ent_Oid         INTEGER NOT NULL,
       Trm_Oid              INTEGER NOT NULL,
       Obj_Ent_Oid          INTEGER NOT NULL,
       Rank		    NUMBER(6) NULL,
       CONSTRAINT XPKBioentry_Assoc 
              PRIMARY KEY (Oid)
       USING INDEX
    	 TABLESPACE &biosql_index
	 ,
       CONSTRAINT XAK1Bioentry_Assoc
       UNIQUE (
	      Subj_Ent_Oid,
	      Obj_Ent_Oid,
	      Trm_Oid
       )
       USING INDEX
    	 TABLESPACE &biosql_index
 	 --
)
;

CREATE INDEX XIF1Bioentry_Assoc ON SG_Bioentry_Assoc
(
       Obj_Ent_Oid
)
    	 TABLESPACE &biosql_index
;

CREATE INDEX XIF2Bioentry_Assoc ON SG_Bioentry_Assoc
(
       Trm_Oid
)
    	 TABLESPACE &biosql_index
;


DROP TABLE SG_Bioentry_Path CASCADE CONSTRAINTS ;

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


DROP TABLE SG_Similarity CASCADE CONSTRAINTS;

CREATE TABLE SG_Similarity (
       Oid                  INTEGER NOT NULL,
       Score                NUMBER(10) NULL,
       Expect_Mantissa      FLOAT NULL,
       Expect_Exponent	    NUMBER(3) NULL,
       Pct_Identity         NUMBER(5,2) NULL,
       Pct_Coverage         NUMBER(5,2) NULL,
       Subj_Start_Pos        NUMBER(10) NOT NULL,
       Subj_End_Pos          NUMBER(10) NOT NULL,
       Subj_Strand           NUMBER(1) NULL
                                   CONSTRAINT Strand22
                                          CHECK (Subj_Strand IN (-1, 0, 1)),
       Subj_Frame            NUMBER(1) NULL
                                   CONSTRAINT Frame8
                                          CHECK (Subj_Frame IN (0, 1, 2)),
       Obj_Start_Pos        NUMBER(10) NOT NULL,
       Obj_End_Pos          NUMBER(10) NOT NULL,
       Obj_Strand           NUMBER(1) NULL,
       Obj_Frame            NUMBER(1) NULL
                                   CONSTRAINT Frame9
                                          CHECK (Obj_Frame IN (0, 1, 2)),
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
       Trm_Oid              INTEGER NOT NULL,
       Rank		    NUMBER(5) NOT NULL,
       Value                VARCHAR2(4000) NULL,
       CONSTRAINT XPKBioentry_Qualifier_Assoc 
              PRIMARY KEY (Ent_Oid, Trm_Oid, Rank)
       USING INDEX
    	 TABLESPACE &biosql_index
 	 --
)
;

CREATE INDEX XIFBioentry_Qualifier_Assoc ON SG_Bioentry_Qualifier_Assoc
(
       Trm_Oid
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
                                          CHECK (Alphabet IN ('dna','DNA','protein','PROTEIN','rna','RNA')),
       Seq                  CLOB NULL,
       CRC                  VARCHAR2(32) NULL,
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
       Accession            VARCHAR2(64) NOT NULL,
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
       Rank		    NUMBER(4) DEFAULT 0 NOT NULL,
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


--
-- DBXref to Ontology Term associations (qualifier/value pairs)
--
DROP TABLE SG_DBXRef_Qualifier_Assoc CASCADE CONSTRAINTS ;

CREATE TABLE SG_DBXRef_Qualifier_Assoc ( 
	DBX_Oid			INTEGER NOT NULL, 
	Trm_Oid			INTEGER NOT NULL, 
	Rank			NUMBER(3) DEFAULT 0 NOT NULL, 
	Value			VARCHAR2(256), 
	CONSTRAINT XPKDBXRef_Qualifier_Assoc
		PRIMARY KEY (DBX_Oid, Trm_Oid, Rank)
	USING INDEX
    	TABLESPACE &biosql_index
	--
)
; 

CREATE INDEX XIF1DBXRef_Qualifier_Assoc ON SG_DBXRef_Qualifier_Assoc
(
	Trm_Oid
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
       CRC                  VARCHAR2(32) NULL,
       DBX_Oid              INTEGER NULL,
       CONSTRAINT XPKReference 
              PRIMARY KEY (Oid)
       USING INDEX
    	 TABLESPACE &biosql_index
 	 ,
       CONSTRAINT XAK2Reference
       UNIQUE (
              DBX_Oid
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
       Rank                 NUMBER(4) NOT NULL,
       Start_Pos            NUMBER(10) NULL,
       End_Pos              NUMBER(10) NULL,
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
       Display_Name	    VARCHAR2(64) NULL,
       Ent_Oid              INTEGER NOT NULL,
       Type_Trm_Oid         INTEGER NOT NULL,
       Source_Trm_Oid       INTEGER NOT NULL,
       CONSTRAINT XPKSeqfeature 
              PRIMARY KEY (Oid)
       USING INDEX
    	 TABLESPACE &biosql_index
 	 ,
       CONSTRAINT XAK1Seqfeature
       UNIQUE (
              Ent_Oid,
              Type_Trm_Oid,
	      Source_Trm_Oid,
              Rank
       )
       USING INDEX
    	 TABLESPACE &biosql_index
 	 --
)
;

CREATE INDEX XIF1Seqfeature ON SG_Seqfeature
(
       Type_Trm_Oid
)
    	 TABLESPACE &biosql_index
;

CREATE INDEX XIF2Seqfeature ON SG_Seqfeature
(
       Source_Trm_Oid
)
    	 TABLESPACE &biosql_index
;


DROP TABLE SG_Seqfeature_Assoc CASCADE CONSTRAINTS;

CREATE TABLE SG_Seqfeature_Assoc (
	Oid		     INTEGER NOT NULL,
	Subj_Fea_Oid         INTEGER NOT NULL,
	Obj_Fea_Oid          INTEGER NOT NULL,
       	Trm_Oid              INTEGER NOT NULL,
       	Rank                 NUMBER(3) NOT NULL,
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

CREATE INDEX XIFSeqfeature_Assoc ON SG_Seqfeature_Assoc
(
       Obj_Fea_Oid
)
    	 TABLESPACE &biosql_index
;

CREATE INDEX XIF2Seqfeature_Assoc ON SG_Seqfeature_Assoc
(
       Trm_Oid
)
    	 TABLESPACE &biosql_index
;


DROP TABLE SG_Seqfeature_Path CASCADE CONSTRAINTS ;

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

CREATE INDEX XIF2Seqfeature_Path ON SG_Seqfeature_Path
(
       Trm_Oid
)
    	 TABLESPACE &biosql_index
;


DROP TABLE SG_Seqfeature_Qualifier_Assoc CASCADE CONSTRAINTS;

CREATE TABLE SG_Seqfeature_Qualifier_Assoc (
       Fea_Oid              INTEGER NOT NULL,
       Trm_Oid              INTEGER NOT NULL,
       Rank                 NUMBER(3) NOT NULL,
       Value                VARCHAR2(4000) NULL,
       CONSTRAINT XPKSeqfeature_Qualifier_Assoc 
              PRIMARY KEY (Fea_Oid, Trm_Oid, Rank)
       USING INDEX
    	 TABLESPACE &biosql_index
 	 --
)
;

CREATE INDEX XIFSeqfeature_Qualifier_Assoc ON SG_Seqfeature_Qualifier_Assoc
(
       Trm_Oid
)
    	 TABLESPACE &biosql_index
;


--
-- Seqfeature to DBXref associations
--
DROP TABLE SG_Seqfeature_DBXref_Assoc CASCADE CONSTRAINTS ;

CREATE TABLE SG_Seqfeature_DBXref_Assoc ( 
	Fea_Oid			INTEGER NOT NULL, 
	DBX_Oid			INTEGER NOT NULL, 
	Rank			NUMBER(3), 
	CONSTRAINT XPKSeqfeature_DBXref_Assoc
		PRIMARY KEY (Fea_Oid, DBX_Oid)
	USING INDEX
    	TABLESPACE &biosql_index
	--
)
; 

CREATE INDEX XIF1Seqfeature_DBXref_Assoc On SG_Seqfeature_DBXref_Assoc
(
	DBX_Oid
)
    	TABLESPACE &biosql_index
; 


DROP TABLE SG_Location CASCADE CONSTRAINTS;

CREATE TABLE SG_Location (
       Oid                  INTEGER NOT NULL,
       Start_Pos            NUMBER(10) NULL,
       End_Pos              NUMBER(10) NULL,
       Strand               NUMBER(1) DEFAULT 0 NOT NULL
                                   CONSTRAINT Strand62
                                          CHECK (Strand IN (-1, 0, 1)),
       Rank                 NUMBER(4) NOT NULL,
       Fea_Oid              INTEGER NOT NULL,
       DBX_Oid              INTEGER NULL,
       Trm_Oid              INTEGER NULL,
       CONSTRAINT XPKLocation 
              PRIMARY KEY (Oid)
       USING INDEX
    	 TABLESPACE &biosql_index
 	 ,
       CONSTRAINT XAK1Location
       UNIQUE (
              Fea_Oid,
              Rank
       )
       USING INDEX
    	 TABLESPACE &biosql_index
 	 --
)
;

CREATE INDEX XIE0Location ON SG_Location
(
       DBX_Oid
)
    	 TABLESPACE &biosql_index
;

CREATE INDEX XIE1Location ON SG_Location
(
       Start_Pos, End_Pos             
)
    	 TABLESPACE &biosql_index
;

CREATE INDEX XIF2Location ON SG_Location
(
       Trm_Oid
)
    	 TABLESPACE &biosql_index
;


DROP TABLE SG_Location_Qualifier_Assoc CASCADE CONSTRAINTS;

CREATE TABLE SG_Location_Qualifier_Assoc (
       Loc_Oid              INTEGER NOT NULL,
       Trm_Oid              INTEGER NOT NULL,
       Value                VARCHAR2(32) NOT NULL
)
;

CREATE INDEX XIFLocation_Qualifier_Assoc ON SG_Location_Qualifier_Assoc
(
       Loc_Oid, Trm_Oid
)
    	 TABLESPACE &biosql_index
;


--
-- Foreign key constraints
--

--
-- Similarity table
--

ALTER TABLE SG_Similarity
       ADD  ( CONSTRAINT FKEntA_Sim
              FOREIGN KEY (Oid)
                             REFERENCES SG_Bioentry_Assoc (Oid) 
                             ON DELETE CASCADE ) ;

--
-- Taxon and Taxon Name tables
--

-- unfortunately, we can't constrain parent_taxon_id as it is violated
-- occasionally by the downloads available from NCBI
-- ALTER TABLE SG_Taxon
--        ADD  ( CONSTRAINT FKTax_Tax
--               FOREIGN KEY (Tax_Oid)
--                              REFERENCES SG_Taxon (Oid)
-- 			     DEFERRABLE ) ;


ALTER TABLE SG_Taxon_Name
       ADD  ( CONSTRAINT FKTax_Tnm
              FOREIGN KEY (Tax_Oid)
                             REFERENCES SG_Taxon (Oid)
			     ON DELETE CASCADE ) ;


--
-- Ontology Term table
--

ALTER TABLE SG_Term
       ADD  ( CONSTRAINT FKOnt_Trm
              FOREIGN KEY (Ont_Oid)
                             REFERENCES SG_Ontology (Oid)
			     ON DELETE CASCADE ) ;


--
-- Term Synonyms
--

ALTER TABLE SG_Term_Synonym
       ADD  ( CONSTRAINT FKTrm_TSyn
              FOREIGN KEY (Trm_Oid)
                             REFERENCES SG_Term (Oid)
			     ON DELETE CASCADE ) ;


--
-- Term-DBXref associations
--

ALTER TABLE SG_Term_DBXRef_Assoc
       ADD  ( CONSTRAINT FKTrm_TrmDBXA
              FOREIGN KEY (Trm_Oid)
                             REFERENCES SG_Term (Oid)
			     ON DELETE CASCADE ) ;


ALTER TABLE SG_Term_DBXRef_Assoc
       ADD  ( CONSTRAINT FKDBX_TrmDBXA
              FOREIGN KEY (DBX_Oid)
                             REFERENCES SG_DBXRef (Oid)
			     ON DELETE CASCADE ) ;


--
-- Term to Term associations
--

ALTER TABLE SG_Term_Assoc
       ADD  ( CONSTRAINT FKTrm_TrmASubj
              FOREIGN KEY (Subj_Trm_Oid)
                             REFERENCES SG_Term (Oid) 
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Term_Assoc
       ADD  ( CONSTRAINT FKTrm_TrmAObj
              FOREIGN KEY (Obj_Trm_Oid)
                             REFERENCES SG_Term (Oid) 
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Term_Assoc
       ADD  ( CONSTRAINT FKTrm_TrmAPred
              FOREIGN KEY (Pred_Trm_Oid)
                             REFERENCES SG_Term (Oid)  ) ;


ALTER TABLE SG_Term_Assoc
       ADD  ( CONSTRAINT FKOnt_TrmA
              FOREIGN KEY (Ont_Oid)
                             REFERENCES SG_Ontology (Oid)
			     ON DELETE CASCADE ) ;

ALTER TABLE SG_Term_Assoc
       ADD  ( CONSTRAINT FKTrm_TrmA
              FOREIGN KEY (Trm_Oid)
                             REFERENCES SG_Term (Oid)
			     ON DELETE SET NULL ) ;


--
-- Term to Term associations transitive closure table
--

ALTER TABLE SG_Term_Path
       ADD  ( CONSTRAINT FKTrm_TrmPSubj
              FOREIGN KEY (Subj_Trm_Oid)
                             REFERENCES SG_Term (Oid) 
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Term_Path
       ADD  ( CONSTRAINT FKTrm_TrmPObj
              FOREIGN KEY (Obj_Trm_Oid)
                             REFERENCES SG_Term (Oid) 
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Term_Path
       ADD  ( CONSTRAINT FKTrm_TrmPPred
              FOREIGN KEY (Pred_Trm_Oid)
                             REFERENCES SG_Term (Oid)  ) ;


ALTER TABLE SG_Term_Path
       ADD  ( CONSTRAINT FKOnt_TrmP
              FOREIGN KEY (Ont_Oid)
                             REFERENCES SG_Ontology (Oid)
			     ON DELETE CASCADE ) ;


--
-- Biodatabase-Qualifier association table
--

ALTER TABLE SG_Biodatabase_Qualifier_Assoc
	ADD ( CONSTRAINT FKDB_DBTrmA
	      FOREIGN KEY (DB_Oid)
			     REFERENCES SG_Biodatabase (Oid)
			     ON DELETE CASCADE );


ALTER TABLE SG_Biodatabase_Qualifier_Assoc
	ADD ( CONSTRAINT FKTrm_DBTrmA
	      FOREIGN KEY (Trm_Oid)
			     REFERENCES SG_Term (Oid)
			     ON DELETE CASCADE );


--
-- Bioentry table
--

ALTER TABLE SG_Bioentry
       ADD  ( CONSTRAINT FKTax_Ent
              FOREIGN KEY (Tax_Oid)
                             REFERENCES SG_Taxon (Oid)  ) ;


ALTER TABLE SG_Bioentry
       ADD  ( CONSTRAINT FKDB_Ent
              FOREIGN KEY (DB_Oid)
                             REFERENCES SG_Biodatabase (Oid) 
                             ON DELETE CASCADE ) ;

--
-- Biosequence table
--

ALTER TABLE SG_Biosequence
       ADD  ( CONSTRAINT FKEnt_Seq
              FOREIGN KEY (Ent_Oid)
                             REFERENCES SG_Bioentry (Oid) 
                             ON DELETE CASCADE ) ;


--
-- Bioentry-DBXref associations
--

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

--
-- Bioentry-Qualifier associations
--

ALTER TABLE SG_Bioentry_Qualifier_Assoc
       ADD  ( CONSTRAINT FKTrm_EntTrmA
              FOREIGN KEY (Trm_Oid)
                             REFERENCES SG_Term (Oid)
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Bioentry_Qualifier_Assoc
       ADD  ( CONSTRAINT FKEnt_EntTrmA
              FOREIGN KEY (Ent_Oid)
                             REFERENCES SG_Bioentry (Oid) 
                             ON DELETE CASCADE ) ;


--
-- Bioentry-Reference associations
--

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


--
-- Bioentry to Bioentry associations
--

ALTER TABLE SG_Bioentry_Assoc
       ADD  ( CONSTRAINT FKTrm_EntA
              FOREIGN KEY (Trm_Oid)
                             REFERENCES SG_Term (Oid)
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Bioentry_Assoc
       ADD  ( CONSTRAINT FKObjEnt_EntA
              FOREIGN KEY (Obj_Ent_Oid)
                             REFERENCES SG_Bioentry (Oid) 
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Bioentry_Assoc
       ADD  ( CONSTRAINT FKSubjEnt_EntA
              FOREIGN KEY (Subj_Ent_Oid)
                             REFERENCES SG_Bioentry (Oid) 
                             ON DELETE CASCADE ) ;


--
-- Bioentry to Bioentry associations transitive closure table
--

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


--
-- Comment table
--

ALTER TABLE SG_Comment
       ADD  ( CONSTRAINT FKEnt_Cmt
              FOREIGN KEY (Ent_Oid)
                             REFERENCES SG_Bioentry (Oid) 
                             ON DELETE CASCADE ) ;


--
-- Reference table
--

ALTER TABLE SG_Reference
       ADD  ( CONSTRAINT FKDBX_Ref
              FOREIGN KEY (DBX_Oid)
                             REFERENCES SG_DBXRef (Oid) 
                             ON DELETE CASCADE ) ;

--
-- DBXRef-Qualifier associations
--

ALTER TABLE SG_DBXRef_Qualifier_Assoc
       ADD  ( CONSTRAINT FKDBX_DBXTrmA
              FOREIGN KEY (DBX_Oid)
                             REFERENCES SG_DBXRef (Oid) 
                             ON DELETE CASCADE ) ;

ALTER TABLE SG_DBXRef_Qualifier_Assoc
       ADD  ( CONSTRAINT FKTrm_DBXTrmA
              FOREIGN KEY (Trm_Oid)
                             REFERENCES SG_Term (Oid) 
                             ON DELETE CASCADE ) ;


--
-- Seqfeature table
--

ALTER TABLE SG_Seqfeature
       ADD  ( CONSTRAINT FKTrm_FSrc
              FOREIGN KEY (Source_Trm_Oid)
                             REFERENCES SG_Term (Oid)
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Seqfeature
       ADD  ( CONSTRAINT FKEnt_Fea
              FOREIGN KEY (Ent_Oid)
                             REFERENCES SG_Bioentry (Oid) 
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Seqfeature
       ADD  ( CONSTRAINT FKTrm_FType
              FOREIGN KEY (Type_Trm_Oid)
                             REFERENCES SG_Term (Oid)  ) ;


--
-- Seqfeature-Qualifier associations
--

ALTER TABLE SG_Seqfeature_Qualifier_Assoc
       ADD  ( CONSTRAINT FKFea_FeaTrmA
              FOREIGN KEY (Fea_Oid)
                             REFERENCES SG_Seqfeature (Oid) 
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Seqfeature_Qualifier_Assoc
       ADD  ( CONSTRAINT FKTrm_FeaTrmA
              FOREIGN KEY (Trm_Oid)
                             REFERENCES SG_Term (Oid)
                             ON DELETE CASCADE ) ;

--
-- Seqfeature-DBXref associations
--

ALTER TABLE SG_Seqfeature_DBXref_Assoc
       ADD  ( CONSTRAINT FKFea_DbxFeaA
              FOREIGN KEY (Fea_Oid)
                             REFERENCES SG_Seqfeature (Oid) 
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Seqfeature_DBXRef_Assoc
       ADD  ( CONSTRAINT FKDBX_DbxFeaA
              FOREIGN KEY (DBX_Oid)
                             REFERENCES SG_DBXRef (Oid)
                             ON DELETE CASCADE ) ;

--
-- Seqfeature to Seqfeature associations
--

ALTER TABLE SG_Seqfeature_Assoc
       ADD  ( CONSTRAINT FKObjFea_FeaA
              FOREIGN KEY (Obj_Fea_Oid)
                             REFERENCES SG_Seqfeature (Oid) 
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Seqfeature_Assoc
       ADD  ( CONSTRAINT FKTrm_FeaA
              FOREIGN KEY (Trm_Oid)
                             REFERENCES SG_Term (Oid)
                             ON DELETE CASCADE ) ;


ALTER TABLE SG_Seqfeature_Assoc
       ADD  ( CONSTRAINT FKSubjFea_FeaA
              FOREIGN KEY (Subj_Fea_Oid)
                             REFERENCES SG_Seqfeature (Oid) 
                             ON DELETE CASCADE ) ;

--
-- Seqfeature to Seqfeature transitive closure table
--

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


--
-- Location table
--

ALTER TABLE SG_Location
       ADD  ( CONSTRAINT FKDBX_Loc
              FOREIGN KEY (DBX_Oid)
                             REFERENCES SG_DBXRef (Oid) ) ;


ALTER TABLE SG_Location
       ADD  ( CONSTRAINT FKTrm_Loc
              FOREIGN KEY (Trm_Oid)
                             REFERENCES SG_Term (Oid) ) ;


ALTER TABLE SG_Location
       ADD  ( CONSTRAINT FKFea_Loc
              FOREIGN KEY (Fea_Oid)
                             REFERENCES SG_Seqfeature (Oid) 
                             ON DELETE CASCADE ) ;


--
-- Location-Qualifier assocations
--

ALTER TABLE SG_Location_Qualifier_Assoc
       ADD  ( CONSTRAINT FKTrm_LocTrmA
              FOREIGN KEY (Trm_Oid)
                             REFERENCES SG_Term (Oid)  ) ;


ALTER TABLE SG_Location_Qualifier_Assoc
       ADD  ( CONSTRAINT FKLoc_LocTrmA
              FOREIGN KEY (Loc_Oid)
                             REFERENCES SG_Location (Oid) 
                             ON DELETE CASCADE ) ;



--
-- Triggers for automatic primary key generation and other sanity checks
--

CREATE OR REPLACE TRIGGER BIR_Location
  BEFORE INSERT
  on SG_Location
  -- 
  for each row
/* Template for auto-generation of primary key (H.Lapp, lapp@gnf.org) */
/* Default body for BIR_Location */
BEGIN
IF :new.Oid IS NULL THEN
    SELECT SG_SEQUENCE_Fea.nextval INTO :new.Oid FROM DUAL;
END IF;
END;
/


CREATE OR REPLACE TRIGGER BIR_SeqFeature
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


CREATE OR REPLACE TRIGGER BIR_Comment
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


CREATE OR REPLACE TRIGGER BIR_Reference
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


CREATE OR REPLACE TRIGGER BIR_BioEntry_Assoc
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


CREATE OR REPLACE TRIGGER BIR_BioEntry
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
-- IF :new.Division IS NULL THEN
--    :new.Division := 'UNK';
-- END IF;
END;
/


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


CREATE OR REPLACE TRIGGER BIR_BioDatabase
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


CREATE OR REPLACE TRIGGER BIR_DBXRef
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


