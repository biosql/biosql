--
-- SQL script to create the SYMGENE/BioSQL schema owner.
--
-- $Id$
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

--
-- Definitions for tablespaces and role.
-- 

@BS-defs.sql

--
-- The owner of the schema.
--
CREATE USER &biosql_owner
       PROFILE "DEFAULT" IDENTIFIED BY "&biosql_pwd"
       DEFAULT TABLESPACE &biosql_data
       TEMPORARY TABLESPACE "TEMP" ACCOUNT UNLOCK
       QUOTA UNLIMITED ON &biosql_data
       QUOTA UNLIMITED ON &biosql_index
       QUOTA UNLIMITED ON &biosql_lob
;
GRANT &schema_creator TO &biosql_owner;



