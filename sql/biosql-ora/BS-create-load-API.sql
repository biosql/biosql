--
-- SQL script to create the views of the load API for SYMGENE/BioSQL.
--
--
-- $GNF: projects/gi/symgene/src/DB/BS-create-load-API.sql,v 1.13 2003/05/23 17:42:27 hlapp Exp $
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
-- With the taxonomy storage changes in the Singapore version, you have to
-- load taxa through an adaptor that is capable of doing this correctly, or
-- through the load-taxonomy.pl script.

--
-- Biodatabases
--
PROMPT
PROMPT Creating view SGLD_Biodatabases

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
PROMPT
PROMPT Creating view SGLD_Bioentries

CREATE OR REPLACE VIEW SGLD_Bioentries
AS
SELECT
	Ent.Oid			Ent_Oid
	, Ent.Accession		Ent_Accession
	, Ent.Identifier	Ent_Identifier
	, Ent.Name		Ent_Name
	, Ent.Description	Ent_Description
	, Ent.Version		Ent_Version
	, Ent.Division		Ent_Division
	, Sq.Alphabet		Ent_Alphabet
	, Sq.Version		Ent_Seq_Version
	, Sq.Length		Ent_Length
	, Ent.DB_Oid		DB_Oid
	, Ent.Tax_Oid		Tax_Oid
	, DB.Name		DB_Name
	, DB.Acronym		DB_Acronym
	, TNam.Name		Tax_Name
	, Tax.NCBI_Taxon_ID	Tax_NCBI_Taxon_ID
-- legacy mappings
   	, Ent.Name		Ent_Display_ID
FROM SG_Bioentry Ent, SG_Biodatabase DB, SG_Biosequence Sq,
     SG_Taxon Tax, SG_Taxon_Name TNam
WHERE
     Ent.DB_Oid  = DB.Oid
AND  Ent.Tax_Oid = Tax.Oid (+)
AND  TNam.Tax_Oid (+) = Tax.Oid
AND  Ent.Oid     = Sq.Ent_Oid (+)
;

--
-- Ontologies
--
PROMPT
PROMPT Creating view SGLD_Ontologies

CREATE OR REPLACE VIEW SGLD_Ontologies
AS
SELECT
	Ont.Oid			Ont_Oid,
	Ont.Name		Ont_Name,
	Ont.Definition		Ont_Definition
FROM SG_Ontology Ont
;

--
-- Ontology terms
--
PROMPT
PROMPT Creating view SGLD_Terms

CREATE OR REPLACE VIEW SGLD_Terms
AS
SELECT
	Trm.Oid			Trm_Oid,
	Trm.Name		Trm_Name,
	Trm.Identifier		Trm_Identifier,
	Trm.Definition		Trm_Definition,
	Trm.Is_Obsolete		Trm_Is_Obsolete,
	Trm.Ont_Oid		Ont_Oid,
	Ont.Name		Ont_Name,
	Ont.Definition		Ont_Definition,
-- legacy mappings
	Trm.Ont_Oid		Cat_Oid,
	Ont.Name		Cat_Name,
	NULL			Cat_Identifier
FROM SG_Term Trm, SG_Ontology Ont
WHERE
     Trm.Ont_Oid  = Ont.Oid
;

--
-- Ontology term associations; this is leaf-oriented
--
CREATE OR REPLACE VIEW SGLD_Term_Assocs
AS
SELECT
	TrmA.Ont_Oid		Ont_Oid
	, AOnt.Name		Ont_Name
	, TrmA.Subj_Trm_Oid	Subj_Trm_Oid
	, STrm.Name		Subj_Trm_Name
	, STrm.Identifier	Subj_Trm_Identifier
	, STrm.Ont_Oid		Subj_Ont_Oid
	, SOnt.Name		Subj_Ont_Name
	, TrmA.Pred_Trm_Oid	Pred_Trm_Oid
	, PTrm.Name		Pred_Trm_Name
	, PTrm.Identifier	Pred_Trm_Identifier
	, PTrm.Ont_Oid		Pred_Ont_Oid
	, POnt.Name		Pred_Ont_Name
	, TrmA.Obj_Trm_Oid	Obj_Trm_Oid
	, TTrm.Name		Obj_Trm_Name
	, TTrm.Identifier	Obj_Trm_Identifier
	, TTrm.Ont_Oid		Obj_Ont_Oid
	, TOnt.Name		Obj_Ont_Name
