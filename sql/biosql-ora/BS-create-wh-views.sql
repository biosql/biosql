--
-- SQL script to create the views for SYMGENE/BioSQL that utilize the
-- warehouse materialized views.
--
-- $GNF: projects/gi/symgene/src/DB/BS-create-wh-views.sql,v 1.2 2002/11/17 05:58:47 hlapp Exp $
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
-- Genome mappings
--
PROMPT
PROMPT Creating view SG_Chr_Map_Assocs

CREATE OR REPLACE VIEW SG_Chr_Map_Assocs
AS
SELECT
	ECM.EntSeg_Start_Pos	EntSeg_Start_Pos,
	ECM.EntSeg_End_Pos	EntSeg_End_Pos,
	ECM.EntSeg_Num		EntSeg_Num,
	ECM.ChrSeg_Start_Pos	ChrSeg_Start_Pos,
	ECM.ChrSeg_End_Pos	ChrSeg_End_Pos,
	ECM.ChrSeg_Strand	ChrSeg_Strand,
	ECM.ChrSeg_Pct_Identity	ChrSeg_Pct_Identity,
	ECM.FType_Name		FType_Name,
	ECM.FSrc_Name		FSrc_Name,
	ECM.Ent_Accession	Ent_Accession,
	ECM.Ent_Identifier	Ent_Identifier,
	ECM.Ent_Version		Ent_Version,
	ECM.DB_Name		DB_Name,
	ECM.DB_Acronym		DB_Acronym,
	EntTax.Name		Ent_Tax_Name,
	EntTax.Variant		Ent_Tax_Variant,
	EntTax.NCBI_Taxon_ID	Ent_Tax_NCBI_Taxon_ID,
	ECM.Chr_Name		Chr_Name,
	ECM.Chr_Accession	Chr_Accession,
	ECM.Asm_Name		Asm_Name,
	ECM.Asm_Acronym		Asm_Acronym,
	ECM.Asm_Tax_Name	Asm_Tax_Name,
	ECM.Asm_Tax_Variant	Asm_Tax_Variant,
	ECM.Asm_Tax_NCBI_Taxon_ID Asm_Tax_NCBI_Taxon_ID,
	ECM.EntSeg_Oid		EntSeg_Oid,
	ECM.Ent_Oid		Ent_Oid,
	ECM.Ent_Tax_Oid		Ent_Tax_Oid,
	ECM.DB_Oid		DB_Oid,
	ECM.ChrSeg_Oid		ChrSeg_Oid,
	ECM.Chr_Oid		Chr_Oid,
	ECM.Asm_Oid		Asm_Oid,
	ECM.Asm_Tax_Oid		Asm_Tax_Oid,
	ECM.FType_Oid		FType_Oid,
	ECM.FSrc_Oid		FSrc_Oid
FROM SG_Ent_Chr_Map ECM, SG_Taxon EntTax
WHERE
     ECM.Ent_Tax_Oid     = EntTax.Oid (+)
;

--
-- Single entry point name searching
--
PROMPT
PROMPT Creating view SG_Bioentry_Names

CREATE OR REPLACE VIEW SG_Bioentry_Names
AS
SELECT
	BEN.Ent_Name		Ent_Name,
	Ent.Accession		Ent_Accession,
	Ent.Identifier		Ent_Identifier,
	Ent.Version		Ent_Version,
	Ent.Display_ID		Ent_Display_ID,
	Ent.Description		Ent_Description,
	BEN.DB_Name		DB_Name,
	BEN.Tax_Name		Tax_Name,
	BEN.Tax_Variant		Tax_Variant,
	BEN.Ent_Oid		Ent_Oid,
	Ent.DB_Oid		DB_Oid,
	Ent.Tax_Oid		Tax_Oid
FROM SG_Bioentry_Name BEN, SG_Bioentry Ent
WHERE
     BEN.Ent_Oid = Ent.Oid
;
