--
-- SQL script to create the views for SYMGENE/BioSQL
--
-- $GNF: projects/gi/symgene/src/DB/BS-create-views.sql,v 1.20 2003/05/23 21:58:43 hlapp Exp $
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
	Tax.Name		Tax_Name
	, TNam.Name		Tax_Common_Name
	, TNod.NCBI_Taxon_ID	Tax_NCBI_Taxon_ID
	, NULL			Tax_Full_Lineage
	, TNod.Oid		Tax_Oid
FROM SG_Taxon_Name Tax,
     SG_Taxon TNod LEFT OUTER JOIN SG_Taxon_Name TNam ON (
		TNam.Tax_Oid = TNod.Oid
	AND     TNam.Name_Class = 'common name'
     )
WHERE
     Tax.Tax_Oid          = TNod.Oid
AND  Tax.Name_Class       = 'scientific name'
;

--
-- Biodatabases (namespaces)
--
PROMPT
PROMPT Creating view SG_Biodatabases

CREATE OR REPLACE VIEW SG_Biodatabases
AS
SELECT
	DB.Oid			DB_Oid
	, DB.Name		DB_Name
	, DB.Authority		DB_Authority
	, DB.Acronym		DB_Acronym
	, DB.URI		DB_URI
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
	Ent.Accession		Ent_Accession
	, Ent.Identifier	Ent_Identifier
	, Ent.Name		Ent_Name
	, Ent.Description	Ent_Description
	, Ent.Version		Ent_Version
	, Ent.Division		Ent_Division
	, Sq.Alphabet		Ent_Alphabet
	, Sq.Version		Ent_Seq_Version
	, Sq.Length		Ent_Length
	, DB.Name		DB_Name
	, DB.Acronym		DB_Acronym
	, Ent.Oid		Ent_Oid
	, Ent.DB_Oid		DB_Oid
	, Ent.Tax_Oid		Tax_Oid
-- legacy mappings
	, Ent.Name		Ent_Display_ID
FROM SG_Bioentry Ent, SG_Biodatabase DB, SG_Biosequence Sq
WHERE
     Ent.DB_Oid  = DB.Oid
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
	Trm.Name		Trm_Name
	, Trm.Identifier	Trm_Identifier
	, Ont.Name		Ont_Name
	, SEnt.Accession	Subj_Ent_Accession
	, SEnt.Identifier	Subj_Ent_Identifier
	, SEnt.Name		Subj_Ent_Name
	, SEnt.Description	Subj_Ent_Description
	, SEnt.Version		Subj_Ent_Version
	, TEnt.Accession	Obj_Ent_Accession
	, TEnt.Identifier	Obj_Ent_Identifier
	, TEnt.Name		Obj_Ent_Name
	, TEnt.Description	Obj_Ent_Description
	, TEnt.Version		Obj_Ent_Version
	, EntA.Oid		EntA_Oid
	, EntA.Subj_Ent_Oid	Subj_Ent_Oid
	, SEnt.DB_Oid		Subj_DB_Oid
	, SEnt.Tax_Oid		Subj_Tax_Oid
	, EntA.Obj_Ent_Oid	Obj_Ent_Oid
	, TEnt.DB_Oid		Obj_DB_Oid
	, TEnt.Tax_Oid		Obj_Tax_Oid
	, EntA.Trm_Oid		Trm_Oid
	, Trm.Ont_Oid		Ont_Oid
FROM SG_Bioentry_Assoc EntA, SG_Bioentry SEnt, SG_Bioentry TEnt, SG_Term Trm,
     SG_Ontology Ont
WHERE
     EntA.Subj_Ent_Oid = SEnt.Oid
AND  EntA.Obj_Ent_Oid  = TEnt.Oid
AND  EntA.Trm_Oid      = Trm.Oid
AND  Trm.Ont_Oid       = Ont.Oid
;

--
-- Ontologies
--
PROMPT
PROMPT Creating view SG_Ontologies

CREATE OR REPLACE VIEW SG_Ontologies
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
PROMPT Creating view SG_Terms

