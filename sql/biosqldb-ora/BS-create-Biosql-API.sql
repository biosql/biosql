--
-- SQL script to create a BioSQL-compliant API on top of the Symgene
-- schema.
--
-- Even though the relational model of the Symgene schema is identical to the
-- BioSQL schema, the naming conventions used are not. The Oracle version uses
-- a prefix for all table names (SG_), names association tables by 
-- concatenating the two entities (using '_' as delimiter) and appending 
-- '_assoc'. Also, all primary keys are called 'OID' (which short and sweet),
-- whereas foreign key names are formed by appending '_OID' to a consistently
-- re-occurring 2-4 letter acronym for the referenced table.
-- 
-- This API achieves partial naming identity by mapping the table names to the
-- original BioSQL table names using synonyms while leaving the column names
-- unchanged. It may be more efficient than the view-based API (see below) when
-- joining aliased tables instead of views, but it also requires a language
-- binding that is agnostic of the precise column naming. Presently, only
-- bioperl-db accomplishes this.
--
-- There is another API (BS-create-Biosql-API.sql) that emulates the original
-- BioSQL naming convention using views except where this is not possible due
-- to Oracle reserved words being used in the original schema.
--
-- Choose the API you want to instantiate according to your needs. Since the
-- eventual table names are identical, you can only have either of the two,
-- not both at the same time.
--
-- $GNF: projects/gi/symgene/src/DB/BS-create-Biosql-API.sql,v 1.7 2003/06/01 21:07:24 hlapp Exp $
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

-- load definitions
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
-- Note that when the variables are substituted, '.' terminates the variable
-- name and does not translate as a literal dot. I.e., &biosql.bla becomes
-- <prefix>bla, not <prefix>.bla.
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
-- Table Taxon
--
-- this is identical to Symgene, hence a synonym does it
CREATE SYNONYM &biosql.taxon FOR SG_Taxon;
-- also, create a synonym for a table-specific sequence
CREATE SYNONYM &biosql.taxon_pk_seq FOR &seqname;

--
-- Table Taxon_Name
--
-- this is identical to Symgene, hence a synonym does it
CREATE SYNONYM &biosql.taxon_name FOR SG_Taxon_Name;

--
-- Table Biodatabase
--
-- this is identical to Symgene, hence a synonym does it
CREATE SYNONYM &biosql.biodatabase FOR SG_BIODATABASE;
-- also, create a synonym for a table-specific sequence
CREATE SYNONYM &biosql.biodatabase_pk_seq FOR &seqname;

--
-- Table Bioentry
--
-- this is identical to Symgene, hence a synonym does it
CREATE SYNONYM &biosql.bioentry FOR SG_BIOENTRY;
-- also, create a synonym for a table-specific sequence
CREATE SYNONYM &biosql.bioentry_pk_seq FOR &seqname;

--
-- Table Bioentry_Assoc
--
-- this is identical to Symgene, hence a synonym does it
CREATE SYNONYM &biosql.bioentry_relationship FOR SG_BIOENTRY_ASSOC;
-- also, create a synonym for a table-specific sequence
CREATE SYNONYM &biosql.bioentry_relationship_pk_seq FOR &entaseqname;

--
-- Table Bioentry_DBXRef_Assoc
--
-- this is identical to Symgene, hence a synonym does it
CREATE SYNONYM &biosql.bioentry_dbxref FOR SG_BIOENTRY_DBXREF_ASSOC;

--
-- Table Bioentry_Qualifier_Assoc
--
-- this is identical to Symgene, hence a synonym does it
CREATE SYNONYM &biosql.bioentry_qualifier_value FOR SG_BIOENTRY_QUALIFIER_ASSOC;

--
-- Table Bioentry_Ref_Assoc
--
-- this is identical to Symgene, hence a synonym does it
CREATE SYNONYM &biosql.bioentry_reference FOR SG_BIOENTRY_REF_ASSOC;

--
-- Table Biosequence
--
-- this is identical to Symgene, hence a synonym does it
CREATE SYNONYM &biosql.biosequence FOR SG_BIOSEQUENCE;
-- also, create a synonym for a table-specific sequence
CREATE SYNONYM &biosql.biosequence_pk_seq FOR &seqname;

--
-- Table Comment
--
-- this is identical to Symgene, hence a synonym does it
CREATE SYNONYM &biosql.anncomment FOR SG_COMMENT;
-- also, create a synonym for a table-specific sequence
CREATE SYNONYM &biosql.anncomment_pk_seq FOR &seqname;

--
-- Table Reference
--
-- this is identical to Symgene, hence a synonym does it
CREATE SYNONYM &biosql.reference FOR SG_REFERENCE;
-- also, create a synonym for a table-specific sequence
CREATE SYNONYM &biosql.reference_pk_seq FOR &seqname;

