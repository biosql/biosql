-- $Id$ 
--
-- This is a rather trivial script for quickly dropping all the biosql
-- tables, and, if you're on PostgreSQL, also the sequences. Indexes,
-- constraints, and rules will be dropped automatically along with the
-- tables.
--
-- Although if you run this through mysql you'll see errors thrown by
-- the DROP SEQUENCE statements, mysql will proceed nonetheless and so
-- you can use this under mysql just as well.
--
-- NOTE: THIS SCRIPT WILL DROP YOUR ENTIRE SCHEMA, AND THEREFORE ALL
-- DATA STORED IN THE SCHEMA WILL BE LOST. THERE IS NO WAY TO UNDO
-- THIS EXCEPT IF YOU RESTORE A BACKUP. Rollback will NOT help. Make
-- absolutely sure that this is exactly what you want BEFORE you run
-- this script.
--
-- (c) Hilmar Lapp, hlapp at gnf.org, 2004.
-- (c) GNF, Genomics Institute of the Novartis Research Foundation, 2004.
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