CREATE OR REPLACE VIEW SG_Terms
AS
SELECT
	Trm.Name		Trm_Name
	, Trm.Identifier	Trm_Identifier
	, Trm.Definition	Trm_Definition
	, Trm.Is_Obsolete	Trm_Is_Obsolete
	, Ont.Name		Ont_Name
	, Ont.Definition	Ont_Definition
	, Trm.Oid		Trm_Oid
	, Trm.Ont_Oid		Ont_Oid
FROM SG_Term Trm, SG_Ontology Ont
WHERE
     Trm.Ont_Oid  = Ont.Oid
;

--
-- Ontology term associations; this is root-oriented
--
PROMPT
PROMPT Creating view SG_Term_Assocs

CREATE OR REPLACE VIEW SG_Term_Assocs
AS
SELECT
	AOnt.Name		Ont_Name
	, STrm.Name		Subj_Trm_Name
	, STrm.Identifier	Subj_Trm_Identifier
	, STrm.Is_Obsolete	Subj_Trm_Is_Obsolete
	, SOnt.Name		Subj_Ont_Name
	, TTrm.Name		Pred_Trm_Name
	, TTrm.Identifier	Pred_Trm_Identifier
	, TTrm.Is_Obsolete	Pred_Trm_Is_Obsolete
	, TOnt.Name		Pred_Ont_Name
	, OTrm.Name		Obj_Trm_Name
	, OTrm.Identifier	Obj_Trm_Identifier
	, OTrm.Is_Obsolete	Obj_Trm_Is_Obsolete
	, OOnt.Name		Obj_Ont_Name
	, TrmA.Oid		TrmA_Oid
	, TrmA.Ont_Oid		Ont_Oid
	, TrmA.Subj_Trm_Oid	Subj_Trm_Oid
	, STrm.Ont_Oid		Subj_Ont_Oid
	, TrmA.Pred_Trm_Oid	Pred_Trm_Oid
	, TTrm.Ont_Oid		Pred_Ont_Oid
	, TrmA.Obj_Trm_Oid	Obj_Trm_Oid
	, OTrm.Ont_Oid		Obj_Ont_Oid
FROM SG_Term_Assoc TrmA, SG_Term STrm, SG_Term TTrm, SG_Term OTrm,
     SG_Ontology SOnt, SG_Ontology TOnt, SG_Ontology OOnt, SG_Ontology AOnt
WHERE
     TrmA.Subj_Trm_Oid  = STrm.Oid
AND  TrmA.Pred_Trm_Oid  = TTrm.Oid
AND  TrmA.Obj_Trm_Oid   = OTrm.Oid
AND  TrmA.Ont_Oid	= AOnt.Oid
AND  STrm.Ont_Oid       = SOnt.Oid
AND  OTrm.Ont_Oid       = OOnt.Oid
AND  TTrm.Ont_Oid       = TOnt.Oid
;

--
-- Transitive closure over term relationships
--
PROMPT
PROMPT Creating view SG_Term_Paths

CREATE OR REPLACE VIEW SG_Term_Paths
AS
SELECT
	TrmP.Distance		TrmP_Distance
	, AOnt.Name		Ont_Name
	, STrm.Name		Subj_Trm_Name
	, STrm.Identifier	Subj_Trm_Identifier
	, STrm.Is_Obsolete	Subj_Trm_Is_Obsolete
	, SOnt.Name		Subj_Ont_Name
	, TTrm.Name		Pred_Trm_Name
	, TTrm.Identifier	Pred_Trm_Identifier
	, TTrm.Is_Obsolete	Pred_Trm_Is_Obsolete
	, TOnt.Name		Pred_Ont_Name
	, OTrm.Name		Obj_Trm_Name
	, OTrm.Identifier	Obj_Trm_Identifier
	, OTrm.Is_Obsolete	Obj_Trm_Is_Obsolete
	, OOnt.Name		Obj_Ont_Name
	, TrmP.Oid		TrmP_Oid
	, TrmP.Ont_Oid		Ont_Oid
	, TrmP.Subj_Trm_Oid	Subj_Trm_Oid
	, STrm.Ont_Oid		Subj_Ont_Oid
	, TrmP.Pred_Trm_Oid	Pred_Trm_Oid
	, TTrm.Ont_Oid		Pred_Ont_Oid
	, TrmP.Obj_Trm_Oid	Obj_Trm_Oid
	, OTrm.Ont_Oid		Obj_Ont_Oid
