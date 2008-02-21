-- -*-Sql-*- mode (to keep my emacs happy)
--
-- Package body for standard functions used throughout other packages.
--
--
-- $GNF: projects/gi/symgene/src/DB/PkgAPI/BSStd.pkb,v 1.4 2003/06/25 00:12:33 hlapp Exp $
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

CREATE OR REPLACE
PACKAGE BODY BSStd IS

FUNCTION translate_bool(bool_var IN VARCHAR2)
RETURN VARCHAR2
IS
	ret_val VARCHAR(6) DEFAULT bool_var;
BEGIN
	IF ret_val IS NOT NULL THEN
		ret_val := UPPER(SUBSTR(ret_val,1,1));
		IF ret_val = 'Y' THEN
		   ret_val := 'X';
		ELSE
		   ret_val := 'N';
		END IF;
	END IF;
	RETURN ret_val;
END;

PROCEDURE modify_constraints(
	  		tabname	  IN All_Constraints.Table_Name%TYPE,
			action	  IN VARCHAR2,
			pat 	  IN VARCHAR2 DEFAULT NULL,
	       		cons_type IN All_Constraints.Constraint_Type%TYPE DEFAULT 'R')
IS
	CURSOR constr_c (tabname IN All_Constraints.Table_Name%TYPE,
	       		 cons_type IN All_Constraints.Constraint_Type%TYPE,
	       		 pat IN VARCHAR2 DEFAULT NULL)
	IS
		SELECT Constraint_Name FROM All_Constraints
		WHERE Table_Name = tabname AND Constraint_Type = cons_type
		AND (
				Constraint_Name LIKE pat
			OR	pat IS NULL
		)
	;
	ddl_stmt VARCHAR2(256) := 
		'ALTER TABLE ' || tabname || ' MODIFY CONSTRAINT ';
BEGIN
	FOR crow IN constr_c (tabname, cons_type, pat) LOOP
		EXECUTE IMMEDIATE 
			ddl_stmt || crow.Constraint_Name || ' ' || action;
	END LOOP;
END;

END BSStd;
/

