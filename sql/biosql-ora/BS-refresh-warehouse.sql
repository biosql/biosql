--
-- SQL script to refresh the Data Warehouse views for SYMGENE/BioSQL
--
-- $GNF: projects/gi/symgene/src/DB/BS-refresh-warehouse.sql,v 1.8 2003/05/15 23:01:30 hlapp Exp $
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
-- do the refresh
--
BEGIN
	DBMS_MVIEW.refresh(list                 => 'SG_ENT_CHR_MAP',
	                   method               => '?',
	                   push_deferred_rpc    => TRUE,
	                   atomic_refresh       => FALSE);
END;
/

-- exit sqlplus
exit
