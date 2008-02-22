--
-- SQL script to create the triggers enabling the load API for
-- SGLD_Ontology_Term_Assocs.
--
--
-- $GNF: projects/gi/symgene/src/DB/load-trgs/Ontology_Term_Assocs.trg,v 1.5 2003/05/02 02:24:46 hlapp Exp $
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
