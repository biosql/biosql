--
-- SQL script to create the views for SYMGENE/BioSQL
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
PROMPT
PROMPT Creating view SG_Taxa

CREATE OR REPLACE VIEW SG_Taxa
AS
SELECT
	Tax.Name		Tax_Name,
	Tax.Variant		Tax_Variant,
	Tax.Common_Name		Tax_Common_Name,
	Tax.NCBI_Taxon_ID	Tax_NCBI_Taxon_ID,
	Tax.Full_Lineage	Tax_Full_Lineage,
	Tax.Oid			Tax_Oid
FROM SG_Taxon Tax
;

--
-- Biodatabases (namespaces)
--
PROMPT
PROMPT Creating view SG_Biodatabases

CREATE OR REPLACE VIEW SG_Biodatabases
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
PROMPT
PROMPT Creating view SG_Bioentries

CREATE OR REPLACE VIEW SG_Bioentries
AS
SELECT
	Ent.Accession		Ent_Accession,
	Ent.Identifier		Ent_Identifier,
	Ent.Display_ID		Ent_Display_ID,
	Ent.Description		Ent_Description,
	Ent.Version		Ent_Version,
	Sq.Division		Ent_Division,
	Sq.Alphabet		Ent_Alphabet,
	Sq.Version		Ent_Seq_Version,
	Sq.Length		Ent_Length,
	DB.Name			DB_Name,
	DB.Acronym		DB_Acronym,
	Tax.Name		Tax_Name,
	Tax.Variant		Tax_Variant,
	Tax.Common_Name		Tax_Common_Name,
	Tax.NCBI_Taxon_ID	Tax_NCBI_Taxon_ID,
	Ent.Oid			Ent_Oid,
	Ent.DB_Oid		DB_Oid,
	Ent.Tax_Oid		Tax_Oid
FROM SG_Bioentry Ent, SG_Biodatabase DB, SG_Taxon Tax, SG_Biosequence Sq
WHERE
     Ent.DB_Oid  = DB.Oid
AND  Ent.Tax_Oid = Tax.Oid (+)
AND  Ent.Oid     = Sq.Ent_Oid (+)
;

--
-- Bioentry-Bioentry associations
--
PROMPT
PROMPT Creating view SG_Bioentry_Assocs

CREATE OR REPLACE VIEW SG_Bioentry_Assocs
AS
SELECT
	Ont.Name		Term_Name,
	Ont.Identifier		Term_Identifier,
	Cat.Name		Cat_Name,
	SEnt.Accession		Src_Ent_Accession,
	SEnt.Identifier		Src_Ent_Identifier,
	SEnt.Display_ID		Src_Ent_Display_ID,
	SEnt.Description	Src_Ent_Description,
	SEnt.Version		Src_Ent_Version,
	SDB.Name		Src_DB_Name,
	SDB.Acronym		Src_DB_Acronym,
	STax.Name		Src_Tax_Name,
	STax.Variant		Src_Tax_Variant,
	STax.Common_Name	Src_Tax_Common_Name,
	STax.NCBI_Taxon_ID	Src_Tax_NCBI_Taxon_ID,
	TEnt.Accession		Tgt_Ent_Accession,
	TEnt.Identifier		Tgt_Ent_Identifier,
	TEnt.Display_ID		Tgt_Ent_Display_ID,
	TEnt.Description	Tgt_Ent_Description,
	TEnt.Version		Tgt_Ent_Version,
	TDB.Name		Tgt_DB_Name,
	TDB.Acronym		Tgt_DB_Acronym,
	TTax.Name		Tgt_Tax_Name,
	TTax.Variant		Tgt_Tax_Variant,
	TTax.Common_Name	Tgt_Tax_Common_Name,
	TTax.NCBI_Taxon_ID	Tgt_Tax_NCBI_Taxon_ID,
	EntA.Oid		EntA_Oid,
	EntA.Src_Ent_Oid	Src_Ent_Oid,
	SEnt.DB_Oid		Src_DB_Oid,
	SEnt.Tax_Oid		Src_Tax_Oid,
	EntA.Tgt_Ent_Oid	Tgt_Ent_Oid,
	TEnt.DB_Oid		Tgt_DB_Oid,
	TEnt.Tax_Oid		Tgt_Tax_Oid,
	EntA.Ont_Oid		Ont_Oid,
	Cat.Oid			Cat_Oid
