--
-- SQL script to create the triggers enabling the load API for
-- SGLD_Ontology_Terms.
--
--
-- $Id: Ontology_Terms.trg,v 1.1.1.2 2003-01-29 08:54:36 lapp Exp $
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

CREATE OR REPLACE TRIGGER BIR_Ontology_Terms
       INSTEAD OF INSERT
       ON SGLD_Ontology_Terms
       REFERENCING NEW AS new OLD AS old
       FOR EACH ROW
DECLARE
	pk		SG_Ontology_Term.Oid%TYPE DEFAULT :new.Ont_Oid;
	do_DML		INTEGER DEFAULT BSStd.DML_UI;
BEGIN
	-- do insert or update (depending on whether it exists or not)
	pk := Ont.get_oid(
			Ont_Oid            => pk,
			Ont_Name	   => :new.Ont_Name,
			Ont_Identifier	   => :new.Ont_Identifier,
			Ont_Definition	   => :new.Ont_Definition,
			Ont_Cat_Oid        => :new.Cat_Oid,
			Cat_Name	   => :new.Cat_Name,
			Cat_Identifier	   => :new.Cat_Identifier,
			do_DML             => do_DML);
END;
/
