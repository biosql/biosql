-- -*-Sql-*- mode (to keep my emacs happy)
--
-- Package body for standard functions used throughout other packages.
--
--
-- $GNF: projects/gi/symgene/src/DB/PkgAPI/BSStd.pkb,v 1.4 2003/06/25 00:12:33 hlapp Exp $
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

