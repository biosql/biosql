--
-- SQL script to create a BioSQL-compliant API on top of the Symgene
-- schema.
--
-- Even though the relational model of the Symgene schema is identical
-- to the BioSQL schema, the naming conventions used are not. The
-- Oracle version uses a prefix for all table names (SG_), names
-- association tables by concatenating the two entities (using '_' as
-- delimiter) and appending '_assoc'. Also, all primary keys are
-- called 'OID' (which is short and sweet), whereas foreign key names
-- are formed by appending '_OID' to a consistently re-occurring 2-4
-- letter acronym for the referenced table.
--
-- This API will emulate the original BioSQL naming convention using views 
-- except where this is not possible due to Oracle reserved words being used
-- in the original biosql naming.
--
-- There is another API (BS-create-Biosql-API.sql) that achieves partial 
-- naming identity by mapping the table names to the original BioSQL table
-- names using synonyms while leaving the column names unchanged. It may be 
-- more efficient when joining aliased tables instead of views, but it also
-- requires a language binding that is agnostic of the precise column naming.
-- Presently, only bioperl-db accomplishes this.
--
-- Choose the API you want to instantiate according to your needs. Since the
-- eventual table names are identical, the two APIs are mutually exclusive.
--
-- $GNF$
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

--
-- The prefix for all objects (tables, views, etc). This will be used
-- literally without further delimiter, so include a trailing underscore
-- or whatever you want as delimiter. You may also set it to an empty
-- string.
--
-- DO NOT USE THE SYMGENE PREFIX here (SG_), because otherwise possibly
-- created synonyms will be circular.
--
define biosql=''

--
-- Names of sequences used.
--
-- If you want to change this make sure you refer to the correct sequence
-- for each table. (Check BS-DDL.sql for what it defines.)
--
define seqname=SG_SEQUENCE
define locseqname=SG_SEQUENCE_FEA
define entaseqname=SG_SEQUENCE_EntA
define feaaseqname=SG_SEQUENCE_FeaA
define trmaseqname=SG_SEQUENCE_TrmA

--
-- delete existing synonyms
--
set timing off
set heading off
set termout off
set feedback off

spool _delsyns.sql

SELECT 'DROP SYNONYM ' || synonym_name || ';' 
FROM user_synonyms
WHERE synonym_name NOT LIKE 'SG%' 
;

spool off

set timing on
set heading on
set termout on
set feedback on

@_delsyns

--
-- Create the API from scratch.
--

--
-- Create synonyms for the per-table sequence as defined in the PostgreSQL
-- version.
-- Note that not all tables have a generated primary key. We don't create
-- a synonym where there is no primary key.
--

CREATE SYNONYM &biosql.taxon_pk_seq FOR &seqname;
CREATE SYNONYM &biosql.biodatabase_pk_seq FOR &seqname;
CREATE SYNONYM &biosql.bioentry_pk_seq FOR &seqname;
CREATE SYNONYM &biosql.bioentry_relationship_pk_seq FOR &entaseqname;
CREATE SYNONYM &biosql.biosequence_pk_seq FOR &seqname;
CREATE SYNONYM &biosql.anncomment_pk_seq FOR &seqname;
CREATE SYNONYM &biosql.reference_pk_seq FOR &seqname;
CREATE SYNONYM &biosql.dbxref_pk_seq FOR &seqname;
CREATE SYNONYM &biosql.ontology_pk_seq FOR &seqname;
CREATE SYNONYM &biosql.term_pk_seq FOR &seqname;
CREATE SYNONYM &biosql.term_relationship_pk_seq FOR &trmaseqname;
CREATE SYNONYM &biosql.term_path_pk_seq FOR &trmaseqname;
CREATE SYNONYM &biosql.seqfeature_pk_seq FOR &seqname;
CREATE SYNONYM &biosql.seqfeature_relationship_pk_seq FOR &feaaseqname;
CREATE SYNONYM &biosql.location_pk_seq FOR &locseqname;

--
-- Now create the views, one view per table.
--

--
-- Biodatabase (namespaces)
--
DROP VIEW Biodatabase;

CREATE OR REPLACE VIEW Biodatabase
AS
SELECT
       Oid                  Biodatabase_Id
       , Name               Name
       , Authority          Authority
       , Description        Description
       , Acronym            Acronym
       , URI                URI
FROM SG_Biodatabase
;

--
-- tag/value annotation for namespaces
--
DROP VIEW Biodatabase_Qualifier_Value;

