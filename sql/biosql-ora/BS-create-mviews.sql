--
-- SQL script to create the warehouse materialized views for SYMGENE/BioSQL
--
-- $GNF: projects/gi/symgene/src/DB/BS-create-mviews.sql,v 1.7 2003/05/21 06:50:13 hlapp Exp $
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

@BS-defs-local

define mview_index=&biosql_index

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
	EntLoc.Start_Pos	EntSeg_Start_Pos
	, EntLoc.End_Pos	EntSeg_End_Pos
	, SUBSTR(NumA.Value,1,5) EntSeg_Num
	, ChrLoc.Start_Pos	ChrSeg_Start_Pos
	, ChrLoc.End_Pos	ChrSeg_End_Pos
	, ChrLoc.Strand		ChrSeg_Strand
	, SUBSTR(FeaTrmA.Value,1,5) ChrSeg_Pct_Identity
	, EntLoc.Oid		EntSeg_Loc_Oid
	, EntSeg.Oid		EntSeg_Oid
	, EntSeg.Type_Trm_Oid	EntSeg_Type_Oid
	, EntSeg.Source_Trm_Oid	EntSeg_Source_Oid
	, Ent.Oid		Ent_Oid
	, Ent.Tax_Oid		Ent_Tax_Oid
	, Ent.DB_Oid		DB_Oid
	, ChrLoc.Oid		ChrSeg_Loc_Oid
	, ChrSeg.Oid		ChrSeg_Oid
	, Chr.Oid		Chr_Oid
	, Chr.Tax_Oid		Chr_Tax_Oid
	, Chr.DB_Oid		Asm_Oid
FROM SG_Bioentry Ent, SG_Bioentry Chr,
     SG_Seqfeature EntSeg, SG_Seqfeature ChrSeg,
     SG_Location EntLoc, SG_Location ChrLoc,
     SG_Seqfeature_Qualifier_Assoc FeaTrmA,
     SG_Seqfeature_Qualifier_Assoc NumA,
     SG_Seqfeature_Assoc HSP,
     SG_Term RelType,
     SG_Term Qual,
     SG_Term NumQual
WHERE
     EntSeg.Ent_Oid   = Ent.Oid
AND  EntLoc.Fea_Oid   = EntSeg.Oid
AND  EntLoc.Rank      = 1
AND  ChrSeg.Ent_Oid   = Chr.Oid
AND  ChrLoc.Fea_Oid   = ChrSeg.Oid
AND  ChrLoc.Rank      = 1
AND  HSP.Subj_Fea_Oid = EntSeg.Oid
AND  HSP.Obj_Fea_Oid  = ChrSeg.Oid
AND  HSP.Trm_Oid      = RelType.Oid
AND  HSP.Rank	      = 0
AND  RelType.Name     = 'Genome Alignment'
AND  FeaTrmA.Fea_Oid  = EntSeg.Oid
AND  FeaTrmA.Trm_Oid  = Qual.Oid
AND  FeaTrmA.Rank     = 1
AND  Qual.Name        = 'Pct_Identity'
AND  NumA.Fea_Oid     = EntSeg.Oid
AND  NumA.Trm_Oid     = NumQual.Oid
AND  NumA.Rank	      = 1
AND  NumQual.Name     = 'Exon_Num'
;

--
-- create the indexes
--
CREATE INDEX ECM_Ent_Oid ON SG_Ent_Chr_Map 
(
	Ent_Oid 
) TABLESPACE &mview_index
;
CREATE INDEX ECM_Chr     ON SG_Ent_Chr_Map
( 
	Chr_Oid,
	ChrSeg_Start_Pos,
	ChrSeg_End_Pos
) TABLESPACE &mview_index
;


--
-- Name searching for Bioentries. We warehouse all of accession, identifier,
-- display_id (name), and term associations where the term is linked to
-- indicate a bioentry name.
--
PROMPT
PROMPT Creating materialized view SG_Bioentry_Name

CREATE MATERIALIZED VIEW SG_Bioentry_Name
	BUILD DEFERRED
       	USING INDEX TABLESPACE &mview_index
       	REFRESH FORCE 
       	START WITH TRUNC(SYSDATE)+1+4/24 
       	NEXT TRUNC(SYSDATE)+2+4/24 
	ENABLE QUERY REWRITE
AS
-- accessions as the name
SELECT
	Ent.Accession	Ent_Name,
	Ent.Oid	     	Ent_Oid
FROM SG_Bioentry Ent
UNION
-- identifiers as the name
SELECT
	Ent.Identifier			Ent_Name, 
	Ent.Oid	      			Ent_Oid
FROM SG_Bioentry Ent
UNION
-- capitalized name (display_id) as name
SELECT
	UPPER(Ent.Name)			Ent_Name,
	Ent.Oid				Ent_Oid
FROM SG_Bioentry Ent
UNION
-- capitalized symbols as names (these are in term-bioentry associations)
SELECT
	UPPER(SUBSTR(EntTrmA.Value,1,32)) Ent_Name,
	EntTrmA.Ent_Oid	     		Ent_Oid
FROM SG_Bioentry_Qualifier_Assoc EntTrmA,
     SG_Term Trm, SG_Term Type, SG_Term Obj, SG_Term_Assoc TrmA
WHERE
     EntTrmA.Trm_Oid	= Trm.Oid
AND  TrmA.Subj_Trm_Oid	= Trm.Oid
AND  TrmA.Pred_Trm_Oid	= Type.Oid
AND  TrmA.Obj_Trm_Oid	= Obj.Oid
AND  Type.Identifier 	= 'REO:1000008'  -- is-a
AND  Obj.Identifier	= 'QUO:1000001'  -- 'bioentry name'
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
CREATE INDEX XIE2Bioentry_Name ON SG_Bioentry_Name
(
	Ent_Oid
) 
	TABLESPACE &mview_index
;
