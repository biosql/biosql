-- 
-- Copyright 2009 Hilmar Lapp
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
-- phylodata tables (not tables or sequences of the core schema, or of
-- other modules), and, if you're on PostgreSQL, also the respective
-- sequences. Indexes, constraints, and rules will be dropped
-- automatically along with the tables.
--
-- Even though if you run this through mysql you'll see errors thrown by
-- the DROP SEQUENCE statements, mysql will proceed nonetheless and so
-- you can use this under mysql just as well.
--
-- NOTE: THIS SCRIPT WILL DROP THE PHYLODATA PART OF YOUR SCHEMA, AND
-- THEREFORE ALL DATA STORED IN THOSE TABLES SCHEMA WILL BE
-- LOST. THERE IS NO WAY TO UNDO THIS EXCEPT IF YOU RESTORE A
-- BACKUP. Rollback will NOT help (except on PostgreSQL). Make
-- absolutely sure that this is exactly what you want BEFORE you run
-- this script.
--
DROP TABLE charmatrix CASCADE ;
DROP TABLE charmatrix_qualifier_value CASCADE ;
DROP TABLE charmatrix_dbxref CASCADE ;
DROP TABLE charmatrix_tree CASCADE ;
DROP TABLE mchar CASCADE ;
DROP TABLE mchar_qualifier_value CASCADE ;
DROP TABLE mchar_dbxref CASCADE ;
DROP TABLE charstate CASCADE ;
DROP TABLE charstate_qualifier_value CASCADE ;
DROP TABLE charstate_dbxref CASCADE ;
DROP TABLE otu CASCADE ;
DROP TABLE otu_dbxref CASCADE ;
DROP TABLE otu_qualifier_value CASCADE ;
DROP TABLE node_otu CASCADE ;
DROP TABLE charmatrix_mchar CASCADE ;
DROP TABLE charmatrix_otu CASCADE ;
DROP TABLE charmatrix_relationship CASCADE ;
DROP TABLE mcell CASCADE ;
DROP TABLE mcell_charstate CASCADE ;
DROP TABLE mcell_qualifier_value CASCADE ;
DROP SEQUENCE charmatrix_pk_seq ;
DROP SEQUENCE mchar_pk_seq ;
DROP SEQUENCE charstate_pk_seq ;
DROP SEQUENCE otu_pk_seq ;
DROP SEQUENCE mcell_pk_seq ;