CREATE VIEW Biodatabase_Qualifier_Value
AS
SELECT
	DB_Oid                  Biodatabase_Id
	, Trm_Oid               Term_Id
	, Rank			Rank
	, Value			Value
FROM SG_Biodatabase_Qualifier_Assoc
;


--
-- Taxon model, basically taken from the NCBI taxon and name table dumps
--
DROP VIEW Taxon;

CREATE OR REPLACE VIEW Taxon
AS
SELECT
	Oid                     Taxon_Id
	, NCBI_Taxon_ID         NCBI_Taxon_Id
        , Node_Rank             Node_Rank
        , Genetic_Code          Genetic_Code
        , Mito_Genetic_Code     Mito_Genetic_Code
        , Left_Value            Left_Value
        , Right_Value           Right_Value
        , Tax_Oid               Parent_Taxon_Id
FROM SG_Taxon
;

DROP VIEW Taxon_Name ;

CREATE OR REPLACE VIEW Taxon_Name
AS
SELECT
     Tax_Oid                Taxon_Id
     , Name                 Name
     , Name_Class           Name_Class
FROM SG_Taxon_Name
;

--
-- Ontology, the namespaces for terms and term relationships
--
DROP VIEW Ontology ;

CREATE OR REPLACE VIEW Ontology
AS
SELECT
     Oid                    Ontology_Id
     , Name                 Name
     , Definition           Definition
FROM SG_Ontology
;

--
-- Terms
--
DROP VIEW Term;

CREATE OR REPLACE VIEW Term
AS
SELECT
     Oid                    Term_Id
     , Name                 Name
     , Identifier           Identifier
     , Definition           Definition
     , Is_Obsolete          Is_Obsolete
     , Ont_Oid              Ontology_Id
FROM SG_Term
;

--
-- DBXrefs for terms
--
DROP VIEW Term_DBXref ;

CREATE OR REPLACE VIEW Term_DBXRef
AS
SELECT
     Trm_Oid                Term_Id
     , DBX_Oid              DBXref_Id
     , Rank                 Rank
FROM SG_Term_DBXRef_Assoc
;

--
-- Term synonyms
--
DROP VIEW Term_Synonym ;

CREATE OR REPLACE VIEW Term_Synonym
AS
SELECT
      Name                  Name
      , Trm_Oid             Term_Id
FROM SG_Term_Synonym
;

--
-- Term relationships, also called triples
--
DROP VIEW Term_Relationship;

CREATE OR REPLACE VIEW Term_Relationship       
AS
SELECT
       Oid                  Term_Relationship_Id
       , Subj_Trm_Oid       Subject_Term_Id
       , Pred_Trm_Oid       Predicate_Term_Id
       , Obj_Trm_Oid        Object_Term_Id
       , Ont_Oid            Ontology_Id
FROM SG_Term_Assoc
;


--
-- Term relationships as first-class terms (Biojava only at this point) 
-- http://www.open-bio.org/pipermail/biosql-l/2003-October/000455.html
-- 
DROP VIEW Term_Relationship_Term;

CREATE OR REPLACE VIEW Term_Relationship_Term
AS
SELECT
       Oid                  Term_Relationship_Id
       , Trm_Oid            Term_Id
FROM SG_Term_Assoc
;

-- Because this is (unnecessarily) separated out into its own table in
-- the PostgreSQL and MySQL versions, there will be INSERTs against
-- this view for existing Term and Term_Assoc entries. Similarly, a
-- DELETE issued against this virtual table conceptually means to
-- disassociate the term from the relationship, which is equivalent to
-- setting the foreign key to Term to NULL. 
-- We need to catch those cases and turn them into updates.
CREATE OR REPLACE TRIGGER BIR_Term_Relationship_Term
        INSTEAD OF INSERT
        ON Term_Relationship_Term
        REFERENCING NEW AS new OLD AS old
        FOR EACH ROW
BEGIN
        UPDATE SG_Term_Assoc SET
                Trm_Oid = :new.Term_Id
        WHERE Oid = :new.Term_Relationship_Id;
END;
/
CREATE OR REPLACE TRIGGER BUR_Term_Relationship_Term
        INSTEAD OF UPDATE
        ON Term_Relationship_Term
        REFERENCING NEW AS new OLD AS old
        FOR EACH ROW
