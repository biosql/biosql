-- Package body for standard functions used throughout other packages.
--
--
-- $Id: BSStd.pkb,v 1.1.1.1 2002-08-13 19:51:10 lapp Exp $
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

END BSStd;
/

