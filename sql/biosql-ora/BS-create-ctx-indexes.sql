--
-- SQL script to create the context indexes.
--
--
-- $GNF: projects/gi/symgene/src/DB/BS-create-ctx-indexes.sql,v 1.4 2002/11/26 10:07:17 hlapp Exp $
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

DROP INDEX EntDesc_Context FORCE ;

CREATE INDEX EntDesc_Context ON SG_Bioentry
(
	Description
)
INDEXTYPE IS CTXSYS.CONTEXT
PARAMETERS (
	   'datastore ent_desc_ud lexer ent_desc_lx filter ctxsys.null_filter section group tagsections'
)
;

DROP INDEX RefDoc_Context FORCE ;

CREATE INDEX RefDoc_Context ON SG_Reference
(
	Title
)
INDEXTYPE IS CTXSYS.CONTEXT
PARAMETERS (
	   'datastore ctxsys.ref_doc_md lexer ent_desc_lx filter ctxsys.null_filter section group refsections'
)
;

exit
