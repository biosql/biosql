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
	Tax.Variant		Tax_Variant,
	Tax.Common_Name		Tax_Common_Name,
	Tax.NCBI_Taxon_ID	Tax_NCBI_Taxon_ID,
	Tax.Full_Lineage	Tax_Full_Lineage
FROM SG_Taxon Tax
;


--
-- Biodatabases
--
CREATE OR REPLACE VIEW SGLD_Biodatabases
AS
SELECT
	DB.Oid			DB_Oid,
	DB.Name			DB_Name,
	DB.Authority		DB_Authority,
	DB.Acronym		DB_Acronym,
	DB.URI			DB_URI
FROM SG_Biodatabase DB
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
	Ent.Display_ID		Ent_Display_ID,
	Ent.Description		Ent_Description,
	Ent.Version		Ent_Version,
	Sq.Division		Ent_Division,
	Sq.Alphabet		Ent_Alphabet,
	Sq.Version		Ent_Seq_Version,
	Sq.Length		Ent_Length,
	Ent.DB_Oid		DB_Oid,
	Ent.Tax_Oid		Tax_Oid,
	DB.Name			DB_Name,
	DB.Acronym		DB_Acronym,
	Tax.Name		Tax_Name,
	Tax.Variant		Tax_Variant,
	Tax.NCBI_Taxon_ID	Tax_NCBI_Taxon_ID
FROM SG_Bioentry Ent, SG_Biodatabase DB, SG_Taxon Tax, SG_Biosequence Sq
WHERE
     Ent.DB_Oid  = DB.Oid
AND  Ent.Tax_Oid = Tax.Oid (+)
AND  Ent.Oid     = Sq.Ent_Oid (+)
;

--
-- Ontology terms
--
PROMPT
PROMPT Creating view SGLD_Ontology_Terms

CREATE OR REPLACE VIEW SGLD_Ontology_Terms
AS
SELECT
	Ont.Oid			Ont_Oid,
	Ont.Name		Ont_Name,
	Ont.Identifier		Ont_Identifier,
	Ont.Definition		Ont_Definition,
	Ont.Ont_Oid		Cat_Oid,
	Cat.Name		Cat_Name,
	Cat.Identifier		Cat_Identifier
FROM SG_Ontology_Term Ont, SG_Ontology_Term Cat
WHERE
     Ont.Ont_Oid  = Cat.Oid (+)
;

--
-- Ontology term associations; this is leaf-oriented
--
CREATE OR REPLACE VIEW SGLD_Ontology_Term_Assocs
AS
SELECT
	OntA.Tgt_Ont_Oid	Ont_Oid,
	Ont.Name		Ont_Name,
	Ont.Ont_Oid		Ont_Cat_Oid,
	Ont.Identifier		Ont_Identifier,
	OntA.Src_Ont_Oid	Src_Ont_Oid,
	SOnt.Name		Src_Ont_Name,
	SOnt.Ont_Oid		Src_Cat_Oid,
	SOnt.Identifier		Src_Ont_Identifier,
	OntA.Type_Ont_Oid	Type_Ont_Oid,
	TOnt.Name		Type_Ont_Name,
	TOnt.Ont_Oid		Type_Cat_Oid,
	TOnt.Identifier		Type_Ont_Identifier
FROM SG_Ontology_Term SOnt, SG_Ontology_Term TOnt, SG_Ontology_Term Ont,
     SG_Ontology_Term_Assoc OntA
WHERE
     SOnt.Oid = OntA.Src_Ont_Oid
AND  TOnt.Oid = OntA.Type_Ont_Oid
AND  Ont.Oid  = OntA.Tgt_Ont_Oid
;

--
-- Annotation: References
--
PROMPT
PROMPT Creating view SGLD_References

CREATE OR REPLACE VIEW SGLD_References
AS
SELECT
	Ref.Oid			Ref_Oid,
	Ref.Title		Ref_Title,
	Ref.Authors		Ref_Authors,
	Ref.Location		Ref_Location,
	Ref.Document_ID		Ref_Document_ID
