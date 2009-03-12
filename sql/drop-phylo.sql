-- 
-- Copyright 2007-2008 Hilmar Lapp
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
-- This is a rather trivial script for quickly dropping all the biosql
-- phylodb tables (not tables or sequences of the core schema), and,
-- if you're on PostgreSQL, also the respective sequences. Indexes,
-- constraints, and rules will be dropped automatically along with the
-- tables.
--
-- Even though if you run this through mysql you'll see errors thrown by
-- the DROP SEQUENCE statements, mysql will proceed nonetheless and so
-- you can use this under mysql just as well.
--
-- NOTE: THIS SCRIPT WILL DROP THE PHYLODB PART OF YOUR SCHEMA, AND
-- THEREFORE ALL DATA STORED IN THOSE TABLES SCHEMA WILL BE
-- LOST. THERE IS NO WAY TO UNDO THIS EXCEPT IF YOU RESTORE A
-- BACKUP. Rollback will NOT help (except on PostgreSQL). Make
-- absolutely sure that this is exactly what you want BEFORE you run
-- this script.
--
DROP TABLE tree CASCADE ;
DROP TABLE tree_root CASCADE ;
DROP TABLE tree_dbxref CASCADE ;
DROP TABLE tree_qualifier_value CASCADE ;
DROP TABLE node CASCADE ;
DROP TABLE node_dbxref CASCADE ;
DROP TABLE node_taxon CASCADE ;
DROP TABLE node_bioentry CASCADE ;
DROP TABLE edge CASCADE ;
DROP TABLE node_path CASCADE ;
DROP TABLE node_qualifier_value CASCADE ;
DROP TABLE edge_qualifier_value CASCADE ;
DROP SEQUENCE tree_pk_seq;
DROP SEQUENCE tree_root_pk_seq;
DROP SEQUENCE node_pk_seq;
DROP SEQUENCE node_taxon_pk_seq;
DROP SEQUENCE node_bioentry_pk_seq;
DROP SEQUENCE edge_pk_seq;