FROM SG_Term_Path TrmP, SG_Term STrm, SG_Term TTrm, SG_Term OTrm,
     SG_Ontology SOnt, SG_Ontology TOnt, SG_Ontology OOnt, SG_Ontology AOnt
WHERE
     TrmP.Subj_Trm_Oid  = STrm.Oid
AND  TrmP.Pred_Trm_Oid  = TTrm.Oid
AND  TrmP.Obj_Trm_Oid   = OTrm.Oid
AND  TrmP.Ont_Oid	= AOnt.Oid
AND  STrm.Ont_Oid       = SOnt.Oid
AND  OTrm.Ont_Oid       = OOnt.Oid
AND  TTrm.Ont_Oid       = TOnt.Oid
;

--
-- Annotation: References
--
PROMPT
PROMPT Creating view SG_References

CREATE OR REPLACE VIEW SG_References
AS
SELECT
	Ref.Title		Ref_Title
	, Ref.Authors		Ref_Authors
	, Ref.Location		Ref_Location
	, Ref.CRC		Ref_CRC
	, DBX.DBName		DBX_DBName
	, DBX.Accession		DBX_Accession
	, Ref.Oid		Ref_Oid
	, Ref.DBX_Oid		DBX_Oid
-- legacy mappings
	, DBX.Accession		Ref_Document_ID
FROM SG_Reference Ref, SG_DBXref DBX
WHERE
     Ref.DBX_Oid  = DBX.Oid (+)
;

--
-- Annotation: DBXRefs
--
PROMPT
PROMPT Creating view SG_DBXRefs

CREATE OR REPLACE VIEW SG_DBXRefs
AS
SELECT
	DBX.DBName		DBX_DBName
	, DBX.Accession		DBX_Accession
	, DBX.Version		DBX_Version
	, DBX.Oid		DBX_Oid
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
	Cmt.Comment_Text	Cmt_Comment_Text
	, Cmt.Rank		Cmt_Rank
	, Cmt.Oid		Cmt_Oid
	, Cmt.Ent_Oid		Ent_Oid
FROM SG_Comment Cmt
;

--
-- Bioentry-Reference associations
--
PROMPT
PROMPT Creating view SG_Bioentry_Ref_Assocs

CREATE OR REPLACE VIEW SG_Bioentry_Ref_Assocs
AS
SELECT
	Ref.Title		Ref_Title
	, Ref.Authors		Ref_Authors
	, Ref.Location		Ref_Location
	, Ref.CRC		Ref_CRC
	, DBX.DBName 		DBX_DBName
	, DBX.Accession		DBX_Accession
	, EntRefA.Start_Pos	EntRefA_Start_Pos
	, EntRefA.End_Pos	EntRefA_End_Pos
	, EntRefA.Rank		EntRefA_Rank
	, EntRefA.Ent_Oid	Ent_Oid
	, Ref.Oid		Ref_Oid
	, Ref.DBX_Oid		DBX_Oid
-- legacy mappings
	, DBX.Accession		Ref_Document_ID
FROM SG_Bioentry_Ref_Assoc EntRefA, SG_Reference Ref, SG_DBXRef DBX
WHERE     
     EntRefA.Ref_Oid = Ref.Oid
AND  Ref.DBX_Oid     = DBX.Oid (+)
;

--
-- Bioentry-DBXref associations
--
PROMPT
PROMPT Creating view SG_Bioentry_DBXRef_Assocs

CREATE OR REPLACE VIEW SG_Bioentry_DBXRef_Assocs
AS
SELECT
	DBX.DBName		DBX_DBName
	, DBX.Accession		DBX_Accession
	, DBX.Version		DBX_Version
	, EntDBXA.Rank		EntDBXA_Rank
	, EntDBXA.DBX_Oid	DBX_Oid
	, EntDBXA.Ent_Oid	Ent_Oid