FROM SG_Reference Ref
;

--
-- Annotation: DBXRefs
--
PROMPT
PROMPT Creating view SGLD_DBXRefs

CREATE OR REPLACE VIEW SGLD_DBXRefs
AS
SELECT
	DBX.Oid			DBX_Oid,
	DBX.DBName		DBX_DBName,
	DBX.Accession		DBX_Accession,
	DBX.Version		DBX_Version
FROM SG_DBXRef DBX
;

--
-- Annotation: Comments
--
PROMPT
PROMPT Creating view SGLD_Bioentry_Comment_Assocs

CREATE OR REPLACE VIEW SGLD_Bioentry_Comment_Assocs
AS
SELECT
	Cmt.Oid			Cmt_Oid,
	Cmt.Comment_Text	Cmt_Comment_Text,
	Cmt.Rank		Cmt_Rank,
	Cmt.Ent_Oid		Ent_Oid,
	Ent.Accession		Ent_Accession,
	Ent.Identifier		Ent_Identifier,
	Ent.Version		Ent_Version,
	DB.Name			DB_Name,
	DB.Acronym		DB_Acronym,
	Tax.Name		Tax_Name,
	Tax.Variant		Tax_Variant,
	Tax.Common_Name		Tax_Common_Name,
	Tax.NCBI_Taxon_ID	Tax_NCBI_Taxon_ID,
	Ent.DB_Oid		DB_Oid,
	Ent.Tax_Oid		Tax_Oid
FROM SG_Comment Cmt, SG_Bioentry Ent, SG_Biodatabase DB, SG_Taxon Tax
WHERE
     Cmt.Ent_Oid = Ent.Oid
AND  Ent.DB_Oid  = DB.Oid
AND  Ent.Tax_Oid = Tax.Oid (+)
;

--
-- Bioentry-Reference associations
--
PROMPT
PROMPT Creating view SGLD_Bioentry_Ref_Assocs

CREATE OR REPLACE VIEW SGLD_Bioentry_Ref_Assocs
AS
SELECT
	EntRefA.Ref_Oid		Ref_Oid,
	EntRefA.Ent_Oid		Ent_Oid,
	EntRefA.Start_Pos       EntRefA_Start_Pos,
	EntRefA.End_Pos		EntRefA_End_Pos,
	EntRefA.Rank		EntRefA_Rank,
	Ref.Title		Ref_Title,
	Ref.Authors		Ref_Authors,
	Ref.Location		Ref_Location,
	Ref.Document_ID		Ref_Document_ID,
	Ent.Accession		Ent_Accession,
	Ent.Identifier		Ent_Identifier,
	Ent.Display_ID		Ent_Display_ID,
	Ent.Description		Ent_Description,
	Ent.Version		Ent_Version,
	DB.Name			DB_Name,
	DB.Acronym		DB_Acronym,
	Tax.Name		Tax_Name,
	Tax.Variant		Tax_Variant,
	Tax.Common_Name		Tax_Common_Name,
	Tax.NCBI_Taxon_ID	Tax_NCBI_Taxon_ID,
	Ent.DB_Oid		DB_Oid,
	Ent.Tax_Oid		Tax_Oid
FROM SG_Bioentry Ent, SG_Biodatabase DB, SG_Taxon Tax,
     SG_Bioentry_Ref_Assoc EntRefA, SG_Reference Ref
WHERE     
     Ent.DB_Oid      = DB.Oid
AND  EntRefA.Ent_Oid = Ent.Oid
AND  EntRefA.Ref_Oid = Ref.Oid
AND  Ent.Tax_Oid = Tax.Oid (+)
;

--
-- Bioentry-DBXref associations
--
PROMPT
PROMPT Creating view SGLD_Bioentry_DBXRef_Assocs