FROM SG_Bioentry_Assoc EntA,
     SG_Bioentry SEnt, SG_Biodatabase SDB, SG_Taxon STax,
     SG_Bioentry TEnt, SG_Biodatabase TDB, SG_Taxon TTax,
     SG_Ontology_Term Ont, SG_Ontology_Term Cat
WHERE
     SEnt.DB_Oid      = SDB.Oid
AND  TEnt.DB_Oid      = TDB.Oid
AND  EntA.Src_Ent_Oid = SEnt.Oid
AND  EntA.Tgt_Ent_Oid = TEnt.Oid
AND  EntA.Ont_Oid     = Ont.Oid
AND  Ont.Ont_Oid      = Cat.Oid
AND  SEnt.Tax_Oid     = STax.Oid (+)
AND  TEnt.Tax_Oid     = TTax.Oid (+)
;

--
-- Ontology terms
--
PROMPT
PROMPT Creating view SG_Ontology_Terms

CREATE OR REPLACE VIEW SG_Ontology_Terms
AS
SELECT
	Ont.Name		Ont_Name,
	Ont.Identifier		Ont_Identifier,
	Ont.Definition		Ont_Definition,
	Cat.Name		Cat_Name,
	Cat.Identifier		Cat_Identifier,
	Cat.Definition		Cat_Definition,
	Ont.Oid			Ont_Oid,
	Cat.Oid			Cat_Oid
FROM SG_Ontology_Term Ont, SG_Ontology_Term Cat
WHERE
     Ont.Ont_Oid  = Cat.Oid (+)
;

--
-- Ontology term associations; this is root-oriented
--
PROMPT
PROMPT Creating view SG_Ontology_Term_Assocs

CREATE OR REPLACE VIEW SG_Ontology_Term_Assocs
AS
SELECT
	SOnt.Name		Src_Term_Name,
	SOnt.Identifier		Src_Term_Identifier,
	SCat.Name		Src_Cat_Name,
	SCat.Identifier		Src_Cat_Identifier,
	TOnt.Name		Type_Term_Name,
	TOnt.Identifier		Type_Term_Identifier,
	TCat.Name		Type_Cat_Name,
	TCat.Identifier		Type_Cat_Identifier,
	Ont.Name		Tgt_Term_Name,
	Ont.Identifier		Tgt_Term_Identifier,
	Cat.Name		Tgt_Cat_Name,
	Cat.Identifier		Tgt_Cat_Identifier,
	SOnt.Oid		Src_Term_Oid,
	SOnt.Ont_Oid		Src_Cat_Oid,
	Ont.Oid			Tgt_Term_Oid,
	Ont.Ont_Oid		Tgt_Cat_Oid,
	TOnt.Oid		Type_Term_Oid,
	TOnt.Ont_Oid		Type_Cat_Oid
FROM SG_Ontology_Term SOnt, SG_Ontology_Term TOnt, SG_Ontology_Term Ont,
     SG_Ontology_Term SCat, SG_Ontology_Term TCat, SG_Ontology_Term Cat,
     SG_Ontology_Term_Assoc OntA
WHERE
     OntA.Src_Ont_Oid  = SOnt.Oid
AND  OntA.Type_Ont_Oid = TOnt.Oid
AND  OntA.Tgt_Ont_Oid  = Ont.Oid
AND  SOnt.Ont_Oid      = SCat.Oid
AND  Ont.Ont_Oid       = Cat.Oid
AND  TOnt.Ont_Oid      = TCat.Oid (+)
;

--
-- Annotation: References
--
PROMPT
PROMPT Creating view SG_References

CREATE OR REPLACE VIEW SG_References
AS
SELECT
	Ref.Title		Ref_Title,
	Ref.Authors		Ref_Authors,
	Ref.Location		Ref_Location,
	Ref.Document_ID		Ref_Document_ID,
	Ref.Oid			Ref_Oid
