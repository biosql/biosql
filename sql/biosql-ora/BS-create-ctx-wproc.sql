--
-- SQL script to create the wrapper procedures used for context indexes.
--
-- NOTE: You need to execute this as user CTXSYS.
--
-- $GNF: projects/gi/symgene/src/DB/BS-create-ctx-wproc.sql,v 1.4 2003/05/15 23:01:30 hlapp Exp $
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
-- get settings
--
@BS-defs-local

--
-- create wrapper procedures
--
CREATE OR REPLACE PROCEDURE SG_WCtx_Ent_Desc(rid IN ROWID, 
					     doc IN OUT NOCOPY CLOB)
IS
BEGIN
	&biosql_owner..Ctx_Ent_Desc(rid, doc);
END;
/

--
-- grant execute to prospective schema owner
--
set timing off
set heading off
set termout off
set feedback off

spool _proc_grants.sql

SELECT 'GRANT EXECUTE ON ' || object_name || ' TO &biosql_owner ;'
FROM user_objects
WHERE object_type = 'PROCEDURE' AND object_name like 'SG_WCTX_%'
AND SUBSTR(object_name,3,1) = '_'
;

spool off

set timing on
set heading on
set termout on
set feedback on

start _proc_grants

--
-- multi-column datastore preferences can only be created by CTXSYS, which
-- is why we do this here
--
BEGIN
	-- ref_doc multi-col datastore
	CTX_DDL.drop_preference('ref_doc_md');
	CTX_DDL.create_preference('ref_doc_md', 'MULTI_COLUMN_DATASTORE');
	CTX_DDL.set_attribute('ref_doc_md', 'columns',
			      'authors "authors", title "title", location "location"');
END;
/
