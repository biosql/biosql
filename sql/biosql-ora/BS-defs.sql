--
-- Common definitions, mostly for SQL*Plus.
--
-- H.Lapp, GNF, 2002.
--
-- $GNF: projects/gi/symgene/src/DB/BS-defs.sql,v 1.5 2003/05/02 02:24:44 hlapp Exp $
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

-- where do the datafiles for the tablespaces go
define datalocation='/u02/app/oracle/oradata/gidev'

-- how do you want to name the table tablespace
define biosql_data=SYMGENE_DATA

-- how do you want to name the index tablespace
define biosql_index=SYMGENE_INDEX

-- how to you want to name the LOB tablespace
define biosql_lob=SYMGENE_LOB

-- what is the name of the role enabling all permissions necessary
-- for schema creation
define schema_creator=CB_MEMBER

-- what shall be name and (initial) pwd of the schema owner
define biosql_owner=sgowner
define biosql_pwd=sgbio

-- the user role (usually read-only, on views) to be created for the schema
define biosql_user=sg_user

-- the upload-permitted role (INSERT permissions for load API views) to be
-- created for the schema
define biosql_loader=sg_loader

-- the admin-permitted role (INSERT, UPDATE, DELETE on most things) to be
-- created for the schema
define biosql_admin=sg_admin

-- the base role you have for users connecting to the database
define base_user=cb_user
