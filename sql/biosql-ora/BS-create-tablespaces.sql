--
-- SQL script to create the database files (tablespaces) for the schema.
--
-- H.Lapp, GNF, 2002.
--
-- $GNF: projects/gi/symgene/src/DB/BS-create-tablespaces.sql,v 1.4 2003/05/02 02:24:44 hlapp Exp $
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

@BS-defs.sql-local

--
-- Create the tablespaces.
--

CREATE TABLESPACE &biosql_data
       DATAFILE '&datalocation/&biosql_data..dbf' SIZE 32M REUSE
       DEFAULT STORAGE (INITIAL 1024K NEXT 16M 
		        MINEXTENTS 1 MAXEXTENTS UNLIMITED PCTINCREASE 0)
;
ALTER DATABASE DATAFILE '&datalocation/&biosql_data..dbf'
      AUTOEXTEND ON NEXT 128M MAXSIZE  UNLIMITED
;

CREATE TABLESPACE &biosql_index
       DATAFILE '&datalocation/&biosql_index..dbf' SIZE 128M REUSE
       DEFAULT STORAGE (INITIAL 2048K NEXT 24M
		        MINEXTENTS 1 MAXEXTENTS UNLIMITED PCTINCREASE 0)
;
ALTER DATABASE DATAFILE '&datalocation/&biosql_index..dbf'
      AUTOEXTEND ON NEXT 192M MAXSIZE  UNLIMITED
;


CREATE TABLESPACE &biosql_lob
       DATAFILE '&datalocation/&biosql_lob..dbf' SIZE 48M REUSE
       DEFAULT STORAGE (INITIAL 8M NEXT 48M
		        MINEXTENTS 1 MAXEXTENTS UNLIMITED PCTINCREASE 0)
;
ALTER DATABASE DATAFILE '&datalocation/&biosql_lob..dbf'
      AUTOEXTEND ON NEXT 96M MAXSIZE  UNLIMITED
;

