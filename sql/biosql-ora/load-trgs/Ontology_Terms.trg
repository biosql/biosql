--
-- SQL script to create the triggers enabling the load API for
-- SGLD_Ontology_Terms.
--
--
-- $GNF: projects/gi/symgene/src/DB/load-trgs/Ontology_Terms.trg,v 1.5 2003/05/02 02:24:46 hlapp Exp $
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