FROM SG_Reference Ref
;

--
-- Annotation: DBXRefs
--
PROMPT
PROMPT Creating view SG_DBXRefs

CREATE OR REPLACE VIEW SG_DBXRefs
AS
SELECT
	DBX.DBName		DBX_DBName,
	DBX.Accession		DBX_Accession,
	DBX.Version		DBX_Version,
	DBX.Oid			DBX_Oid
FROM SG_DBXRef DBX
;

--
-- Annotation: Comments
--
PROMPT
PROMPT Creating view SG_Bioentry_Comment_Assocs

CREATE OR REPLACE VIEW SG_Bioentry_Comment_Assocs
AS
SELECT
	Cmt.Comment_Text	Cmt_Comment_Text,
	Cmt.Rank		Cmt_Rank,
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
	Cmt.Oid			Cmt_Oid,
	Ent.Oid			Ent_Oid,
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
PROMPT Creating view SG_Bioentry_Ref_Assocs

CREATE OR REPLACE VIEW SG_Bioentry_Ref_Assocs
AS
SELECT
	Ref.Title		Ref_Title,
	Ref.Authors		Ref_Authors,
	Ref.Location		Ref_Location,
	Ref.Document_ID		Ref_Document_ID,
	EntRefA.Start_Pos       EntRefA_Start_Pos,
	EntRefA.End_Pos		EntRefA_End_Pos,
	EntRefA.Rank		EntRefA_Rank,
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
	Ent.Oid			Ent_Oid,
	Ent.DB_Oid		DB_Oid,
	Ent.Tax_Oid		Tax_Oid,
	Ref.Oid			Ref_Oid
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
PROMPT Creating view SG_Bioentry_DBXRef_Assocs

CREATE OR REPLACE VIEW SG_Bioentry_DBXRef_Assocs
AS
SELECT
	DBX.DBName		DBX_DBName,
	DBX.Accession		DBX_Accession,
	DBX.Version		DBX_Version,
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
	DBX.Oid			DBX_Oid,
	Ent.Oid			Ent_Oid,
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
-- Bioentry-Qualifier associations
--
PROMPT
PROMPT Creating view SG_Bioentry_Qual_Assocs

CREATE OR REPLACE VIEW SG_Bioentry_Qual_Assocs
AS
SELECT
	Ont.Name		Term_Name,
	Ont.Identifier		Term_Identifier,
	Cat.Name		Cat_Name,
	EntOntA.Value		Qual_Value,
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
	Ont.Oid			Term_Oid,
	Cat.Oid			Cat_Oid,
	Ent.Oid			Ent_Oid,
	Ent.DB_Oid		DB_Oid,
	Ent.Tax_Oid		Tax_Oid
FROM SG_Bioentry Ent, SG_Biodatabase DB, SG_Taxon Tax,
     SG_Ontology_Term Ont, SG_Ontology_Term Cat, 
     SG_Bioentry_Qualifier_Assoc EntOntA
WHERE
     Ont.Ont_Oid     = Cat.Oid
AND  EntOntA.Ont_Oid = Ont.Oid
AND  EntOntA.Ent_Oid = Ent.Oid
AND  Ent.DB_Oid      = DB.Oid
AND  Ent.Tax_Oid     = Tax.Oid (+)
;

--
-- Seqfeatures
--
PROMPT
PROMPT Creating view SG_Seqfeatures

CREATE OR REPLACE VIEW SG_Seqfeatures
AS
SELECT
	Fea.Rank		Fea_Rank,
	FType.Name		FType_Name,
	FTCat.Name		FType_Cat_Name,
	FSrc.Name		FSrc_Name,
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
	Fea.Oid			Fea_Oid,
	FType.Oid		FType_Oid,
	FSrc.Oid		FSrc_Oid,
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
PROMPT Creating view SG_Seqfeature_Locs

