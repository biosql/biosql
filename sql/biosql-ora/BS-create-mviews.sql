--
-- SQL script to create the warehouse materialized views for SYMGENE/BioSQL
--
-- $GNF: projects/gi/symgene/src/DB/BS-create-mviews.sql,v 1.4 2003/01/29 09:00:11 hlapp Exp $
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

@BS-defs

define mview_index=&biosql_data

--
-- Entity-chromosome mappings
--
PROMPT
PROMPT Creating materialized view SG_Ent_Chr_Map

CREATE MATERIALIZED VIEW SG_Ent_Chr_Map
BUILD DEFERRED
USING INDEX TABLESPACE &mview_index
REFRESH FORCE ON DEMAND
ENABLE QUERY REWRITE
AS
SELECT
	EntLoc.Start_Pos	EntSeg_Start_Pos,
	EntLoc.End_Pos		EntSeg_End_Pos,
	SUBSTR(NumA.Value,1,5)	EntSeg_Num,
	ChrLoc.Start_Pos	ChrSeg_Start_Pos,
	ChrLoc.End_Pos		ChrSeg_End_Pos,
	ChrLoc.Strand		ChrSeg_Strand,
	SUBSTR(FeaOntA.Value,1,5) ChrSeg_Pct_Identity,
	FType.Name		FType_Name,
	FSrc.Name		FSrc_Name,
	Ent.Accession		Ent_Accession,
	Ent.Version		Ent_Version,
	Ent.Identifier		Ent_Identifier,
	DB.Name			DB_Name,
	DB.Acronym		DB_Acronym,
--	EntTax.Name		Ent_Tax_Name,
--	EntTax.Variant		Ent_Tax_Variant,
--	EntTax.NCBI_Taxon_ID	Ent_Tax_NCBI_Taxon_ID,
	Chr.Display_ID		Chr_Name,
	Chr.Accession		Chr_Accession,
	Asm.Name		Asm_Name,
	Asm.Acronym		Asm_Acronym,
	Tax.Name		Asm_Tax_Name,
	Tax.Variant		Asm_Tax_Variant,
	Tax.NCBI_Taxon_ID	Asm_Tax_NCBI_Taxon_ID,
	HSP.Oid			EntSeg_Oid,
	Ent.Oid			Ent_Oid,
	Ent.Tax_Oid		Ent_Tax_Oid,
	Ent.DB_Oid		DB_Oid,
	Exon.Oid		ChrSeg_Oid,
	Chr.Oid			Chr_Oid,
	Chr.DB_Oid		Asm_Oid,
	Chr.Tax_Oid		Asm_Tax_Oid,
	FType.Oid		FType_Oid,
	FSrc.Oid		FSrc_Oid
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
     SG_Taxon Tax --, SG_Taxon EntTax
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
--AND  Ent.Tax_Oid     = EntTax.Oid
;

--
-- create the indexes
--
CREATE INDEX ecm_ent_oid ON SG_Ent_Chr_Map 
(
	Ent_Oid 
) TABLESPACE &mview_index
;
CREATE INDEX ecm_acc     ON SG_Ent_Chr_Map
(
	Ent_Accession 
) TABLESPACE &mview_index
;
CREATE INDEX ecm_chr     ON SG_Ent_Chr_Map
( 
	Chr_Name,
	ChrSeg_Start_Pos,
	ChrSeg_End_Pos
) TABLESPACE &mview_index
;


--
-- Name searching for Bioentries
--
PROMPT
PROMPT Creating materialized view SG_Bioentry_Name

CREATE MATERIALIZED VIEW SG_Bioentry_Name
BUILD IMMEDIATE
USING INDEX TABLESPACE &mview_index
REFRESH FORCE 
START WITH TRUNC(SYSDATE)+1+5/24 
      NEXT TRUNC(SYSDATE)+2+5/24 
ENABLE QUERY REWRITE
AS
SELECT
	Ent.Accession	Ent_Name,
	DB.Name	     	DB_Name, 
	Tax.Name     	Tax_Name,
	Tax.Variant	Tax_Variant,
	Ent.Oid	     	Ent_Oid  
FROM SG_Bioentry Ent, SG_Biodatabase DB, SG_Taxon Tax
WHERE
     Ent.DB_Oid	 = DB.Oid
AND  Ent.Tax_Oid = Tax.Oid (+)
UNION
SELECT
	Ent.Identifier	Ent_Name, 
	DB.Name      	DB_Name, 
	Tax.Name     	Tax_Name,
	Tax.Variant	Tax_Variant,
	Ent.Oid	      	Ent_Oid  
FROM SG_Bioentry Ent, SG_Biodatabase DB, SG_Taxon Tax
WHERE
     Ent.DB_Oid	 = DB.Oid
AND  Ent.Identifier IS NOT NULL
AND  Ent.Tax_Oid = Tax.Oid (+)
UNION
SELECT
	UPPER(Ent.Display_ID)	Ent_Name,
	DB.Name      	DB_Name, 
	Tax.Name     	Tax_Name,
	Tax.Variant	Tax_Variant,
	Ent.Oid	      	Ent_Oid  
FROM SG_Bioentry Ent, SG_Biodatabase DB, SG_Taxon Tax
WHERE
     Ent.DB_Oid	 = DB.Oid
AND  Ent.Display_ID IS NOT NULL
AND  Ent.Tax_Oid = Tax.Oid (+)
UNION
SELECT
	UPPER(SUBSTR(EntOntA.Value,1,32))	Ent_Name,
	DB.Name 		  	DB_Name, 
	Tax.Name		  	Tax_Name,
	Tax.Variant			Tax_Variant,
	EntOntA.Ent_Oid		  	Ent_Oid  
FROM SG_Bioentry_Qualifier_Assoc EntOntA,
     SG_Bioentry Ent, SG_Biodatabase DB, SG_Taxon Tax,
     SG_Ontology_Term Ont, SG_Ontology_Term Type, SG_Ontology_Term Tgt, 
     SG_Ontology_Term_Assoc OntA
WHERE
     EntOntA.Ont_Oid	= Ont.Oid
AND  OntA.Src_Ont_Oid	= Ont.Oid
AND  OntA.Type_Ont_Oid	= Type.Oid
AND  OntA.Tgt_Ont_Oid	= Tgt.Oid
AND  EntOntA.Ent_Oid    = Ent.Oid
AND  Ent.DB_Oid		= DB.Oid
AND  Ent.Tax_Oid	= Tax.Oid (+)
AND  Type.Identifier 	= 'REO:1000008'  -- is-a
AND  Tgt.Identifier	= 'QUO:1000001'  -- 'bioentry name'
;

--
-- Indexes: we need one on name; you'll also need one on ent_oid for the
-- reverse search (all names for an oid).
--
CREATE INDEX XIE1Bioentry_Name ON SG_Bioentry_Name
(
	Ent_Name
) 
	TABLESPACE &mview_index
;
