-- -*-Sql-*- mode (to keep my emacs happy)
--
-- SQL script to create the triggers enabling the load API for
-- SGLD_Ontology_Terms.
--
--
-- $GNF: projects/gi/symgene/src/DB/load-trgs/Terms.trg,v 1.1 2003/05/23 17:42:28 hlapp Exp $
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