CREATE OR REPLACE VIEW SG_Seqfeature_Locations
AS
SELECT
	Loc.Start_Pos		Loc_Start_Pos,
	Loc.End_Pos		Loc_End_Pos,
	Loc.Strand		Loc_Strand,
	Loc.Rank		Loc_Rank,
	DBX.DBName		Loc_SeqID_DB,
	DBX.Accession		Loc_SeqID_Acc,
	Fea.Rank		Fea_Rank,
	FType.Name		FType_Name,
	FTCat.Name		FType_Cat_Name,
	FSrc.Name		FSrc_Name,
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
	Fea.Oid			Fea_Oid,
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
PROMPT
PROMPT Creating view SG_Seqfeature_Qual_Assocs

CREATE OR REPLACE VIEW SG_Seqfeature_Qual_Assocs
AS
SELECT
	Ont.Name		Term_Name,
	Ont.Identifier		Term_Identifier,
	Cat.Name		Cat_Name,
	FeaOntA.Value		Qual_Value,
	FeaOntA.Rank		Qual_Rank,
	Fea.Rank		Fea_Rank,
	FType.Name		FType_Name,
	FTCat.Name		FType_Cat_Name,
	FSrc.Name		FSrc_Name,
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
	Ent.Oid			Ent_Oid,
	Ent.DB_Oid		DB_Oid,
	Ent.Tax_Oid		Tax_Oid
FROM SG_Seqfeature_Qualifier_Assoc FeaOntA,
     SG_Ontology_Term Ont, SG_Ontology_Term Cat,
     SG_Seqfeature Fea, SG_Ontology_Term FType, SG_Ontology_Term FTCat,
     SG_Ontology_Term FSrc, SG_Bioentry Ent, SG_Biodatabase DB, SG_Taxon Tax
WHERE
     FeaOntA.Ont_Oid = Ont.Oid
AND  FeaOntA.Fea_Oid = Fea.Oid
AND  Ont.Ont_Oid     = Cat.Oid
AND  Fea.Ent_Oid     = Ent.Oid
AND  Fea.Ont_Oid     = FType.Oid
AND  FType.Ont_Oid   = FTCat.Oid
AND  Ent.DB_Oid      = DB.Oid
AND  Fea.FSrc_Oid    = FSrc.Oid (+)
AND  Ent.Tax_Oid     = Tax.Oid (+)
;

--
-- Genome mapping view but without using the materialized view
--
CREATE OR REPLACE VIEW SG_Chr_Map_Assocs_v
AS
SELECT
	EntLoc.Start_Pos	EntSeg_Start_Pos,
	EntLoc.End_Pos		EntSeg_End_Pos,
	NumA.Value		EntSeg_Num,
	ChrLoc.Start_Pos	ChrSeg_Start_Pos,
	ChrLoc.End_Pos		ChrSeg_End_Pos,
	ChrLoc.Strand		ChrSeg_Strand,
	FeaOntA.Value		ChrSeg_Pct_Identity,
	FType.Name		FType_Name,
	FSrc.Name		FSrc_Name,
	Ent.Accession		Ent_Accession,
	Ent.Identifier		Ent_Identifier,
	Ent.Version		Ent_Version,
	DB.Name			DB_Name,
	DB.Acronym		DB_Acronym,
	EntTax.Name		Ent_Tax_Name,
	EntTax.Variant		Ent_Tax_Variant,
	EntTax.NCBI_Taxon_ID	Ent_Tax_NCBI_Taxon_ID,
	Chr.Display_ID		Chr_Name,
	Chr.Accession		Chr_Accession,
	Asm.Name		Asm_Name,
	Asm.Acronym		Asm_Acronym,
	Tax.Name		Asm_Tax_Name,
	Tax.Variant		Asm_Tax_Variant,
	Tax.NCBI_Taxon_ID	Asm_Tax_NCBI_Taxon_ID,
	Ent.Oid			Ent_Oid,
	Ent.DB_Oid		DB_Oid,
	Ent.Tax_Oid		Ent_Tax_Oid,
	Chr.Oid			Chr_Oid,
	Chr.DB_Oid		Asm_Oid,
	Tax.Oid			Asm_Tax_Oid,
	HSP.Oid			EntSeg_Oid,
	Exon.Oid		ChrSeg_Oid
