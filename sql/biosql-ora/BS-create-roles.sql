--
-- SQL script to create the CLONETRAILS roles.
--
-- $GNF: projects/gi/symgene/src/DB/BS-create-roles.sql,v 1.4 2003/05/02 02:24:44 hlapp Exp $
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

@BS-defs-local

--
-- Create the base role for this schema. Because of the grants, SYSTEM
-- has to do that.
--
CREATE ROLE &biosql_user;
GRANT &base_user to &biosql_user;

--
-- Loader (submittor) permission set.
-- 
CREATE ROLE &biosql_loader;
GRANT &biosql_user TO &biosql_loader;

--
-- Admin permission set.
-- 
CREATE ROLE &biosql_admin;
GRANT &biosql_loader TO &biosql_admin;