-- legacy mappings
	, TrmA.Obj_Trm_Oid	Trm_Oid
	, TTrm.Name		Trm_Name
	, TTrm.Ont_Oid		Trm_Cat_Oid
	, TTrm.Identifier	Trm_Identifier
	, TrmA.Subj_Trm_Oid	Src_Trm_Oid
	, STrm.Name		Src_Trm_Name
	, STrm.Ont_Oid		Src_Cat_Oid
	, STrm.Identifier	Src_Trm_Identifier
	, TrmA.Pred_Trm_Oid	Type_Trm_Oid
	, PTrm.Name		Type_Trm_Name
	, PTrm.Ont_Oid		Type_Cat_Oid
	, PTrm.Identifier	Type_Trm_Identifier
FROM SG_Term_Assoc TrmA,
     SG_Term STrm, SG_Term PTrm, SG_Term TTrm,
     SG_Ontology SOnt, SG_Ontology TOnt, SG_Ontology POnt, SG_Ontology AOnt
WHERE
     STrm.Oid  = TrmA.Subj_Trm_Oid
AND  TTrm.Oid  = TrmA.Obj_Trm_Oid
AND  PTrm.Oid  = TrmA.Pred_Trm_Oid
AND  AOnt.Oid  = TrmA.Ont_Oid
AND  SOnt.Oid  = STrm.Ont_Oid
AND  TOnt.Oid  = TTrm.Ont_Oid
AND  POnt.Oid  = PTrm.Ont_Oid
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
	Ref.DBX_Oid		DBX_Oid,
	DBX.DBName		DBX_DBName,
	DBX.Accession		DBX_Accession,
-- legacy mappings
	DBX.Accession		Ref_Document_ID
FROM SG_Reference Ref, SG_DBXRef DBX
WHERE
     Ref.DBX_Oid = DBX.Oid (+)
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
	TNam.Name		Tax_Name,
	Tax.NCBI_Taxon_ID	Tax_NCBI_Taxon_ID,
	Ent.DB_Oid		DB_Oid,
	Ent.Tax_Oid		Tax_Oid
FROM SG_Comment Cmt, SG_Bioentry Ent, SG_Biodatabase DB,
     SG_Taxon Tax, SG_Taxon_Name TNam
WHERE
     Cmt.Ent_Oid = Ent.Oid
AND  Ent.DB_Oid  = DB.Oid
AND  Ent.Tax_Oid = Tax.Oid (+)
AND  TNam.Tax_Oid (+) = Tax.Oid
;

--
-- Bioentry-Reference associations
--
PROMPT
PROMPT Creating view SGLD_Bioentry_Ref_Assocs

CREATE OR REPLACE VIEW SGLD_Bioentry_Ref_Assocs
AS
SELECT
	EntRefA.Ref_Oid		Ref_Oid
	, EntRefA.Ent_Oid	Ent_Oid
	, EntRefA.Start_Pos	EntRefA_Start_Pos
	, EntRefA.End_Pos	EntRefA_End_Pos
	, EntRefA.Rank		EntRefA_Rank
	, Ref.Title		Ref_Title
	, Ref.Authors		Ref_Authors
	, Ref.Location		Ref_Location
	, Ref.DBX_Oid		DBX_Oid
	, DBX.DBName		DBX_DBName
	, DBX.Accession		DBX_Accession
	, Ent.Accession		Ent_Accession
	, Ent.Identifier	Ent_Identifier
	, Ent.Name		Ent_Name
	, Ent.Description	Ent_Description
	, Ent.Version		Ent_Version
	, DB.Name		DB_Name
	, DB.Acronym		DB_Acronym
	, TNam.Name		Tax_Name
	, Tax.NCBI_Taxon_ID	Tax_NCBI_Taxon_ID
	, Ent.DB_Oid		DB_Oid
	, Ent.Tax_Oid		Tax_Oid
