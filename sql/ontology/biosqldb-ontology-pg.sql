--- BIOSQL ONTOLOGIES MODULE 
--- 
--- relies on core module biosqldb-[dbms].sql 
--- relationship between controlled vocabulary / ontology term 
--- we use subject/predicate/object but this could also 
--- be thought of as child/relationship-type/parent. 
--- the subject/predicate/object naming is better as we 
--- can think of the graph as composed of statements. 
--- 
--- we also treat the relationshiptypes / predicates as 
--- controlled terms in themselves; this is quite useful 
--- as a lot of systems (eg GO) will soon require 
--- ontologies of relationship types (eg subtle differences 
--- in the partOf relationship) 
--- 
--- this table probably won't be filled for a while, the core 
--- will just treat ontologies as flat lists of terms 
CREATE SEQUENCE ontology_relationship_pk_seq;
CREATE TABLE ontology_relationship ( 
	 ontology_relationship_id integer primary key default (nextval ( 'ontology_relationship_pk_seq' )) , 
	 subject_id int NOT NULL , 
	 predicate_id int NOT NULL , 
	 object_id int NOT NULL , 
	 FOREIGN KEY ( subject_id ) REFERENCES ontology_term ( ontology_term_id ) , 
	 FOREIGN KEY ( predicate_id ) REFERENCES ontology_term ( ontology_term_id ) , 
	 FOREIGN KEY ( object_id ) REFERENCES ontology_term ( ontology_term_id ) ); 

CREATE SEQUENCE ontology_dbxref_pk_seq;
CREATE TABLE ontology_dbxref ( 
	 ontology_term_id integer primary key default (nextval ( 'ontology_dbxref_pk_seq' )) , 
	 FOREIGN KEY ( ontology_term_id ) REFERENCES ontology_term ( ontology_term_id ) , 
	 dbxref_id int NOT NULL , 
	 FOREIGN KEY ( dbxref_id ) REFERENCES dbxref ( dbxref_id ) ); 