CREATE OR REPLACE VIEW SGLD_Bioentry_DBXRef_Assocs
AS
SELECT
	EntDBXA.Ent_Oid		Ent_Oid,
	EntDBXA.DBX_Oid		DBX_Oid,
	DBX.DBName		DBX_DBName,
	DBX.Accession		DBX_Accession,
	DBX.Version		DBX_Version,
	Ent.Accession		Ent_Accession,
	Ent.Identifier		Ent_Identifier,
	Ent.Version		Ent_Version,
	DB.Name			DB_Name,
	DB.Acronym		DB_Acronym,
	Tax.Name		Tax_Name,
	Tax.Variant		Tax_Variant,
	Tax.NCBI_Taxon_ID	Tax_NCBI_Taxon_ID,
	Ent.DB_Oid		DB_Oid,
	Ent.Tax_Oid		Tax_Oid
FROM SG_Bioentry Ent, SG_Biodatabase DB, SG_Taxon Tax,
     SG_Bioentry_DBXref_Assoc EntDBXA, SG_DBXRef DBX
WHERE     
     Ent.DB_Oid      = DB.Oid
AND  EntDBXA.Ent_Oid = Ent.Oid
AND  EntDBXA.DBX_Oid = DBX.Oid
AND  Ent.Tax_Oid = Tax.Oid (+)
;

--
-- Seqfeatures
--
PROMPT
PROMPT Creating view SGLD_Seqfeatures

CREATE OR REPLACE VIEW SGLD_Seqfeatures
AS
SELECT
	Fea.Oid			Fea_Oid,
	Fea.Rank		Fea_Rank,
	Fea.Ont_Oid		FType_Oid,
	Fea.FSrc_Oid		FSrc_Oid,
	FType.Name		FType_Name,
	FTCat.Name		FType_Cat_Name,
	FSrc.Name		FSrc_Name,
	Ent.Accession		Ent_Accession,
	Ent.Identifier		Ent_Identifier,
	Ent.Version		Ent_Version,
	DB.Name			DB_Name,
	DB.Acronym		DB_Acronym,
	Tax.Name		Tax_Name,
	Tax.Variant		Tax_Variant,
	Tax.NCBI_Taxon_ID	Tax_NCBI_Taxon_ID,
	Ent.Oid			Ent_Oid,
	Ent.DB_Oid		DB_Oid,
	Ent.Tax_Oid		Tax_Oid
FROM SG_Seqfeature Fea, SG_Ontology_Term FType, SG_Ontology_Term FTCat,
     SG_Ontology_Term FSrc, SG_Bioentry Ent, SG_Biodatabase DB, SG_Taxon Tax
WHERE
     Fea.Ent_Oid     = Ent.Oid
AND  Fea.Ont_Oid     = FType.Oid
AND  FType.Ont_Oid   = FTCat.Oid
AND  Ent.DB_Oid      = DB.Oid
AND  Fea.FSrc_Oid    = FSrc.Oid (+)
AND  Ent.Tax_Oid     = Tax.Oid (+)
;

--
-- Seqfeatures with location(s)
--
PROMPT
PROMPT Creating view SGLD_Seqfeature_Locations

CREATE OR REPLACE VIEW SGLD_Seqfeature_Locations
AS
SELECT
	Loc.Oid			Loc_Oid,
	Loc.Start_Pos		Loc_Start_Pos,
	Loc.End_Pos		Loc_End_Pos,
	Loc.Strand		Loc_Strand,
	Loc.Rank		Loc_Rank,
	Loc.Fea_Oid		Fea_Oid,
	Loc.DBX_Oid		Loc_SeqID_Oid,
	DBX.DBName		Loc_SeqID_DB,
	DBX.Accession		Loc_SeqID_Acc,
	Fea.Rank		Fea_Rank,
	FType.Name		FType_Name,
	FTCat.Name		FType_Cat_Name,
	FSrc.Name		FSrc_Name,
	Ent.Accession		Ent_Accession,
	Ent.Identifier		Ent_Identifier,
	Ent.Display_ID		Ent_Display_ID,
	DB.Name			DB_Name,
	DB.Acronym		DB_Acronym,
	Tax.Name		Tax_Name,
	Tax.Variant		Tax_Variant,
	Tax.NCBI_Taxon_ID	Tax_NCBI_Taxon_ID,
	FType.Oid		FType_Oid,
	FSrc.Oid		FSrc_Oid,
	Ent.Oid			Ent_Oid,
	Ent.DB_Oid		DB_Oid,
	Ent.Tax_Oid		Tax_Oid