-- legacy mapping
	, DBX.Accession		Ref_Document_ID
	, Ent.Name		Ent_Display_ID
FROM SG_Bioentry_Ref_Assoc EntRefA, SG_Reference Ref, SG_DBXRef DBX,
     SG_Bioentry Ent, SG_Biodatabase DB, SG_Taxon Tax, SG_Taxon_Name TNam
WHERE     
     Ent.DB_Oid      = DB.Oid
AND  EntRefA.Ent_Oid = Ent.Oid
AND  EntRefA.Ref_Oid = Ref.Oid
AND  Ref.DBX_Oid     = DBX.Oid (+)
AND  Ent.Tax_Oid     = Tax.Oid (+)
AND  TNam.Tax_Oid (+) = Tax.Oid
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
	TNam.Name		Tax_Name,
	Tax.NCBI_Taxon_ID	Tax_NCBI_Taxon_ID,
	Ent.DB_Oid		DB_Oid,
	Ent.Tax_Oid		Tax_Oid
FROM SG_Bioentry Ent, SG_Biodatabase DB, SG_Taxon Tax, SG_Taxon_Name TNam,
     SG_Bioentry_DBXref_Assoc EntDBXA, SG_DBXRef DBX
WHERE     
     Ent.DB_Oid      = DB.Oid
AND  EntDBXA.Ent_Oid = Ent.Oid
AND  EntDBXA.DBX_Oid = DBX.Oid
AND  Ent.Tax_Oid     = Tax.Oid (+)
AND  TNam.Tax_Oid (+) = Tax.Oid
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
	Fea.Display_Name	Fea_Display_Name,
	Fea.Rank		Fea_Rank,
	Fea.Type_Trm_Oid	Type_Trm_Oid,
	FType.Name		Type_Trm_Name,
	FTCat.Name		Type_Ont_Name,
	Fea.Source_Trm_Oid	Source_Trm_Oid,
	FSrc.Name		Source_Trm_Name,
	Ent.Accession		Ent_Accession,
	Ent.Identifier		Ent_Identifier,
	Ent.Version		Ent_Version,
	DB.Name			DB_Name,
	DB.Acronym		DB_Acronym,
	TNam.Name		Tax_Name,
	Tax.NCBI_Taxon_ID	Tax_NCBI_Taxon_ID,
	Ent.Oid			Ent_Oid,
	Ent.DB_Oid		DB_Oid,
	Ent.Tax_Oid		Tax_Oid,
-- legacy mappings
	Fea.Type_Trm_Oid	FType_Oid,
	FType.Name		FType_Name,
	FTCat.Name		FType_Cat_Name,
	Fea.Source_Trm_Oid	FSrc_Oid,
	FSrc.Name		FSrc_Name
FROM SG_Seqfeature Fea, SG_Term FType, SG_Ontology FTCat, SG_Term FSrc, 
     SG_Bioentry Ent, SG_Biodatabase DB, SG_Taxon Tax, SG_Taxon_Name TNam
WHERE
     Fea.Ent_Oid        = Ent.Oid
AND  Fea.Type_Trm_Oid   = FType.Oid
AND  FType.Ont_Oid   	= FTCat.Oid
AND  Ent.DB_Oid         = DB.Oid
AND  Fea.Source_Trm_Oid = FSrc.Oid
AND  Ent.Tax_Oid     	= Tax.Oid (+)
AND  TNam.Tax_Oid (+) 	= Tax.Oid
;