BEGIN
        -- if this is an attempt to only change the term relationship
        -- of the association, we need to disassociate the old one
        -- first, because we don't want to be changing primary keys
        -- on term relationships
        IF :new.Term_Relationship_Id != :old.Term_Relationship_Id THEN
                UPDATE SG_Term_Assoc SET
                        Trm_Oid = NULL
                WHERE Oid = :old.Term_Relationship_Id;
        END IF;
        -- now change the term to which the relationship is to be equivalent
        UPDATE SG_Term_Assoc SET
                Trm_Oid = :new.Term_Id
        WHERE Oid = :new.Term_Relationship_Id;
END;
/
CREATE OR REPLACE TRIGGER BDR_Term_Relationship_Term
        INSTEAD OF DELETE
        ON Term_Relationship_Term
        REFERENCING NEW AS new OLD AS old
        FOR EACH ROW
BEGIN
        UPDATE SG_Term_Assoc SET
                Trm_Oid = NULL
        WHERE Oid = :old.Term_Relationship_Id;
        -- there shouldn't be a row anymore matching this, but to be on the
        -- safe side we'll do it nonetheless
        UPDATE SG_Term_Assoc SET
                Trm_Oid = NULL
        WHERE Trm_Oid = :old.Term_Id;
END;
/

--
-- Transitive closure table for term relationships
--
DROP VIEW Term_Path ;

CREATE OR REPLACE VIEW Term_Path
AS
SELECT
       Oid                  Term_Path_Id
       , Subj_Trm_Oid       Subject_Term_Id
       , Pred_Trm_Oid       Predicate_Term_Id
       , Obj_Trm_Oid        Object_Term_Id
       , Distance           Distance
       , Ont_Oid            Ontology_Id
FROM SG_Term_Path
;

--
-- Bioentry, one of the central tables
--
DROP VIEW Bioentry;

CREATE OR REPLACE VIEW Bioentry
AS
SELECT
       Oid                  Bioentry_Id
       , Accession          Accession
       , Identifier         Identifier
       , Name               Name
       , Description        Description
       , Version            Version
       , Division           Division
       , DB_Oid             Biodatabase_Id
       , Tax_Oid            Taxon_Id
FROM SG_Bioentry
;

--
-- relationships between bioentries
--
DROP VIEW Bioentry_Relationship;

CREATE OR REPLACE VIEW Bioentry_Relationship
AS
SELECT
       Oid                  Bioentry_Relationship_Id
       , Subj_Ent_Oid       Subject_Bioentry_Id
       , Trm_Oid            Term_Id
       , Obj_Ent_Oid        Object_Bioentry_Id
       , Rank               Rank
FROM SG_Bioentry_Assoc
;

--
-- full or partial transitive closure for bioentry relationships
--
DROP VIEW Bioentry_Path ;

CREATE OR REPLACE VIEW Bioentry_Path
AS
SELECT
       Subj_Ent_Oid         Subject_Bioentry_Id
       , Trm_Oid            Term_Id
       , Obj_Ent_Oid        Object_Bioentry_Id
       , Distance           Distance
FROM SG_Bioentry_Path
;

--
-- tag/value annotations for bioentries; also value-less term
-- associations
--
DROP VIEW Bioentry_Qualifier_Value;

CREATE OR REPLACE VIEW Bioentry_Qualifier_Value
AS
SELECT
       Ent_Oid              Bioentry_Id
       , Trm_Oid            Term_Id
       , Rank               Rank
       , Value              Value
FROM SG_Bioentry_Qualifier_Assoc
;

--
-- Sequence and sequence-specific attributes for bioentries when
-- applicable
--
DROP VIEW Biosequence;

CREATE OR REPLACE VIEW Biosequence
AS
SELECT
       Ent_Oid              Bioentry_Id
       , Version            Version
       , Length             Length
       , Alphabet           Alphabet
       , Seq                Seq
FROM SG_Biosequence
;

--
-- Database cross-references
--
DROP VIEW DBXRef;

CREATE OR REPLACE VIEW DBXRef
AS
SELECT
       Oid                  DBXref_Id
       , DBName             DBName
       , Accession          Accession
       , Version            Version
FROM SG_DBXRef
;

--
-- Bioentry associations with db_xrefs
--
DROP VIEW Bioentry_DBXRef;

CREATE OR REPLACE VIEW Bioentry_DBXRef
AS
SELECT
       DBX_Oid              DBXref_Id
       , Ent_Oid            Bioentry_Id
       , Rank               Rank
FROM SG_Bioentry_DBXRef_Assoc
;

--
-- DBXref to Term associations (qualifier/value pairs)
--
DROP VIEW DBXRef_Qualifier_Value ;

