-- $Id$ 
-- BIOSQL ONTOLOGIES MODULE 
-- 
-- relies on core module biosqldb-[dbms].sql 
-- 
-- Copyright O|B|F. You may use, modify, and distribute this code under 
-- the same terms as Perl. See the Perl Artistic License. 
-- 
-- comments to biosql - biosql-l@open-bio.org 
-- 
-- 
-- Migration to InnoDB by Hilmar Lapp <hlapp at gmx.net> 
-- 
-- relationship between controlled vocabulary / ontology term 
-- we use subject/predicate/object but this could also 
-- be thought of as child/relationship-type/parent. 
-- the subject/predicate/object naming is better as we 
-- can think of the graph as composed of statements. 
-- 
-- we also treat the relationshiptypes / predicates as 
-- controlled terms in themselves; this is quite useful 
-- as a lot of systems (eg GO) will soon require 
-- ontologies of relationship types (eg subtle differences 
-- in the partOf relationship) 
-- 
-- this table probably won''t be filled for a while, the core 
-- will just treat ontologies as flat lists of terms 
CREATE TABLE ontology_relationship ( 
	 subject_id INTEGER NOT NULL , 
	 predicate_id INTEGER NOT NULL , 
	 object_id INTEGER NOT NULL , 
	 PRIMARY KEY ( subject_id , predicate_id , object_id ) ) ; 

CREATE INDEX ontrel_predicateid ON ontology_relationship ( predicate_id ); 
CREATE INDEX ontrel_objectid ON ontology_relationship ( object_id ); 
CREATE TABLE ontology_dbxref ( 
	 ontology_term_id INTEGER NOT NULL , 
	 dbxref_id INTEGER NOT NULL , 
	 PRIMARY KEY ( ontology_term_id , dbxref_id ) ) ; 

CREATE INDEX ontdbxref_dbxrefid ON ontology_dbxref ( dbxref_id ); 
--  
-- add foreign key constraints 
-- 
-- ontology_relationship 
ALTER TABLE ontology_relationship ADD CONSTRAINT FKontsubject_ont FOREIGN KEY ( subject_id ) REFERENCES ontology_term ( ontology_term_id ) ON DELETE CASCADE ; 
ALTER TABLE ontology_relationship ADD CONSTRAINT FKontpredicate_ont FOREIGN KEY ( predicate_id ) REFERENCES ontology_term ( ontology_term_id ) ON DELETE CASCADE ; 
ALTER TABLE ontology_relationship ADD CONSTRAINT FKontobject_ont FOREIGN KEY ( object_id ) REFERENCES ontology_term ( ontology_term_id ) ON DELETE CASCADE ; 
-- ontology_dbxref 
ALTER TABLE ontology_dbxref ADD CONSTRAINT FKdbxref_ontdbxref FOREIGN KEY ( dbxref_id ) REFERENCES dbxref ( dbxref_id ) ON DELETE CASCADE ; 
ALTER TABLE ontology_dbxref ADD CONSTRAINT FKontology_ontdbxref FOREIGN KEY ( ontology_term_id ) REFERENCES ontology_term ( ontology_term_id ) ON DELETE CASCADE ; 