--
-- Seqfeatures with location(s)
--
PROMPT
PROMPT Creating view SGLD_Locations

CREATE OR REPLACE VIEW SGLD_Locations
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
	FType.Oid		Type_Trm_Oid,
	FType.Name		Type_Trm_Name,
	FType.Identifier	Type_Trm_Identifier,
	FTCat.Name		Type_Ont_Name,
	FSrc.Oid		Source_Trm_Oid,
	FSrc.Name		Source_Trm_Name,
	Ent.Accession		Ent_Accession,
	Ent.Identifier		Ent_Identifier,
	Ent.Name		Ent_Name,
	DB.Name			DB_Name,
	DB.Acronym		DB_Acronym,
	TNam.Name		Tax_Name,
	Tax.NCBI_Taxon_ID	Tax_NCBI_Taxon_ID,
	Ent.Oid			Ent_Oid,
	Ent.DB_Oid		DB_Oid,
	Ent.Tax_Oid		Tax_Oid,
-- legacy mappings
	FType.Oid		FType_Oid,
	FType.Name		FType_Name,
	FTCat.Name		FType_Cat_Name,
	FSrc.Oid		FSrc_Oid,
	FSrc.Name		FSrc_Name,
	Ent.Name		Ent_Display_ID
FROM SG_Location Loc, SG_Seqfeature Fea, SG_DBXref DBX, SG_Bioentry Ent,
     SG_Term FType, SG_Ontology FTCat, SG_Term FSrc,
     SG_Biodatabase DB, SG_Taxon Tax, SG_Taxon_Name TNam
WHERE
     Loc.Fea_Oid        = Fea.Oid
AND  Fea.Ent_Oid     	= Ent.Oid
AND  Fea.Type_Trm_Oid   = FType.Oid
AND  FType.Ont_Oid   	= FTCat.Oid
AND  Ent.DB_Oid      	= DB.Oid
AND  Fea.Source_Trm_Oid = FSrc.Oid
AND  Ent.Tax_Oid     	= Tax.Oid (+)
AND  TNam.Tax_Oid (+) 	= Tax.Oid
AND  Loc.DBX_Oid     	= DBX.Oid (+)
;

--
-- Bioentry-Qualifier associations
--
PROMPT
PROMPT Creating view SGLD_Bioentry_Qualifier_Assocs

CREATE OR REPLACE VIEW SGLD_Bioentry_Qualifier_Assocs
AS
SELECT
	EntTrmA.Ent_Oid		Ent_Oid,
	EntTrmA.Trm_Oid		Trm_Oid,
	EntTrmA.Value		EntTrmA_Value,
	Ent.Accession		Ent_Accession,
	Ent.Identifier		Ent_Identifier,
	Ent.Version		Ent_Version,
	DB.Oid			DB_Oid,
	DB.Name			DB_Name,
	DB.Acronym		DB_Acronym,
	Trm.Name		Trm_Name,
	Trm.Identifier		Trm_Identifier,
	Trm.Ont_Oid		Ont_Oid,
	Cat.Name		Ont_Name,
-- legacy mappings
	Trm.Ont_Oid		Ont_Cat_Oid,
	Cat.Name		Ont_Cat_Name,
	NULL			Ont_Cat_Identifier
FROM SG_Bioentry_Qualifier_Assoc EntTrmA, SG_Term Trm,
     SG_Bioentry Ent, SG_Biodatabase DB, SG_Ontology Cat
WHERE
     EntTrmA.Trm_Oid = Trm.Oid
AND  EntTrmA.Ent_Oid = Ent.Oid
AND  Ent.DB_Oid	     = DB.Oid
AND  Trm.Ont_Oid     = Cat.Oid
;

--
-- Genome mappings
--
PROMPT
PROMPT Creating view SGLD_Chr_Map_Assocs