CREATE OR REPLACE VIEW DBXRef_Qualifier_Value
AS
SELECT
        DBX_Oid             DBXref_Id
        , Trm_Oid           Term_Id
        , Rank              Rank
        , Value             Value
FROM SG_DBXRef_Qualifier_Assoc
;

--
-- Comment-type annotations
--
DROP VIEW AnnComment;

CREATE OR REPLACE VIEW AnnComment
AS
SELECT
       Oid                  AnnComment_Id
       , Rank               Rank
       , Comment_Text       Comment_Text
       , Ent_Oid            Bioentry_Id
FROM SG_Comment
;

--
-- Literature references
--
DROP VIEW Reference;

CREATE OR REPLACE VIEW Reference
AS
SELECT
       Oid                  Reference_Id
       , Title              Title
       , Authors            Authors
       , Location           Location
       , CRC                CRC
       , DBX_Oid            DBXref_Id
FROM SG_Reference
;

--
-- Bioentry associations with literature references
--
DROP VIEW Bioentry_Reference;

CREATE OR REPLACE VIEW Bioentry_Reference
AS
SELECT
       Ent_Oid              Bioentry_Id
       , Ref_Oid            Reference_Id
       , Rank               Rank
       , Start_Pos          Start_Pos
       , End_Pos            End_Pos
FROM SG_Bioentry_Ref_Assoc
;

--
-- Bioentry or Sequence features
--
DROP VIEW Seqfeature;

CREATE OR REPLACE VIEW Seqfeature
AS
SELECT
       Oid                  Seqfeature_Id
       , Rank               Rank
       , Display_Name       Display_Name
       , Ent_Oid            Bioentry_Id
       , Type_Trm_Oid       Type_Term_Id
       , Source_Trm_Oid     Source_Term_Id
FROM SG_Seqfeature
;

--
-- Relationships between seqfeatures
--
DROP VIEW Seqfeature_Relationship;

CREATE OR REPLACE VIEW Seqfeature_Relationship
AS
SELECT
        Oid                 Seqfeature_Relationship_Id
        , Subj_Fea_Oid      Subject_Seqfeature_Id
        , Obj_Fea_Oid       Object_Seqfeature_Id
        , Trm_Oid           Term_Id
        , Rank              Rank
FROM SG_Seqfeature_Assoc
;

--
-- Full or partial transitive closure table for seqfeature relationships
--
DROP VIEW Seqfeature_Path ;

CREATE OR REPLACE VIEW Seqfeature_Path
AS
SELECT
       Subj_Fea_Oid         Subj_Seqfeature_Id
       , Trm_Oid            Term_Id
       , Obj_Fea_Oid        Obj_Seqfeature_Id
       , Distance           Distance
FROM SG_Seqfeature_Path
;

--
-- tag/value pairs for seqfeatures; or value-less term associations
--
DROP VIEW Seqfeature_Qualifier_Value;

CREATE OR REPLACE VIEW Seqfeature_Qualifier_Value
AS
SELECT
       Fea_Oid              Seqfeature_Id
       , Trm_Oid            Term_Id
       , Rank               Rank
       , Value              Value
FROM SG_Seqfeature_Qualifier_Assoc
;

--
-- DBXref annotation for seqfeatures
--
DROP VIEW Seqfeature_DBXref ;

CREATE OR REPLACE VIEW Seqfeature_DBXref
AS
SELECT
        Fea_Oid             Seqfeature_Id
        , DBX_Oid           DBXref_Id
        , Rank              Rank
FROM SG_Seqfeature_DBXref_Assoc
;

--
-- Locations of seqfeatures
--
DROP VIEW Location;

CREATE OR REPLACE VIEW Location
AS
SELECT
       Oid                  Location_Id
       , Start_Pos          Start_Pos
       , End_Pos            End_Pos
       , Strand             Strand
       , Rank               Rank
       , Fea_Oid            Seqfeature_Id
       , DBX_Oid            DBXref_Id
       , Trm_Oid            Term_Id
FROM SG_Location
;

--
-- Extension of basic locations by tag/value pair annotation (e.g.,
-- for fuzzy locations)
--
DROP VIEW Location_Qualifier_Value;

CREATE OR REPLACE VIEW Location_Qualifier_Value
AS
SELECT
       Loc_Oid              Location_Id
       , Trm_Oid            Term_Id
       , Value              Value
FROM SG_Location_Qualifier_Assoc
;
