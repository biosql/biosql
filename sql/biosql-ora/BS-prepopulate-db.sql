--
-- SQL script to prepopulate tables in the SymGENE/BioSQL database as
-- far as it is needed.
--
-- $GNF: projects/gi/symgene/src/DB/BS-prepopulate-db.sql,v 1.7 2003/05/14 07:10:58 hlapp Exp $
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
-- Categories or Namespaces, respectively.
--
-- The following will be created automatically upon inserting their terms.
--    'Relationship Type Ontology'
--    'Bioentry Type Ontology'
--    'Qualifier Type Ontology'
--

-- Alignment Block Types may comprise of HSP, or exon, to name a few
INSERT INTO SGLD_Ontologies (Ont_Name) 
VALUES ('Alignment Block Types');

-- Alignment Types may comprise of Genome Alignment, Protein Alignment, to 
-- name a few
INSERT INTO SGLD_Ontologies (Ont_Name) 
VALUES ('Alignment Types');

--
-- A note about the identifiers I chose: the format essentially follows that
-- of GOBO (namespace:identifier). To simplify future changes and merges with
-- other ontologies that may or may not be or become applicable, I used for
-- the numeric part the same number as SO uses; only the namespace would be
-- different in those cases. Those numbers generally start with a 0 (zero),
-- whereas numbers for the terms I invented myself start with a 1 (one).
--

--
-- Ontology terms: relationship type ontology
--
INSERT INTO SGLD_Terms (Trm_Name, Trm_Identifier, Cat_Name)
VALUES ('EST','REO:0000345','Relationship Type Ontology');
INSERT INTO SGLD_Terms (Trm_Name, Trm_Identifier, Cat_Name)
VALUES ('cluster member','REO:1000001','Relationship Type Ontology');
INSERT INTO SGLD_Terms (Trm_Name, Trm_Identifier, Cat_Name)
VALUES ('splice variant','REO:1000002','Relationship Type Ontology');
INSERT INTO SGLD_Terms (Trm_Name, Trm_Identifier, Cat_Name)
VALUES ('synonym','REO:1000003','Relationship Type Ontology');
INSERT INTO SGLD_Terms (Trm_Name, Trm_Identifier, Cat_Name)
VALUES ('protein','REO:1000004','Relationship Type Ontology');
INSERT INTO SGLD_Terms (Trm_Name, Trm_Identifier, Cat_Name)
VALUES ('ortholog','REO:1000005','Relationship Type Ontology');
INSERT INTO SGLD_Terms (Trm_Name, Trm_Identifier, Cat_Name)
VALUES ('translation','REO:1000006','Relationship Type Ontology');
INSERT INTO SGLD_Terms (Trm_Name, Trm_Identifier, Cat_Name)
VALUES ('expression reporter','REO:1000007','Relationship Type Ontology');
INSERT INTO SGLD_Terms (Trm_Name, Trm_Identifier, Cat_Name)
VALUES ('is-a','REO:1000008','Relationship Type Ontology');

--
-- Ontology terms: bioentry type ontology
--
INSERT INTO SGLD_Terms (Trm_Name, Trm_Identifier, Cat_Name)
VALUES ('gene','BEO:0000007','Bioentry Type Ontology');
INSERT INTO SGLD_Terms (Trm_Name, Trm_Identifier, Cat_Name)
VALUES ('EST','BEO:0000345','Bioentry Type Ontology');
INSERT INTO SGLD_Terms (Trm_Name, Trm_Identifier, Cat_Name)
VALUES ('protein','BEO:0000608','Bioentry Type Ontology');
INSERT INTO SGLD_Terms (Trm_Name, Trm_Identifier, Cat_Name)
VALUES ('transcript','BEO:0000673','Bioentry Type Ontology');
INSERT INTO SGLD_Terms (Trm_Name, Trm_Identifier, Cat_Name)
VALUES ('sequence cluster','BEO:1000001','Bioentry Type Ontology');
INSERT INTO SGLD_Terms (Trm_Name, Trm_Identifier, Cat_Name)
VALUES ('array sequence','BEO:1000002','Bioentry Type Ontology');

--
-- Ontology terms: qualifier type ontology
--
INSERT INTO SGLD_Terms (Trm_Name, Trm_Identifier, Cat_Name)
VALUES ('bioentry name','QUO:1000001','Qualifier Type Ontology');
INSERT INTO SGLD_Terms (Trm_Name, Trm_Identifier, Cat_Name)
VALUES ('genename','QUO:1000002','Qualifier Type Ontology');
INSERT INTO SGLD_Terms (Trm_Name, Trm_Identifier, Cat_Name)
VALUES ('function','QUO:1000003','Qualifier Type Ontology');
INSERT INTO SGLD_Terms (Trm_Name, Trm_Identifier, Cat_Name)
VALUES ('phenotype','QUO:1000004','Qualifier Type Ontology');