CREATE OR REPLACE VIEW SGLD_Chr_Map_Assocs
AS
SELECT
	HSP.Oid			EntSeg_Oid
	, EntLoc.Start_Pos	EntSeg_Start_Pos
	, EntLoc.End_Pos	EntSeg_End_Pos
	, HSP.Rank		EntSeg_Num
	, Exon.Oid		ChrSeg_Oid
	, ChrLoc.Start_Pos	ChrSeg_Start_Pos
	, ChrLoc.End_Pos	ChrSeg_End_Pos
	, ChrLoc.Strand		ChrSeg_Strand
	, FeaTrmA.Value		ChrSeg_Pct_Identity
	, FType.Name		FType_Name
	, FSrc.Name		FSrc_Name
	, Ent.Oid		Ent_Oid
	, Ent.Accession		Ent_Accession
	, Ent.Identifier	Ent_Identifier
	, Ent.Version		Ent_Version
	, Ent.DB_Oid		DB_Oid
	, DB.Name		DB_Name
	, DB.Acronym		DB_Acronym
	, Ent.Tax_Oid		Ent_Tax_Oid
	, EntTNam.Name		Ent_Tax_Name
	, EntTax.NCBI_Taxon_ID	Ent_Tax_NCBI_Taxon_ID
	, Chr.Oid		Chr_Oid
	, Chr.Name		Chr_Name
	, Chr.Accession		Chr_Accession
	, Chr.DB_Oid		Asm_Oid
	, Asm.Name		Asm_Name
	, Asm.Acronym		Asm_Acronym
	, Tax.Oid		Asm_Tax_Oid
	, TNam.Name		Asm_Tax_Name
	, Tax.NCBI_Taxon_ID	Asm_Tax_NCBI_Taxon_ID
-- legacy mappings
	, NULL			Ent_Tax_Variant
	, NULL			Asm_Tax_Variant
FROM SG_Bioentry Ent, SG_Bioentry Chr,
     SG_Seqfeature HSP, SG_Seqfeature Exon,
     SG_Location EntLoc, SG_Location ChrLoc,
     SG_Biodatabase DB, SG_Biodatabase Asm,
     SG_Seqfeature_Assoc Sim,
     SG_Term FType,
     SG_Term FSrc,
     SG_Term RelType,
     SG_Term Qual,
     SG_Seqfeature_Qualifier_Assoc FeaTrmA,
     SG_Taxon Tax, SG_Taxon_Name TNam, SG_Taxon EntTax, SG_Taxon_Name EntTNam
WHERE
     Ent.DB_Oid      = DB.Oid
AND  HSP.Ent_Oid     = Ent.Oid
AND  EntLoc.Fea_Oid  = HSP.Oid
AND  HSP.Type_Trm_Oid   = FType.Oid
AND  HSP.Source_Trm_Oid = FSrc.Oid
AND  Chr.DB_Oid      = Asm.Oid
AND  Exon.Ent_Oid    = Chr.Oid
AND  ChrLoc.Fea_Oid  = Exon.Oid
AND  Chr.Tax_Oid     = Tax.Oid
AND  TNam.Tax_Oid    = Tax.Oid
AND  Sim.Subj_Fea_Oid= HSP.Oid
AND  Sim.Obj_Fea_Oid = Exon.Oid
AND  Sim.Trm_Oid     = RelType.Oid
AND  RelType.Name    = 'Genome Alignment'
AND  Exon.Type_Trm_Oid   = FType.Oid
AND  Exon.Source_Trm_Oid = FSrc.Oid
AND  FeaTrmA.Fea_Oid = Exon.Oid
AND  FeaTrmA.Trm_Oid = Qual.Oid
AND  Qual.Name       = 'Pct_Identity'
AND  Ent.Tax_Oid     = EntTax.Oid
AND  EntTNam.Tax_Oid = EntTax.Oid
;

