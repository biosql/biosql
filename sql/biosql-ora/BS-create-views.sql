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
CREATE OR REPLACE VIEW SG_Taxa
AS
SELECT
	Tax.Oid			Tax_Oid,
	Tax.Name		Tax_Name,
	Tax.Common_Name		Tax_Common_Name,
	Tax.NCBI_Taxon_ID	Tax_NCBI_Taxon_ID,
	Tax.Node_Type		Tax_Node_Type,
	Tax.Tax_Oid		TaxP_Oid
FROM SG_Taxon Tax
;

--
-- Ontology terms; this is leaf-oriented
--
CREATE OR REPLACE VIEW SG_Ontology_Terms
AS
SELECT
	Ont.Name		Ont_Name,
	Ont.Identifier		Ont_Identifier,
	Ont.Definition		Ont_Definition,
	TOnt.Name		Type_Ont_Name,
	TOnt.Identifier		Type_Ont_Identifier,
	SOnt.Name		Src_Ont_Name,
	SOnt.Identifier		Src_Ont_Identifier,
	SOnt.Oid		Src_Ont_Oid,
	TOnt.Oid		Type_Ont_Oid,
	Ont.Oid			Ont_Oid
FROM SG_Ontology_Term SOnt, SG_Ontology_Term TOnt, SG_Ontology_Term Ont,
     SG_Ontology_Term_Assoc OntA
WHERE
     SOnt.Oid = OntA.Src_Ont_Oid
AND  TOnt.Oid = OntA.Type_Ont_Oid
AND  Ont.Oid  = OntA.Tgt_Ont_Oid
;

