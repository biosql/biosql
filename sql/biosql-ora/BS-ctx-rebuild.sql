--
-- SQL script to rebuild the context indexes.
--
--
-- $GNF: projects/gi/symgene/src/DB/BS-ctx-rebuild.sql,v 1.3 2002/11/26 10:11:26 hlapp Exp $
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

ALTER INDEX EntDesc_Context REBUILD ONLINE 
PARAMETERS('REPLACE datastore ent_desc_ud lexer ent_desc_lx filter ctxsys.null_filter section group tagsections')
;

ALTER INDEX RefDoc_Context REBUILD ONLINE ;

exit