FROM SG_Bioentry_DBXref_Assoc EntDBXA, SG_DBXRef DBX
WHERE     
     EntDBXA.DBX_Oid = DBX.Oid
;

--
-- Bioentry-Qualifier associations
--
PROMPT
PROMPT Creating view SG_Bioentry_Qual_Assocs

CREATE OR REPLACE VIEW SG_Bioentry_Qual_Assocs
AS
SELECT
	Trm.Name		Trm_Name
	, Trm.Identifier	Trm_Identifier
	, Ont.Name		Ont_Name
	, EntTrmA.Value		Qual_Value
	, EntTrmA.Trm_Oid	Trm_Oid
	, Trm.Ont_Oid		Ont_Oid
	, EntTrmA.Ent_Oid	Ent_Oid
FROM SG_Bioentry_Qualifier_Assoc EntTrmA, SG_Term Trm, SG_Ontology Ont
WHERE
     Trm.Ont_Oid     = Ont.Oid
AND  EntTrmA.Trm_Oid = Trm.Oid
;

--
-- Seqfeatures
--
PROMPT
PROMPT Creating view SG_Seqfeatures

CREATE OR REPLACE VIEW SG_Seqfeatures
AS
SELECT
	Fea.Display_Name	Fea_Display_Name
	, Fea.Rank		Fea_Rank
	, FType.Name		Type_Trm_Name
	, FType.Identifier	Type_Trm_Identifier
	, FTOnt.Name		Type_Ont_Name
	, FSrc.Name		Source_Trm_Name
	, FSrc.Identifier	Source_Trm_Identifier
	, FSOnt.Name		Source_Ont_Name
	, Fea.Oid		Fea_Oid
	, Fea.Type_Trm_Oid	Type_Trm_Oid
	, FType.Ont_Oid		Type_Ont_Oid
	, Fea.Source_Trm_Oid	Source_Trm_Oid
	, FSrc.Ont_Oid		Source_Ont_Oid
	, Fea.Ent_Oid		Ent_Oid
FROM SG_Seqfeature Fea, SG_Term FType, SG_Term FSrc, 
     SG_Ontology FTOnt, SG_Ontology FSOnt
WHERE
     Fea.Type_Trm_Oid   = FType.Oid
AND  FType.Ont_Oid	= FTOnt.Oid
AND  Fea.Source_Trm_Oid = FSrc.Oid
AND  FSrc.Ont_Oid	= FSOnt.Oid
;

--
-- Seqfeatures with location(s)
--
PROMPT
PROMPT Creating view SG_Locations

CREATE OR REPLACE VIEW SG_Locations
AS
SELECT
	Loc.Start_Pos		Loc_Start_Pos
	, Loc.End_Pos		Loc_End_Pos
	, Loc.Strand		Loc_Strand
	, Loc.Rank		Loc_Rank
	, DBX.DBName		Loc_SeqID_DB
	, DBX.Accession		Loc_SeqID_Acc
	, Loc.Fea_Oid		Fea_Oid
FROM SG_Location Loc, SG_DBXref DBX
WHERE
     Loc.DBX_Oid     = DBX.Oid (+)
;

--
-- Seqfeature-Qualifier associations
--
PROMPT
PROMPT Creating view SG_Seqfeature_Qual_Assocs

CREATE OR REPLACE VIEW SG_Seqfeature_Qual_Assocs
AS
SELECT
	Trm.Name		Trm_Name
	, Trm.Identifier	Trm_Identifier
	, Ont.Name		Ont_Name
	, FeaTrmA.Value		Qual_Value
	, FeaTrmA.Rank		Qual_Rank
	, FeaTrmA.Fea_Oid	Fea_Oid
	, FeaTrmA.Trm_Oid	Trm_Oid
	, Trm.Ont_Oid		Ont_Oid
FROM SG_Seqfeature_Qualifier_Assoc FeaTrmA, SG_Term Trm, SG_Ontology Ont
WHERE
     FeaTrmA.Trm_Oid = Trm.Oid