--
-- Table DBXRef
--
-- this is identical to Symgene, hence a synonym does it
CREATE SYNONYM &biosql.dbxref FOR SG_DBXREF;
-- also, create a synonym for a table-specific sequence
CREATE SYNONYM &biosql.dbxref_pk_seq FOR &seqname;

--
-- Table Ontology
--
-- this is identical to Symgene, hence a synonym does it
CREATE SYNONYM &biosql.ontology FOR SG_ONTOLOGY;
-- also, create a synonym for a table-specific sequence
CREATE SYNONYM &biosql.ontology_pk_seq FOR &seqname;

--
-- Table Term
--
-- this is identical to Symgene, hence a synonym does it
CREATE SYNONYM &biosql.term FOR SG_TERM;
-- also, create a synonym for a table-specific sequence
CREATE SYNONYM &biosql.term_pk_seq FOR &seqname;

--
-- Table Term_Synonym
--
-- this is identical to Symgene, hence a synonym does it
CREATE SYNONYM &biosql.term_synonym FOR SG_TERM_SYNONYM;

--
-- Table Term_DBXref_Assoc
--
-- this is identical to Symgene, hence a synonym does it
CREATE SYNONYM &biosql.term_dbxref FOR SG_TERM_DBXREF_ASSOC;

--
-- Table Term_Assoc
--
-- this is identical to Symgene, hence a synonym does it
CREATE SYNONYM &biosql.term_relationship FOR SG_TERM_ASSOC;
-- also, create a synonym for a table-specific sequence
CREATE SYNONYM &biosql.term_relationship_pk_seq FOR &trmaseqname;

--
-- Table Term_Path
--
-- this is identical to Symgene, hence a synonym does it
CREATE SYNONYM &biosql.term_path FOR SG_TERM_PATH;
-- also, create a synonym for a table-specific sequence
CREATE SYNONYM &biosql.term_path_pk_seq FOR &trmaseqname;

--
-- Table Seqfeature
--
-- this is identical to Symgene, hence a synonym does it
CREATE SYNONYM &biosql.seqfeature FOR SG_SEQFEATURE;
-- also, create a synonym for a table-specific sequence
CREATE SYNONYM &biosql.seqfeature_pk_seq FOR &seqname;

--
-- Table Seqfeature_Assoc
--
-- this is identical to Symgene, hence a synonym does it
CREATE SYNONYM &biosql.seqfeature_relationship FOR SG_SEQFEATURE_ASSOC;
-- also, create a synonym for a table-specific sequence
CREATE SYNONYM &biosql.seqfeature_relationship_pk_seq FOR &feaaseqname;

--
-- Table Seqfeature_Qualifier_Assoc
--
-- this is identical to Symgene, hence a synonym does it
CREATE SYNONYM &biosql.seqfeature_qualifier_value FOR SG_SEQFEATURE_QUALIFIER_ASSOC;

--
-- Table Seqfeature_DBXref_Assoc
--
-- this is identical to Symgene, hence a synonym does it
CREATE SYNONYM &biosql.seqfeature_dbxref FOR SG_SEQFEATURE_DBXref_Assoc;

--
-- Table Location
--
-- this is identical to Symgene, hence a synonym does it
CREATE SYNONYM &biosql.location FOR SG_LOCATION;
-- also, create a synonym for a table-specific sequence
CREATE SYNONYM &biosql.location_pk_seq FOR &locseqname;

--
-- Table Location_Qualifier_Assoc
--
-- this is identical to Symgene, hence a synonym does it
CREATE SYNONYM &biosql.location_qualifier_value FOR SG_LOCATION_QUALIFIER_ASSOC;

--
-- We don't have these yet in Biosql
--CREATE SYNONYM &biosql.CHR_MAP_ASSOC FOR SG_CHR_MAP_ASSOC;
--CREATE SYNONYM &biosql.SIMILARITY FOR SG_SIMILARITY;

-- We create a separate set of API views here that exactly reflect the column
-- names as in the MySQL and PostgreSQL versions of Biosql. This is to simplify
-- things for mass-loading tools that go directly through SQL, like
-- load_ncbi_taxonomy.pl.
CREATE OR REPLACE VIEW BS_Taxon
AS
SELECT
	Tax.Oid			Taxon_ID
	, Tax.NCBI_Taxon_ID	NCBI_Taxon_ID
	, Tax.Node_Rank		Node_Rank
	, Tax.Genetic_Code	Genetic_Code
	, Tax.Mito_Genetic_Code	Mito_Genetic_Code
	, Tax.Left_Value	Left_Value
	, Tax.Right_Value	Right_Value
	, Tax.Tax_Oid		Parent_Taxon_ID
FROM SG_Taxon Tax
;

CREATE OR REPLACE VIEW BS_Taxon_Name
AS
SELECT
	Tnm.Tax_Oid		Taxon_ID
	, Tnm.Name		Name
	, Tnm.Name_Class	Name_Class
FROM SG_Taxon_Name Tnm
;
