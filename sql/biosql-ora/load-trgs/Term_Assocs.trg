-- -*-Sql-*- mode (to keep my emacs happy)
--
-- SQL script to create the triggers enabling the load API for
-- SGLD_Ontology_Term_Assocs.
--
--
-- $GNF: projects/gi/symgene/src/DB/load-trgs/Term_Assocs.trg,v 1.1 2003/05/23 17:42:28 hlapp Exp $
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

CREATE OR REPLACE TRIGGER BIR_Term_Assocs
       INSTEAD OF INSERT
       ON SGLD_Term_Assocs
       REFERENCING NEW AS new OLD AS old
       FOR EACH ROW
DECLARE
	pk		SG_Term_Assoc.Oid%TYPE;
	do_DML		INTEGER DEFAULT BSStd.DML_I;
BEGIN
	-- do insert or update (depending on whether it exists or not)
	pk := TrmA.get_oid(
			Ont_Oid		    => :new.Ont_Oid,
			Ont_Name	    => :new.Ont_Name,
			Subj_Trm_Oid        => :new.Subj_Trm_Oid,
			Subj_Trm_Name	    => :new.Subj_Trm_Name,
			Subj_Ont_Oid	    => :new.Subj_Ont_Oid,
			Subj_Ont_Name	    => :new.Subj_Ont_Name,
			Subj_Trm_Identifier => :new.Subj_Trm_Identifier,
			Pred_Trm_Oid        => :new.Pred_Trm_Oid,
			Pred_Trm_Name	    => :new.Pred_Trm_Name,
			Pred_Ont_Oid        => :new.Pred_Ont_Oid,
			Pred_Ont_Name       => :new.Pred_Ont_Name,
			Pred_Trm_Identifier => :new.Pred_Trm_Identifier,
			Obj_Trm_Oid         => :new.Obj_Trm_Oid,
			Obj_Trm_Name	    => :new.Obj_Trm_Name,
			Obj_Ont_Oid	    => :new.Obj_Ont_Oid,
			Obj_Ont_Name	    => :new.Obj_Ont_Name,
			Obj_Trm_Identifier  => :new.Obj_Trm_Identifier,
			do_DML              => do_DML);
END;
/
