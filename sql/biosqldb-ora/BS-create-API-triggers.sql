--
-- SQL script to create the triggers enabling the load API.
--
--
-- $GNF: projects/gi/symgene/src/DB/BS-create-API-triggers.sql,v 1.8 2003/05/23 17:42:27 hlapp Exp $
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

prompt Trigger for SGLD_Terms API

@load-trgs/Terms.trg

prompt Trigger for SGLD_Term_Assocs API

@load-trgs/Term_Assocs.trg

prompt Trigger for SGLD_Bioentries API

@load-trgs/Bioentries.trg

prompt Trigger for SGLD_Bioentry_Qualifier_Assocs API

@load-trgs/Bioentry_Qualifier_Assocs.trg

prompt Trigger for SGLD_Chr_Map_Assocs API

@load-trgs/Chr_Map_Assocs.trg