FROM SG_Seqfeature_Location Loc,
     SG_Seqfeature Fea, SG_DBXref DBX, SG_Bioentry Ent,
     SG_Ontology_Term FType, SG_Ontology_Term FTCat,
     SG_Ontology_Term FSrc, SG_Biodatabase DB, SG_Taxon Tax
WHERE
     Loc.Fea_Oid     = Fea.Oid
AND  Fea.Ent_Oid     = Ent.Oid
AND  Fea.Ont_Oid     = FType.Oid
AND  FType.Ont_Oid   = FTCat.Oid
AND  Ent.DB_Oid      = DB.Oid
AND  Fea.FSrc_Oid    = FSrc.Oid (+)
AND  Ent.Tax_Oid     = Tax.Oid (+)
AND  Loc.DBX_Oid     = DBX.Oid (+)
;

--
-- Seqfeature-Qualifier associations
--
-- PROMPT
-- PROMPT Creating view SGLD_Seqfeature_Qual_Assocs

-- CREATE OR REPLACE VIEW SGLD_Seqfeature_Qual_Assocs
-- AS
-- SELECT
-- 	Ont.Name		Term_Name,
-- 	Ont.Identifier		Term_Identifier,
-- 	Cat.Name		Cat_Name,
-- 	FeaOntA.Value		Qual_Value,
-- 	FeaOntA.Rank		Qual_Rank,
-- 	Fea.Rank		Fea_Rank,
-- 	FType.Name		FType_Name,
-- 	FTCat.Name		FType_Cat_Name,
-- 	FSrc.Name		FSrc_Name,
-- 	Ent.Accession		Ent_Accession,
-- 	Ent.Identifier		Ent_Identifier,
-- 	Ent.Display_ID		Ent_Display_ID,
-- 	Ent.Description		Ent_Description,
-- 	Ent.Version		Ent_Version,
-- 	DB.Name			DB_Name,
-- 	DB.Acronym		DB_Acronym,
-- 	Tax.Name		Tax_Name,
-- 	Tax.Variant		Tax_Variant,
-- 	Tax.Common_Name		Tax_Common_Name,
-- 	Tax.NCBI_Taxon_ID	Tax_NCBI_Taxon_ID,
-- 	Ent.Oid			Ent_Oid,
-- 	Ent.DB_Oid		DB_Oid,
-- 	Ent.Tax_Oid		Tax_Oid
-- FROM SG_Seqfeature_Qualifier_Assoc FeaOntA,
--      SG_Ontology_Term Ont, SG_Ontology_Term Cat,
--      SG_Seqfeature Fea, SG_Ontology_Term FType, SG_Ontology_Term FTCat,
--      SG_Ontology_Term FSrc, SG_Bioentry Ent, SG_Biodatabase DB, SG_Taxon Tax
-- WHERE
--      FeaOntA.Ont_Oid = Ont.Oid
-- AND  FeaOntA.Fea_Oid = Fea.Oid
-- AND  Ont.Ont_Oid     = Cat.Oid
-- AND  Fea.Ent_Oid     = Ent.Oid
-- AND  Fea.Ont_Oid     = FType.Oid
-- AND  FType.Ont_Oid   = FTCat.Oid
-- AND  Ent.DB_Oid      = DB.Oid
-- AND  Fea.FSrc_Oid    = FSrc.Oid (+)
-- AND  Ent.Tax_Oid     = Tax.Oid (+)
-- ;

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
	Ont.Identifier		Ont_Identifier,
	Ont.Ont_Oid		Ont_Cat_Oid,
	Cat.Name		Ont_Cat_Name,
	Cat.Identifier		Ont_Cat_Identifier
FROM SG_Bioentry_Qualifier_Assoc EntOntA, SG_Ontology_Term Ont,
     SG_Bioentry Ent, SG_Biodatabase DB, SG_Ontology_Term Cat
