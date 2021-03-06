--
-- SQL script to create the trigger(s) enabling the load API for
-- SGLD_Seqfeature_Assocs.
--
-- Scaffold auto-generated by gen-api.pl.
--
--
-- $Id: Seqfeature_Assocs.trg,v 1.1.1.2 2003-01-29 08:54:36 lapp Exp $
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

CREATE OR REPLACE TRIGGER BIUR_Seqfeature_Assocs
       INSTEAD OF INSERT OR UPDATE
       ON SGLD_Seqfeature_Assocs
       REFERENCING NEW AS new OLD AS old
       FOR EACH ROW
DECLARE
	pk		SG_SEQFEATURE_ASSOC.SRC_FEA_OID##FIXME##TGT_FEA_OID##FIXME##ONT_OID%TYPE DEFAULT :new.FeaA_Oid;
	do_DML		INTEGER DEFAULT BSStd.DML_NO;
BEGIN
	IF INSERTING THEN
		do_DML := BSStd.DML_I;
	ELSE
		-- this is an update
		do_DML := BSStd.DML_UI;
	END IF;
	-- do insert or update (depending on whether it exists or not)
	pk := FeaA.get_oid(
			FeaA_SRC_FEA_OID##FIXME##TGT_FEA_OID##FIXME##ONT_OID => pk,
		        FeaA_TGT_FEA_OID => TGT_FEA_OID_,
			FeaA_ONT_OID => ONT_OID_,
			FeaA_RANK => FeaA_RANK,
			do_DML             => do_DML);
END;
/
