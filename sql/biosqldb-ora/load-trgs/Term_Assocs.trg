-- -*-Sql-*- mode (to keep my emacs happy)
--
-- SQL script to create the triggers enabling the load API for
-- SGLD_Ontology_Term_Assocs.
--
--
-- $GNF: projects/gi/symgene/src/DB/load-trgs/Term_Assocs.trg,v 1.1 2003/05/23 17:42:28 hlapp Exp $
--

--
-- Copyright 2002-2003 Genomics Institute of the Novartis Research Foundation
-- Copyright 2002-2008 Hilmar Lapp
-- 
--  This file is part of BioSQL.
--
--  BioSQL is free software: you can redistribute it and/or modify it
--  under the terms of the GNU Lesser General Public License as
--  published by the Free Software Foundation, either version 3 of the
--  License, or (at your option) any later version.
--
--  BioSQL is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU Lesser General Public License for more details.
--
--  You should have received a copy of the GNU Lesser General Public License
--  along with BioSQL. If not, see <http://www.gnu.org/licenses/>.
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