FROM SG_Bioentry Ent, SG_Bioentry Chr,
     SG_Seqfeature HSP, SG_Seqfeature Exon,
     SG_Seqfeature_Location EntLoc, SG_Seqfeature_Location ChrLoc,
     SG_Biodatabase DB, SG_Biodatabase Asm,
     SG_Seqfeature_Qualifier_Assoc FeaOntA,
     SG_Seqfeature_Qualifier_Assoc NumA,
     SG_Seqfeature_Assoc Sim,
     SG_Ontology_Term FType,
     SG_Ontology_Term FSrc,
     SG_Ontology_Term RelType,
     SG_Ontology_Term Qual,
     SG_Ontology_Term NumQual,
     SG_Taxon Tax, SG_Taxon EntTax
WHERE
     Ent.DB_Oid      = DB.Oid
AND  HSP.Ent_Oid     = Ent.Oid
AND  EntLoc.Fea_Oid  = HSP.Oid
AND  EntLoc.Rank     = 1
AND  HSP.Ont_Oid     = FType.Oid
AND  HSP.FSrc_Oid    = FSrc.Oid
AND  Chr.DB_Oid      = Asm.Oid
AND  Exon.Ent_Oid    = Chr.Oid
AND  ChrLoc.Fea_Oid  = Exon.Oid
AND  ChrLoc.Rank     = 1
AND  Sim.Src_Fea_Oid = HSP.Oid
AND  Sim.Tgt_Fea_Oid = Exon.Oid
AND  Sim.Ont_Oid     = RelType.Oid
AND  Sim.Rank	     = 0
AND  RelType.Name    = 'Genome Alignment'
AND  FeaOntA.Fea_Oid = HSP.Oid
AND  FeaOntA.Ont_Oid = Qual.Oid
AND  FeaOntA.Rank    = 1
AND  Qual.Name       = 'Pct_Identity'
AND  NumA.Fea_Oid    = HSP.Oid
AND  NumA.Ont_Oid    = NumQual.Oid
AND  NumA.Rank	     = 1
AND  NumQual.Name    = 'Exon_Num'
AND  Chr.Tax_Oid     = Tax.Oid
AND  Ent.Tax_Oid     = EntTax.Oid
;

--
-- Bioentry relationships based on DBXrefs
--
CREATE OR REPLACE VIEW SG_DBX_Bioentry_Assocs
AS
SELECT
	SEnt.Accession		Src_Ent_Accession,
	SEnt.Identifier		Src_Ent_Identifier,
	SEnt.Display_ID		Src_Ent_Display_ID,
	SEnt.Description	Src_Ent_Description,
	SEnt.Version		Src_Ent_Version,
	SDB.Name		Src_DB_Name,
	SDB.Acronym		Src_DB_Acronym,
	SOnt.Name		Src_BEType_Name,
	STax.Name		Src_Tax_Name,
	STax.Variant		Src_Tax_Variant,
	STax.Common_Name	Src_Tax_Common_Name,
	STax.NCBI_Taxon_ID	Src_Tax_NCBI_Taxon_ID,
	TEnt.Accession		Tgt_Ent_Accession,
	TEnt.Identifier		Tgt_Ent_Identifier,
	TEnt.Display_ID		Tgt_Ent_Display_ID,
	TEnt.Description	Tgt_Ent_Description,
	TEnt.Version		Tgt_Ent_Version,
	DBX.Version		Tgt_DBX_Version,
	TDB.Name		Tgt_DB_Name,
	TDB.Acronym		Tgt_DB_Acronym,
	TOnt.Name		Tgt_BEType_Name,
	TTax.Name		Tgt_Tax_Name,
	TTax.Variant		Tgt_Tax_Variant,
	TTax.Common_Name	Tgt_Tax_Common_Name,
	TTax.NCBI_Taxon_ID	Tgt_Tax_NCBI_Taxon_ID,
	SEnt.Oid		Src_Ent_Oid,
	SEnt.DB_Oid		Src_DB_Oid,
	SEnt.Tax_Oid		Src_Tax_Oid,
	TEnt.Oid		Tgt_Ent_Oid,
	TEnt.DB_Oid		Tgt_DB_Oid,
	TEnt.Tax_Oid		Tgt_Tax_Oid,
	DBX.Oid			DBX_Oid