AND  Trm.Ont_Oid     = Ont.Oid
;

--
-- Bioentry relationships based on DBXrefs
--
CREATE OR REPLACE VIEW SG_DBX_Bioentry_Assocs
AS
SELECT
	SEnt.Accession		Subj_Ent_Accession
	, SEnt.Identifier	Subj_Ent_Identifier
	, SEnt.Name		Subj_Ent_Name
	, SEnt.Description	Subj_Ent_Description
	, SEnt.Version		Subj_Ent_Version
	, SDB.Name		Subj_DB_Name
	, SDB.Acronym		Subj_DB_Acronym
	, STrm.Name		Subj_BEType_Name
	, STrm.Identifier	Subj_BEType_Identifier
	, STNam.Name		Subj_Tax_Name
	, STax.NCBI_Taxon_ID	Subj_Tax_NCBI_Taxon_ID
	, TEnt.Accession	Obj_Ent_Accession
	, TEnt.Identifier	Obj_Ent_Identifier
	, TEnt.Name		Obj_Ent_Name
	, TEnt.Description	Obj_Ent_Description
	, TEnt.Version		Obj_Ent_Version
	, DBX.Version		Obj_DBX_Version
	, TDB.Name		Obj_DB_Name
	, TDB.Acronym		Obj_DB_Acronym
	, TTrm.Name		Obj_BEType_Name
	, TTrm.Identifier	Obj_BEType_Identifier
	, TTNam.Name		Obj_Tax_Name
	, TTax.NCBI_Taxon_ID	Obj_Tax_NCBI_Taxon_ID
	, SEnt.Oid		Subj_Ent_Oid
	, SEnt.DB_Oid		Subj_DB_Oid
	, SEnt.Tax_Oid		Subj_Tax_Oid
	, TEnt.Oid		Obj_Ent_Oid
	, TEnt.DB_Oid		Obj_DB_Oid
	, TEnt.Tax_Oid		Obj_Tax_Oid
	, DBX.Oid		DBX_Oid
	, SEntTrmA.Trm_Oid	Subj_BEType_Oid
	, TEntTrmA.Trm_Oid	Obj_BEType_Oid
FROM SG_Bioentry SEnt, SG_Bioentry TEnt, 
     SG_Bioentry_DBXref_Assoc DBXEntA, SG_DBXref DBX,
     SG_Bioentry_Qualifier_Assoc SEntTrmA,
     SG_Bioentry_Qualifier_Assoc TEntTrmA,
     SG_Term STrm, SG_Ontology SOnt,
     SG_Term TTrm, SG_Ontology TOnt,
     SG_Taxon STax, SG_Taxon TTax, SG_Taxon_Name STNam, SG_Taxon_Name TTNam,
     SG_Biodatabase SDB, SG_Biodatabase TDB
WHERE
     DBXEntA.Ent_Oid  = SEnt.Oid
AND  DBXEntA.DBX_Oid  = DBX.Oid
AND  SEnt.DB_Oid      = SDB.Oid
AND  TEnt.DB_Oid      = TDB.Oid
AND  TDB.Name	      = DBX.DBName
AND  TEnt.Accession   = DBX.Accession
--AND  TEnt.Version     = DBX.Version
AND  SEntTrmA.Ent_Oid = SEnt.Oid
AND  SEntTrmA.Trm_Oid = STrm.Oid
AND  STrm.Ont_Oid     = SOnt.Oid
AND  SOnt.Name	      = 'Bioentry Type Ontology'
AND  TEntTrmA.Ent_Oid = TEnt.Oid
AND  TEntTrmA.Trm_Oid = TTrm.Oid
AND  TTrm.Ont_Oid     = SOnt.Oid
AND  TOnt.Name	      = 'Bioentry Type Ontology'
AND  SEnt.Tax_Oid     = STax.Oid
AND  STNam.Tax_Oid    = STax.Oid
AND  STNam.Name_Class = 'scientific name'
AND  TEnt.Tax_Oid     = TTax.Oid
AND  TTNam.Tax_Oid    = TTax.Oid
AND  TTNam.Name_Class = 'scientific name'
;

