--
-- SQL script to create a BioSQL-compliant API on top of the Symgene
-- schema.
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

--
-- The prefix for all objects (tables, views, etc). This will be used
-- literally without further delimiter, so include a trailing underscore
-- or whatever you want as delimiter. You may also set it to an empty
-- string.
--
-- DO NOT USE THE SYMGENE PREFIX here (SG_), because otherwise possibly
-- created synonyms will be circular.
--
define biosql=BS_
define seqname=SG_SEQUENCE
define locseqname=SG_SEQUENCE_FEA
define entaseqname=SG_SEQUENCE_ENTA

--
-- Table Taxon
--
-- this is identical to Symgene, hence a synonym does it
CREATE SYNONYM &biosql.taxon FOR SG_Taxon;
-- also, create a synonym for a table-specific sequence
CREATE SYNONYM &biosql.taxon_pk_seq FOR &seqname;

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
CREATE SYNONYM &biosql.bioentry_assoc FOR SG_BIOENTRY_ASSOC;
-- also, create a synonym for a table-specific sequence
CREATE SYNONYM &biosql.bioentry_assoc_pk_seq FOR &entaseqname;

--
-- Table Bioentry_DBXRef_Assoc
--
-- this is identical to Symgene, hence a synonym does it
CREATE SYNONYM &biosql.bioentry_dbxref_assoc FOR SG_BIOENTRY_DBXREF_ASSOC;

--
-- Table Bioentry_Qualifier_Assoc
--
-- this is identical to Symgene, hence a synonym does it
CREATE SYNONYM &biosql.bioentry_qualifier_assoc FOR SG_BIOENTRY_QUALIFIER_ASSOC;

--
-- Table Bioentry_Ref_Assoc
--
-- this is identical to Symgene, hence a synonym does it
CREATE SYNONYM &biosql.bioentry_ref_assoc FOR SG_BIOENTRY_REF_ASSOC;

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
CREATE SYNONYM &biosql.comment FOR SG_COMMENT;
-- also, create a synonym for a table-specific sequence
CREATE SYNONYM &biosql.comment_pk_seq FOR &seqname;

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
-- Table Ontology_Term
--
-- this is identical to Symgene, hence a synonym does it
CREATE SYNONYM &biosql.ontology_term FOR SG_ONTOLOGY_TERM;
-- also, create a synonym for a table-specific sequence
CREATE SYNONYM &biosql.ontology_term_pk_seq FOR &seqname;

--
-- Table Ontology_Term_Assoc
--
-- this is identical to Symgene, hence a synonym does it
CREATE SYNONYM &biosql.ontology_term_assoc FOR SG_ONTOLOGY_TERM_ASSOC;

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
CREATE SYNONYM &biosql.seqfeature_assoc FOR SG_SEQFEATURE_ASSOC;

--
-- Table Seqfeature_Qualifier_Assoc
--
-- this is identical to Symgene, hence a synonym does it
CREATE SYNONYM &biosql.seqfeature_qualifier_assoc FOR SG_SEQFEATURE_QUALIFIER_ASSOC;

--
-- Table Seqfeature_Location
--
-- this is identical to Symgene, hence a synonym does it
CREATE SYNONYM &biosql.seqfeature_location FOR SG_SEQFEATURE_LOCATION;
-- also, create a synonym for a table-specific sequence
CREATE SYNONYM &biosql.seqfeature_location_pk_seq FOR &locseqname;

--
-- Table Location_Qualifier_Assoc
--
-- this is identical to Symgene, hence a synonym does it
CREATE SYNONYM &biosql.location_qualifier_assoc FOR SG_LOCATION_QUALIFIER_ASSOC;

--
-- We don't have these yet in Biosql
--CREATE SYNONYM &biosql.CHROMOSOME FOR SG_CHROMOSOME;
--CREATE SYNONYM &biosql.CHR_MAP_ASSOC FOR SG_CHR_MAP_ASSOC;
--CREATE SYNONYM &biosql.SIMILARITY FOR SG_SIMILARITY;