FROM SG_Bioentry SEnt, SG_Bioentry TEnt, 
     SG_Bioentry_DBXref_Assoc DBXEntA, SG_DBXref DBX,
     SG_Bioentry_Qualifier_Assoc SEntOntA,
     SG_Bioentry_Qualifier_Assoc TEntOntA,
     SG_Ontology_Term SOnt,
     SG_Ontology_Term SCat,
     SG_Ontology_Term TOnt,
     SG_Ontology_Term TCat,
     SG_Taxon STax, SG_Taxon TTax, 
     SG_Biodatabase SDB, SG_Biodatabase TDB
WHERE
     DBXEntA.Ent_Oid  = SEnt.Oid
AND  DBXEntA.DBX_Oid  = DBX.Oid
AND  SEnt.DB_Oid      = SDB.Oid
AND  TEnt.DB_Oid      = TDB.Oid
AND  TDB.Name	      = DBX.DBName
AND  TEnt.Accession   = DBX.Accession
--AND  TEnt.Version     = DBX.Version
AND  SEntOntA.Ent_Oid = SEnt.Oid
AND  SEntOntA.Ont_Oid = SOnt.Oid
AND  SOnt.Ont_Oid     = SCat.Oid
AND  SCat.Name	      = 'Bioentry Type Ontology'
AND  TEntOntA.Ent_Oid = TEnt.Oid
AND  TEntOntA.Ont_Oid = TOnt.Oid
AND  TOnt.Ont_Oid     = SCat.Oid
AND  TCat.Name	      = 'Bioentry Type Ontology'
AND  SEnt.Tax_Oid     = STax.Oid (+)
AND  TEnt.Tax_Oid     = TTax.Oid (+)
;

--
-- Transcript relationships
--
CREATE OR REPLACE VIEW SG_DYN_TRANSCRIPTS
AS
SELECT
	SEnt.Accession		Trs_Accession,
	SEnt.Identifier		Trs_Identifier,
	SEnt.Display_ID		Trs_Display_ID,
	SEnt.Description	Trs_Description,
	SEnt.Version		Trs_Version,
	SDB.Name		DB_Name,
	SDB.Acronym		DB_Acronym,
	TEnt.Accession		Gene_Accession,
	TEnt.Identifier		Gene_Identifier,
	TEnt.Display_ID		Gene_Display_ID,
	TEnt.Description	Gene_Description,
	TEnt.Version		Gene_Version,
	TDB.Name		Gene_DB_Name,
	TDB.Acronym		Gene_DB_Acronym,
	STax.Name		Tax_Name,
	STax.Variant		Tax_Variant,
	STax.Common_Name	Tax_Common_Name,
	STax.NCBI_Taxon_ID	Tax_NCBI_Taxon_ID,
	SEnt.Oid		Trs_Oid,
	SEnt.DB_Oid		DB_Oid,
	SEnt.Tax_Oid		Tax_Oid,
	TEnt.Oid		Gene_Oid,
	TEnt.DB_Oid		Gene_DB_Oid
FROM SG_Bioentry SEnt, SG_Bioentry TEnt, 
     SG_Bioentry_DBXref_Assoc DBXEntA, SG_DBXref DBX,
     SG_Taxon STax, SG_Biodatabase SDB, SG_Biodatabase TDB
WHERE
     DBXEntA.Ent_Oid  = TEnt.Oid
AND  DBXEntA.DBX_Oid  = DBX.Oid
AND  TEnt.DB_Oid      = TDB.Oid
AND  SEnt.DB_Oid      = SDB.Oid
AND  SDB.Name	      = DBX.DBName
AND  SEnt.Accession   = DBX.Accession
AND  SEnt.Version     = DBX.Version
AND  SEnt.Tax_Oid     = STax.Oid (+)
;

