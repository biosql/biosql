--
-- SQL script to create the context indexes.
--
--
-- $GNF: projects/gi/symgene/src/DB/BS-create-ctx.sql,v 1.3 2003/05/15 23:01:30 hlapp Exp $
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

-- load settings
@BS-defs-local

--
-- create the procedure(s)
--
@BS-create-ctx-proc

--
-- create the wrapper procedures in CTXSYS' schema
-- 
connect ctxsys/&ctxpwd
@BS-create-ctx-wproc
connect &biosql_owner/&biosql_pwd

--
-- create the preferences
--
@BS-create-ctx-prefs

--
-- and finally, create the indexes
--
-- note: you may want to comment this out - on full content it takes a while
-- and on no content it doesn't help, since the index doesn't sync
-- automatically
--@BS-create-ctx-indexes
