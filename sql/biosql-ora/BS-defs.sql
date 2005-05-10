--
-- Common definitions, mostly for SQL*Plus.
--
-- H.Lapp, GNF, 2002.
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

-- set the line size wide enough so that generated scripts won't have
-- erroneous line breaks in them (comment this out if your personal
-- default setting is wider already)
set lines 200

-- where do the datafiles for the tablespaces go
define datalocation='/u02/app/oracle/oradata/gidev'

-- how do you want to name the table tablespace
define biosql_data=BIOSQL_DATA

-- how do you want to name the index tablespace
define biosql_index=BIOSQL_INDEX

-- how to you want to name the LOB tablespace
define biosql_lob=BIOSQL_LOB

-- what shall be name and (initial) pwd of the schema owner
define biosql_owner=sgowner
define biosql_pwd=XXXX

-- the base role you have for users connecting to the database 
--
-- users newly created will get this role granted to them;
-- alternatively, at least the following permissions need to be
-- granted to all users who want to open a connection and access
-- biosql:
-- GRANT CREATE SESSION, CREATE SYNONYM TO <username here>;
define base_user=CB_USER

-- what is the name of the role enabling all permissions necessary
-- for schema creation
--
-- the owner of the biosql schema will need to have this role, or
-- alternatively be granted all of the following permissions
-- directly:
-- GRANT CREATE PROCEDURE,
--       CREATE ROLE,
--       CREATE SEQUENCE,
--       CREATE SESSION,
--       CREATE SYNONYM,
--       CREATE TRIGGER,
--       CREATE TYPE,
--       CREATE VIEW,
--       CREATE TABLE,
--       CREATE PUBLIC SYNONYM,
--       DROP PUBLIC SYNONYM
-- TO &biosql_owner
-- ;
define schema_creator=CB_MEMBER

-- the user role (usually read-only, on views) to be created for the schema
define biosql_user=sg_user

-- the read/write role, e.g., for uploads (INSERT, UPDATE, DELETE
-- permissions for API views, SELECT on sequences) to be created for
-- the schema
define biosql_loader=sg_loader

-- the admin-permitted role (additional DELETE on SGLD% API views) to
-- be created for the schema - note: most Biosql-oriented users will
-- never use this and so shouldn't worry much about it
define biosql_admin=sg_admin
