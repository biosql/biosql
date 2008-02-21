--
-- SQL script to create the preferences used for context indexes.
--
--
-- $GNF: projects/gi/symgene/src/DB/BS-create-ctx-prefs.sql,v 1.4 2003/05/15 23:01:30 hlapp Exp $
--

--
-- Copyright 2002-2003 Genomics Institute of the Novartis Research Foundation
-- Copyright 2002-2008 Hilmar Lapp
-- 
--  This file is part of BioSQL.
--
--  BioSQL is free software: you can redistribute it and/or modify it
--  under the terms of the GNU Lesser General Public License as
--  published by the Free Software Foundation, either version 3 of the
--  License, or (at your option) any later version.
--
--  BioSQL is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU Lesser General Public License for more details.
--
--  You should have received a copy of the GNU Lesser General Public License
--  along with BioSQL. If not, see <http://www.gnu.org/licenses/>.
--

BEGIN
	--
	-- datastore parameter
	--
	-- ent_desc user datastore
	--CTX_DDL.drop_preference('ent_desc_ud');
	CTX_DDL.create_preference('ent_desc_ud', 'USER_DATASTORE');
	CTX_DDL.set_attribute('ent_desc_ud', 
			      'procedure', 'sg_wctx_ent_desc');
        CTX_DDL.set_attribute('ent_desc_ud', 'output_type', 'clob');
	--
	-- lexer parameter
	--
	--CTX_DDL.drop_preference('ent_desc_lx');
	CTX_DDL.create_preference('ent_desc_lx', 'BASIC_LEXER');
	CTX_DDL.set_attribute('ent_desc_lx', 'skipjoins', '-');
	--CTX_DDL.set_attribute('ent_desc_lx', 'index_stems', 1);
	--CTX_DDL.set_attribute('ent_desc_lx', 'index_text', 'YES');
	--
	-- section group parameter
	--CTX_DDL.drop_section_group('tagsections');
	CTX_DDL.create_section_group('tagsections','AUTO_SECTION_GROUP');
	--
	-- for multi-col sg_reference:
	--CTX_DDL.drop_section_group('refsections');
	CTX_DDL.create_section_group('refsections','BASIC_SECTION_GROUP');
	CTX_DDL.add_field_section('refsections', 'authors', 'authors', TRUE);
	CTX_DDL.add_field_section('refsections', 'title', 'title', TRUE);
	CTX_DDL.add_field_section('refsections', 'location', 'location', TRUE);
END;
/