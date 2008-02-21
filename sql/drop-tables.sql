-- $Id$ 
--
-- Copyright 2004 GNF, Genomics Institute of the Novartis Research Foundation
-- Copyright 2004-2008 Hilmar Lapp
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
-- tables, and, if you're on PostgreSQL, also the sequences. Indexes,
-- constraints, and rules will be dropped automatically along with the
-- tables.
--
-- Even though if you run this through mysql you'll see errors thrown by
-- the DROP SEQUENCE statements, mysql will proceed nonetheless and so
-- you can use this under mysql just as well.
--
-- NOTE: THIS SCRIPT WILL DROP YOUR ENTIRE SCHEMA, AND THEREFORE ALL
-- DATA STORED IN THE SCHEMA WILL BE LOST. THERE IS NO WAY TO UNDO
-- THIS EXCEPT IF YOU RESTORE A BACKUP. Rollback will NOT help (except
-- on PostgreSQL). Make absolutely sure that this is exactly what you
-- want BEFORE you run this script.
--
DROP TABLE biodatabase CASCADE ;
DROP TABLE taxon CASCADE ;
DROP TABLE taxon_name CASCADE ;
DROP TABLE ontology CASCADE ;
DROP TABLE term CASCADE ;
DROP TABLE term_dbxref CASCADE ;
DROP TABLE term_relationship CASCADE ;
DROP TABLE term_relationship_term CASCADE ;
DROP TABLE term_path CASCADE ;
DROP TABLE term_synonym CASCADE ;
DROP TABLE bioentry CASCADE ;
DROP TABLE bioentry_relationship CASCADE ;
DROP TABLE bioentry_path CASCADE ;
DROP TABLE biosequence CASCADE ;
DROP TABLE dbxref CASCADE ;
DROP TABLE dbxref_qualifier_value CASCADE ;
DROP TABLE bioentry_dbxref CASCADE ; 
DROP TABLE reference CASCADE ;
DROP TABLE bioentry_reference CASCADE ;
DROP TABLE comment CASCADE ;
DROP TABLE bioentry_qualifier_value CASCADE ;
DROP TABLE seqfeature CASCADE ;
DROP TABLE seqfeature_dbxref CASCADE ;
DROP TABLE seqfeature_relationship CASCADE ;
DROP TABLE seqfeature_path CASCADE ;
DROP TABLE seqfeature_qualifier_value CASCADE ;
DROP TABLE location CASCADE ;
DROP TABLE location_qualifier_value CASCADE ;
DROP SEQUENCE biodatabase_pk_seq ;
DROP SEQUENCE taxon_pk_seq ;
DROP SEQUENCE ontology_pk_seq ;
DROP SEQUENCE term_pk_seq ;
DROP SEQUENCE term_relationship_pk_seq ;
DROP SEQUENCE term_path_pk_seq ;
DROP SEQUENCE bioentry_pk_seq ;
DROP SEQUENCE bioentry_relationship_pk_seq ;
DROP SEQUENCE dbxref_pk_seq ;
DROP SEQUENCE reference_pk_seq ;
DROP SEQUENCE comment_pk_seq ;
DROP SEQUENCE seqfeature_pk_seq ;
DROP SEQUENCE seqfeature_relationship_pk_seq ;
DROP SEQUENCE location_pk_seq ;


