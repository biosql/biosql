--
-- SQL script to create the preferences used for context indexes.
--
--
-- $GNF: projects/gi/symgene/src/DB/BS-create-ctx-prefs.sql,v 1.3 2002/11/26 10:07:17 hlapp Exp $
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

BEGIN
	--
	-- datastore parameter
	--
	-- ent_desc user datastore
	CTX_DDL.drop_preference('ent_desc_ud');
	CTX_DDL.create_preference('ent_desc_ud', 'USER_DATASTORE');
	CTX_DDL.set_attribute('ent_desc_ud', 
			      'procedure', 'sg_wctx_ent_desc');
        CTX_DDL.set_attribute('ent_desc_ud', 'output_type', 'clob');
	--
	-- lexer parameter
	--
	CTX_DDL.drop_preference('ent_desc_lx');
	CTX_DDL.create_preference('ent_desc_lx', 'BASIC_LEXER');
	CTX_DDL.set_attribute('ent_desc_lx', 'skipjoins', '-');
	--CTX_DDL.set_attribute('ent_desc_lx', 'index_stems', 1);
	--CTX_DDL.set_attribute('ent_desc_lx', 'index_text', 'YES');
	--
	-- section group parameter
	CTX_DDL.drop_section_group('tagsections');
	CTX_DDL.create_section_group('tagsections','AUTO_SECTION_GROUP');
	-- for multi-col sg_reference:
	--CTX_DDL.drop_section_group('refsections');
	CTX_DDL.create_section_group('refsections','BASIC_SECTION_GROUP');
	CTX_DDL.add_field_section('refsections', 'authors', 'authors', TRUE);
	CTX_DDL.add_field_section('refsections', 'title', 'title', TRUE);
	CTX_DDL.add_field_section('refsections', 'location', 'location', TRUE);
END;
/