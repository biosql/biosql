--
-- Script for migrating a BioSQL database from version 1.0.0 to 1.0.1.
--
-- You DO NOT need this if you installed BioSQL v1.0.1 or later. This
-- script will not check the installed version - if you run it on a
-- newer version than 1.0.0 you may revert changes made in later
-- versions.
--
-- It is strongly recommended to backup your database first.
--
-- comments to biosql - biosql-l@open-bio.org 
--
-- ========================================================================
--
-- Copyright 2008 Hilmar Lapp 
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
-- ========================================================================
--

-- widen the column width constraint on dbxref.accession
ALTER TABLE SG_DBXRef MODIFY (Accession VARCHAR2(128));

-- correspondingly, do the same for bioentry.accession
ALTER TABLE SG_Bioentry MODIFY (Accession VARCHAR2(128));
