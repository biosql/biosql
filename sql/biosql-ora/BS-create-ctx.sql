--
-- SQL script to create the context indexes.
--
--
-- $GNF: projects/gi/symgene/src/DB/BS-create-ctx.sql,v 1.1 2002/11/17 05:53:13 hlapp Exp $
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

-- load settings
@BS-defs

--
-- create the procedure(s)
--
@BS-create-ctx-proc

--
-- create the wrapper procedures in CTXSYS' schema
-- 
connect ctxsys/&ctxpwd
@BS-create-ctx-wproc
connect &biosql_owner/&biosql_pwd

--
-- create the preferences
--
@BS-create-ctx-prefs

--
-- and finally, create the indexes
--
-- note: you may want to comment this out - on full content it takes a while
-- and on no content it doesn't help, since the index doesn't sync
-- automatically
@BS-create-ctx-indexes
