# BIOSQL ONTOLOGIES MODULE
#
# relies on core module biosqldb-[dbms].sql

# relationship between controlled vocabulary / ontology term
# we use subject/predicate/object but this could also
# be thought of as child/relationship-type/parent.
# the subject/predicate/object naming is better as we
# can think of the graph as composed of statements.
#
# we also treat the relationshiptypes / predicates as
# controlled terms in themselves; this is quite useful
# as a lot of systems (eg GO) will soon require
# ontologies of relationship types (eg subtle differences
# in the partOf relationship)
#
# this table probably won''t be filled for a while, the core
# will just treat ontologies as flat lists of terms

CREATE TABLE ontology_relationship (
       ontology_relationship_id int(10) unsigned NOT NULL PRIMARY KEY auto_increment,
       subject_id               int(10) unsigned NOT NULL,
       predicate_id             int(10) unsigned NOT NULL,
       object_id                int(10) unsigned NOT NULL,
       FOREIGN KEY (subject_id) REFERENCES ontology_term(ontology_term_id),
       FOREIGN KEY (predicate_id) REFERENCES ontology_term(ontology_term_id),
       FOREIGN KEY (object_id) REFERENCES ontology_term(ontology_term_id),
       UNIQUE (subject_id,predicate_id,object_id)
);

CREATE INDEX ontrel_predicateid ON ontology_relationship(predicate_id);
CREATE INDEX ontrel_objectid ON ontology_relationship(object_id);

CREATE TABLE ontology_dbxref (
       ontology_term_id int(10) unsigned NOT NULL,
       dbxref_id                int(10) unsigned NOT NULL,
       FOREIGN KEY (ontology_term_id) REFERENCES ontology_term(ontology_term_id),
       FOREIGN KEY (dbxref_id) REFERENCES dbxref(dbxref_id),
       PRIMARY KEY (ontology_term_id,dbxref_id)
);

CREATE INDEX ontdbxref_dbxrefid ON ontology_dbxref(dbxref_id);
