-- -*-Sql-*- mode (to keep my emacs happy)
--
-- API Package body for general or special purpose SymGene functions and
-- procedures.
--
-- $GNF: projects/gi/symgene/src/DB/PkgAPI/SGAPI.pkb,v 1.4 2003/05/21 09:33:18 hlapp Exp $
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

CURSOR Ancestor_c (Ent_Oid IN SG_Bioentry.Oid%TYPE)
IS
	SELECT Subj_Ent_Oid, Level
	FROM SG_Bioentry_Assoc
	START WITH Obj_Ent_Oid = Ent_Oid
	CONNECT BY PRIOR Subj_Ent_Oid = Obj_Ent_Oid
;

FUNCTION Platonic_Ent(Ent_Oid IN SG_Bioentry.Oid%TYPE)
RETURN SG_Bioentry.Oid%TYPE
IS
	-- default is there is no parent
	Parent_Oid SG_Bioentry.Oid%TYPE DEFAULT Ent_Oid;
	lvl        INTEGER DEFAULT 0;
BEGIN
	-- if there is a hierarchy of parents, get the last (highest) one
	FOR parent_r IN Ancestor_c (Ent_Oid)
	LOOP
		IF parent_r.Level > lvl THEN 
		   Parent_Oid := parent_r.Subj_Ent_Oid;
		   lvl := parent_r.Level;
		END IF;
	END LOOP;
	RETURN Parent_Oid;
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
