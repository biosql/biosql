-- -*-Sql-*- mode (to keep my emacs happy)
--
-- API Package body for general or special purpose SymGene functions and
-- procedures.
--
-- $GNF: projects/gi/symgene/src/DB/PkgAPI/SGAPI.pkb,v 1.5 2003/06/11 10:03:20 hlapp Exp $
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

CREATE OR REPLACE
PACKAGE BODY SGAPI IS

FUNCTION Platonic_Ent(Ent_Oid IN SG_Bioentry.Oid%TYPE)
RETURN SG_Bioentry.Oid%TYPE
IS
BEGIN
	RETURN EntA.Platonic_Ent(Ent_Oid);
END;

FUNCTION Ent_Descendants(
			Ent_Oid		IN SG_Bioentry.Oid%TYPE,
		 	Trm_Oid		IN SG_Term.Oid%TYPE DEFAULT NULL,
			Trm_Name	IN SG_Term.Name%TYPE DEFAULT NULL,
			Trm_Identifier IN SG_Term.Identifier%TYPE DEFAULT NULL,
			Ont_Oid		IN SG_Ontology.Oid%TYPE DEFAULT NULL,
			Ont_Name	IN SG_Ontology.Name%TYPE DEFAULT NULL)
RETURN Oid_List_t
IS
BEGIN
	RETURN EntA.Ent_Descendants(
			Ent_Oid		=> Ent_Oid,
		 	Trm_Oid		=> Trm_Oid,
			Trm_Name	=> Trm_Name,
			Trm_Identifier  => Trm_Identifier,
			Ont_Oid		=> Ont_Oid,
			Ont_Name	=> Ont_Name);
END;

PROCEDURE delete_mapping(
		Asm_Name	IN SG_Biodatabase.Name%TYPE,
		DB_Name		IN SG_Biodatabase.Name%TYPE DEFAULT NULL,
		FSrc_Name	IN SG_Term.Name%TYPE DEFAULT NULL)
IS
BEGIN
	ChrEntA.delete_mapping(Asm_Name  => Asm_Name,
			       DB_Name   => DB_Name,
			       FSrc_Name => FSrc_Name);
END;


END SGAPI;
/
