--
-- SQL script to create the triggers enabling the load API for
-- SGLD_Ontology_Term_Assocs.
--
--
-- $GNF: projects/gi/symgene/src/DB/load-trgs/Ontology_Term_Assocs.trg,v 1.5 2003/05/02 02:24:46 hlapp Exp $
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

CREATE OR REPLACE TRIGGER BIR_Ontology_Term_Assocs
       INSTEAD OF INSERT
       ON SGLD_Ontology_Term_Assocs
       REFERENCING NEW AS new OLD AS old
       FOR EACH ROW
DECLARE
	pk		INTEGER;
	do_DML		INTEGER DEFAULT BSStd.DML_I;
BEGIN
	-- do insert or update (depending on whether it exists or not)
	pk := OntA.get_oid(
			Src_Ont_Oid         => :new.Src_Ont_Oid,
			Src_Ont_Name	    => :new.Src_Ont_Name,
			Src_Cat_Oid	    => :new.Src_Cat_Oid,
			Src_Ont_Identifier  => :new.Src_Ont_Identifier,
			Type_Ont_Oid        => :new.Type_Ont_Oid,
			Type_Ont_Name	    => :new.Type_Ont_Name,
			Type_Cat_Oid        => :new.Type_Cat_Oid,
			Type_Ont_Identifier => :new.Type_Ont_Identifier,
			Tgt_Ont_Oid         => :new.Ont_Oid,
			Tgt_Ont_Name	    => :new.Ont_Name,
			Tgt_Cat_Oid	    => :new.Ont_Cat_Oid,
			Tgt_Ont_Identifier  => :new.Ont_Identifier,
			do_DML              => do_DML);
END;
/
