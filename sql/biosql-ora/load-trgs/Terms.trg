-- -*-Sql-*- mode (to keep my emacs happy)
--
-- SQL script to create the triggers enabling the load API for
-- SGLD_Ontology_Terms.
--
--
-- $GNF: projects/gi/symgene/src/DB/load-trgs/Terms.trg,v 1.1 2003/05/23 17:42:28 hlapp Exp $
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

CREATE OR REPLACE TRIGGER BIR_Terms
       INSTEAD OF INSERT
       ON SGLD_Terms
       REFERENCING NEW AS new OLD AS old
       FOR EACH ROW
DECLARE
	pk		SG_Term.Oid%TYPE DEFAULT :new.Trm_Oid;
	do_DML		INTEGER DEFAULT BSStd.DML_UI;
BEGIN
	-- do insert or update (depending on whether it exists or not)
	pk := Trm.get_oid(
			Trm_Oid            => pk,
			Trm_Name	   => :new.Trm_Name,
			Trm_Identifier	   => :new.Trm_Identifier,
			Trm_Definition	   => :new.Trm_Definition,
			Trm_Is_Obsolete	   => :new.Trm_Is_Obsolete,
			Ont_Oid        	   => :new.Ont_Oid,
			Ont_Name	   => :new.Ont_Name,
			do_DML             => do_DML);
END;
/