WHERE
     EntOntA.Ont_Oid = Ont.Oid
AND  EntOntA.Ent_Oid = Ent.Oid
AND  Ent.DB_Oid	     = DB.Oid
AND  Ont.Ont_Oid     = Cat.Oid (+)
;

--
-- Genome mappings
--
CREATE OR REPLACE VIEW SGLD_Chr_Map_Assocs
AS
SELECT
	HSP.Oid			EntSeg_Oid,
	EntLoc.Start_Pos	EntSeg_Start_Pos,
	EntLoc.End_Pos		EntSeg_End_Pos,
	HSP.Rank		EntSeg_Num,
	Exon.Oid		ChrSeg_Oid,
	ChrLoc.Start_Pos	ChrSeg_Start_Pos,
	ChrLoc.End_Pos		ChrSeg_End_Pos,
	ChrLoc.Strand		ChrSeg_Strand,
	FeaOntA.Value		ChrSeg_Pct_Identity,
	FType.Name		FType_Name,
	FSrc.Name		FSrc_Name,
	Ent.Oid			Ent_Oid,
	Ent.Accession		Ent_Accession,
	Ent.Identifier		Ent_Identifier,
	Ent.Version		Ent_Version,
	Ent.DB_Oid		DB_Oid,
	DB.Name			DB_Name,
	DB.Acronym		DB_Acronym,
	Ent.Tax_Oid		Ent_Tax_Oid,
	EntTax.Name		Ent_Tax_Name,
	EntTax.Variant		Ent_Tax_Variant,
	EntTax.NCBI_Taxon_ID	Ent_Tax_NCBI_Taxon_ID,
	Chr.Oid			Chr_Oid,
	Chr.Display_ID		Chr_Name,
	Chr.Accession		Chr_Accession,
	Chr.DB_Oid		Asm_Oid,
	Asm.Name		Asm_Name,
	Asm.Acronym		Asm_Acronym,
	Tax.Oid			Asm_Tax_Oid,
	Tax.Name		Asm_Tax_Name,
	Tax.Variant		Asm_Tax_Variant,
	Tax.NCBI_Taxon_ID	Asm_Tax_NCBI_Taxon_ID
FROM SG_Bioentry Ent, SG_Bioentry Chr,
     SG_Seqfeature HSP, SG_Seqfeature Exon,
     SG_Seqfeature_Location EntLoc, SG_Seqfeature_Location ChrLoc,
     SG_Biodatabase DB, SG_Biodatabase Asm,
     SG_Seqfeature_Assoc Sim,
     SG_Ontology_Term FType,
     SG_Ontology_Term FSrc,
     SG_Ontology_Term RelType,
     SG_Ontology_Term Qual,
     SG_Seqfeature_Qualifier_Assoc FeaOntA,
     SG_Taxon Tax, SG_Taxon EntTax
WHERE
     Ent.DB_Oid      = DB.Oid
AND  HSP.Ent_Oid     = Ent.Oid
AND  EntLoc.Fea_Oid  = HSP.Oid
AND  HSP.Ont_Oid     = FType.Oid
AND  HSP.FSrc_Oid    = FSrc.Oid
AND  Chr.DB_Oid      = Asm.Oid
AND  Exon.Ent_Oid    = Chr.Oid
AND  ChrLoc.Fea_Oid  = Exon.Oid
AND  Chr.Tax_Oid     = Tax.Oid
AND  Sim.Src_Fea_Oid = HSP.Oid
AND  Sim.Tgt_Fea_Oid = Exon.Oid
AND  Sim.Ont_Oid     = RelType.Oid
AND  RelType.Name    = 'Genome Alignment'
AND  Exon.Ont_Oid    = FType.Oid
AND  Exon.FSrc_Oid   = FSrc.Oid
AND  FeaOntA.Fea_Oid = Exon.Oid
AND  FeaOntA.Ont_Oid = Qual.Oid
AND  Qual.Name       = 'Pct_Identity'
AND  Ent.Tax_Oid     = EntTax.Oid
;

