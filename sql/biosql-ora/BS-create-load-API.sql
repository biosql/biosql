--
-- SQL script to create the views of the load API for SYMGENE/BioSQL.
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
-- Taxa
--
CREATE OR REPLACE VIEW SGLD_Taxa
AS
SELECT
	Tax.Oid			Tax_Oid,
	Tax.Name		Tax_Name,
	Tax.Common_Name		Tax_Common_Name,
	Tax.NCBI_Taxon_ID	Tax_NCBI_Taxon_ID,
	Tax.Node_Type		Tax_Node_Type,
	Tax.Tax_Oid		TaxP_Oid,
	TaxP.Name		TaxP_Name,
	TaxP.Common_Name	TaxP_Common_Name,
	TaxP.NCBI_Taxon_ID	TaxP_NCBI_Taxon_ID,
	TaxP.Node_Type		TaxP_Node_Type
FROM SG_Taxon Tax, SG_Taxon TaxP
WHERE
     Tax.Tax_Oid = TaxP.Oid (+)
;


--
-- Ontology terms
--
CREATE OR REPLACE VIEW SGLD_Ontology_Terms
AS
SELECT
	Ont.Oid			Ont_Oid,
	Ont.Name		Ont_Name,
	Ont.Identifier		Ont_Identifier,
	Ont.Definition		Ont_Definition
FROM SG_Ontology_Term Ont
;

--
-- Ontology term associations; this is leaf-oriented
--
CREATE OR REPLACE VIEW SGLD_Ontology_Term_Assocs
AS
SELECT
	OntA.Tgt_Ont_Oid	Ont_Oid,
	Ont.Name		Ont_Name,
	Ont.Identifier		Ont_Identifier,
	OntA.Src_Ont_Oid	Src_Ont_Oid,
	SOnt.Name		Src_Ont_Name,
	SOnt.Identifier		Src_Ont_Identifier,
	OntA.Type_Ont_Oid	Type_Ont_Oid,
	TOnt.Name		Type_Ont_Name,
	TOnt.Identifier		Type_Ont_Identifier
FROM SG_Ontology_Term SOnt, SG_Ontology_Term TOnt, SG_Ontology_Term Ont,
     SG_Ontology_Term_Assoc OntA
WHERE
     SOnt.Oid = OntA.Src_Ont_Oid
AND  TOnt.Oid = OntA.Type_Ont_Oid
AND  Ont.Oid  = OntA.Tgt_Ont_Oid
;

--
-- Biodatabases
--
CREATE OR REPLACE VIEW SGLD_Biodatabases
AS
SELECT
	DB.Oid			DB_Oid,
	DB.Name			DB_Name,
	DB.Acronym		DB_Acronym,
	DB.Organization		DB_Organization,
	DB.URI			DB_URI
FROM SG_Biodatabase DB
;

--
-- Biodatabase releases
--
CREATE OR REPLACE VIEW SGLD_DB_Releases
AS
SELECT
	Rel.Oid			Rel_Oid,
	Rel.Version		Rel_Version,
	Rel.Rel_Date		Rel_Rel_Date,
	DB.Oid			DB_Oid,
	DB.Name			DB_Name,
	DB.Acronym		DB_Acronym
FROM SG_DB_Release Rel, SG_Biodatabase DB
WHERE 
     Rel.DB_Oid = DB.Oid
;

--
-- Chromosomes
--
CREATE OR REPLACE VIEW SGLD_Chromosomes
AS
SELECT
	Chr.Oid			Chr_Oid,
	Chr.Name		Chr_Name,
	Chr.Length		Chr_Length,
	Tax.Oid			Tax_Oid,
	Tax.Name		Tax_Name,
	Tax.NCBI_Taxon_ID	Tax_NCBI_Taxon_ID
FROM SG_Chromosome Chr, SG_Taxon Tax
WHERE
     Chr.Tax_Oid = Tax.Oid
;

--
-- Bioentries
--
CREATE OR REPLACE VIEW SGLD_Bioentries
AS
SELECT
	Ent.Oid			Ent_Oid,
	Ent.Accession		Ent_Accession,
	Ent.Identifier		Ent_Identifier,
	Ent.Name		Ent_Name,
	Ent.Description		Ent_Description,
	Ent.Version		Ent_Version,
	Ent.Division		Ent_Division,
	Ent.Molecule		Ent_Molecule,
	Ent.DB_Oid		DB_Oid,
	Ent.Tax_Oid		Tax_Oid,
	Seq.Version		Ent_Seq_Version,
	Seq.Length		Ent_Seq_Length,
	DB.Name			DB_Name,
	DB.Acronym		DB_Acronym,
	Tax.Name		Tax_Name,
	Tax.NCBI_Taxon_ID	Tax_NCBI_Taxon_ID
FROM SG_Bioentry Ent, SG_Biodatabase DB, SG_Taxon Tax, SG_Biosequence Seq
WHERE
     Ent.DB_Oid  = DB.Oid
AND  Ent.Tax_Oid = Tax.Oid (+)
AND  Ent.Oid     = Seq.Oid (+)
;

--
-- Bioentry-DBrelease associations
--
CREATE OR REPLACE VIEW SGLD_Bioentry_Rel_Assocs
AS
SELECT
	EntRelA.Rel_Oid		Rel_Oid,
	EntRelA.Ent_Oid		Ent_Oid,
	Ent.Accession		Ent_Accession,
	Ent.Identifier		Ent_Identifier,
	Ent.Version		Ent_Version,
	DB.Oid			DB_Oid,
	DB.Name			DB_Name,
	DB.Acronym		DB_Acronym,
	Rel.Version		Rel_Version,
	Rel.Rel_Date		Rel_Rel_Date	