--
-- Some warehouse queries and context-index populating procedures exploit
-- is-a associations of terms coming from native annotations of various
-- formats to flexibly determine what to process.
--

-- first pre-create the tags (the uppercase tags are mostly from LocusLink,
-- some others are from UniGene etc)
INSERT INTO SGLD_Terms (Trm_Name, Cat_Name)
VALUES ('PREFERRED_SYMBOL','Annotation Tags');
INSERT INTO SGLD_Terms (Trm_Name, Cat_Name)
VALUES ('ECNUM','Annotation Tags');
INSERT INTO SGLD_Terms (Trm_Name, Cat_Name)
VALUES ('ALIAS_SYMBOL','Annotation Tags');
INSERT INTO SGLD_Terms (Trm_Name, Cat_Name)
VALUES ('gene_name','Annotation Tags');
INSERT INTO SGLD_Terms (Trm_Name, Cat_Name)
VALUES ('EC_number','Annotation Tags');
INSERT INTO SGLD_Terms (Trm_Name, Cat_Name)
VALUES ('OFFICIAL_SYMBOL','Annotation Tags');
INSERT INTO SGLD_Terms (Trm_Name, Cat_Name)
VALUES ('PREFERRED_SYMBOL','Annotation Tags');
INSERT INTO SGLD_Terms (Trm_Name, Cat_Name)
VALUES ('gene_name','Annotation Tags');
INSERT INTO SGLD_Terms (Trm_Name, Cat_Name)
VALUES ('OFFICIAL_SYMBOL','Annotation Tags');
INSERT INTO SGLD_Terms (Trm_Name, Cat_Name)
VALUES ('ALIAS_SYMBOL','Annotation Tags');
INSERT INTO SGLD_Terms (Trm_Name, Cat_Name)
VALUES ('OFFICIAL_GENE_NAME','Annotation Tags');
INSERT INTO SGLD_Terms (Trm_Name, Cat_Name)
VALUES ('PREFERRED_GENE_NAME','Annotation Tags');
INSERT INTO SGLD_Terms (Trm_Name, Cat_Name)
VALUES ('PHENOTYPE','Annotation Tags');

-- second, create the actual associations with the terms used by the warehouse
INSERT INTO SGLD_Term_Assocs (Subj_Trm_Name, Pred_Trm_Name, Trm_Name)
VALUES ('PREFERRED_SYMBOL','is-a','bioentry name');
INSERT INTO SGLD_Term_Assocs (Subj_Trm_Name, Pred_Trm_Name, Obj_Trm_Name)
VALUES ('ECNUM','is-a','bioentry name');
INSERT INTO SGLD_Term_Assocs (Subj_Trm_Name, Pred_Trm_Name, Obj_Trm_Name)
VALUES ('ALIAS_SYMBOL','is-a','bioentry name');
INSERT INTO SGLD_Term_Assocs (Subj_Trm_Name, Pred_Trm_Name, Obj_Trm_Name)
VALUES ('gene_name','is-a','bioentry name');
INSERT INTO SGLD_Term_Assocs (Subj_Trm_Name, Pred_Trm_Name, Obj_Trm_Name)
VALUES ('EC_number','is-a','bioentry name');
INSERT INTO SGLD_Term_Assocs (Subj_Trm_Name, Pred_Trm_Name, Obj_Trm_Name)
VALUES ('OFFICIAL_SYMBOL','is-a','bioentry name');
INSERT INTO SGLD_Term_Assocs (Subj_Trm_Name, Pred_Trm_Name, Obj_Trm_Name)
VALUES ('PREFERRED_SYMBOL','is-a','genename');
INSERT INTO SGLD_Term_Assocs (Subj_Trm_Name, Pred_Trm_Name, Obj_Trm_Name)
VALUES ('gene_name','is-a','genename');
INSERT INTO SGLD_Term_Assocs (Subj_Trm_Name, Pred_Trm_Name, Obj_Trm_Name)
VALUES ('OFFICIAL_SYMBOL','is-a','genename');
INSERT INTO SGLD_Term_Assocs (Subj_Trm_Name, Pred_Trm_Name, Obj_Trm_Name)
VALUES ('ALIAS_SYMBOL','is-a','genename');
INSERT INTO SGLD_Term_Assocs (Subj_Trm_Name, Pred_Trm_Name, Obj_Trm_Name)
VALUES ('OFFICIAL_GENE_NAME','is-a','genename');
INSERT INTO SGLD_Term_Assocs (Subj_Trm_Name, Pred_Trm_Name, Obj_Trm_Name)
VALUES ('PREFERRED_GENE_NAME','is-a','genename');
INSERT INTO SGLD_Term_Assocs (Subj_Trm_Name, Pred_Trm_Name, Obj_Trm_Name)
VALUES ('PHENOTYPE','is-a','phenotype');

--
-- Done
--
PROMPT 
PROMPT ================================================================
PROMPT Dont forget to commit in order to make the insertions permanent.
PROMPT ================================================================
PROMPT