FROM SG_Bioentry_Rel_Assoc EntRelA, SG_DB_Release Rel, SG_Bioentry Ent,
     SG_Biodatabase DB
WHERE
     EntRelA.Rel_Oid = Rel.Oid
AND  EntRelA.Ent_Oid = Ent.Oid
AND  Ent.DB_Oid      = DB.Oid
AND  Rel.DB_Oid	     = DB.Oid
;

--
-- Bioentry-Qualifier associations
--
CREATE OR REPLACE VIEW SGLD_Bioentry_Qualifier_Assocs
AS
SELECT
	EntOntA.Ent_Oid		Ent_Oid,
	EntOntA.Ont_Oid		Ont_Oid,
	EntOntA.Value		EntOntA_Value,
	Ent.Accession		Ent_Accession,
	Ent.Identifier		Ent_Identifier,
	Ent.Version		Ent_Version,
	DB.Oid			DB_Oid,
	DB.Name			DB_Name,
	DB.Acronym		DB_Acronym,
	Ont.Name		Ont_Name,
	Ont.Identifier		Ont_Identifier
FROM SG_Bioentry_Qualifier_Assoc EntOntA, SG_Ontology_Term Ont,
     SG_Bioentry Ent, SG_Biodatabase DB
WHERE
     EntOntA.Ont_Oid = Ont.Oid
AND  EntOntA.Ent_Oid = Ent.Oid
AND  Ent.DB_Oid	     = DB.Oid
;

--
-- Bioentry-Chromosome mappings
--
CREATE OR REPLACE VIEW SGLD_Chr_Map_Assocs
AS
SELECT
	ChrEntA.Oid		ChrEntA_Oid,
	ChrEntA.Chr_Start_Pos	ChrEntA_Chr_Start_Pos,
	ChrEntA.Chr_End_Pos	ChrEntA_Chr_End_Pos,
	ChrEntA.Ent_Start_Pos	ChrEntA_Ent_Start_Pos,
	ChrEntA.Ent_End_Pos	ChrEntA_Ent_End_Pos,
	ChrEntA.Strand		ChrEntA_Strand,
	ChrEntA.Num_Mismatch	ChrEntA_Num_Mismatch,
	ChrEntA.Ent_Oid		Ent_Oid,
	ChrEntA.Chr_Oid		Chr_Oid,
	ChrEntA.Rel_Oid		Rel_Oid,
	Chr.Name		Chr_Name,
	Tax.Oid			Tax_Oid,
	Tax.Name		Tax_Name,
	Tax.NCBI_Taxon_ID	Tax_NCBI_Taxon_ID,
	Ent.Accession		Ent_Accession,
	Ent.Identifier		Ent_Identifier,
	Ent.Version		Ent_Version,
	DB.Oid			DB_Oid,
	DB.Name			DB_Name,
	DB.Acronym		DB_Acronym,
	RDB.Oid			Rel_DB_Oid,
	RDB.Name		Rel_DB_Name,
	RDB.Acronym		Rel_DB_Acronym,
	Rel.Version		Rel_Version	
FROM SG_Chr_Map_Assoc ChrEntA, SG_Bioentry Ent, SG_Biodatabase DB,
     SG_Taxon Tax, SG_Chromosome Chr, SG_DB_Release Rel, SG_Biodatabase RDB
WHERE
     ChrEntA.Ent_Oid = Ent.Oid
AND  ChrEntA.Chr_Oid = Chr.Oid
AND  ChrEntA.Rel_Oid = Rel.Oid
AND  Rel.DB_Oid	     = RDB.Oid
AND  Chr.Tax_Oid     = Tax.Oid
AND  Ent.DB_Oid	     = DB.Oid
;

--
-- Seqfeature and Locations
--
CREATE OR REPLACE VIEW SGLD_Seqfeature_Locations
AS
SELECT
	Loc.Oid			Loc_Oid,
	Loc.Start_Pos		Loc_Start_Pos,
	Loc.End_Pos		Loc_End_Pos,
	Loc.Strand		Loc_Strand,
	Loc.Rank		Loc_Rank,
	Loc.Fea_Oid		Fea_Oid,
	Loc.Ent_Oid		Loc_Ent_Oid,
	Fea.Rank		Fea_Rank,
	Fea.Ent_Oid		Ent_Oid,
	Fea.Ont_Oid		Ont_Oid,
	Ont.Name		Ont_Name,
	Ont.Identifier		Ont_Identifier,
	Ent.Accession		Ent_Accession,
	Ent.Identifier		Ent_Identifier,
	Ent.Version		Ent_Version,
	DB.Oid			DB_Oid,
	DB.Name			DB_Name,
	DB.Acronym		DB_Acronym
FROM SG_Seqfeature_Location Loc, SG_Seqfeature Fea, SG_Bioentry Ent,
     SG_Biodatabase DB, SG_Ontology_Term Ont
WHERE
	Loc.Fea_Oid = Fea.Oid
AND	Fea.Ont_Oid = Ont.Oid
AND	Fea.Ent_Oid = Ent.Oid
AND	Ent.DB_Oid  = DB.Oid
;

