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
       	subject_id	INT(10) UNSIGNED NOT NULL,
       	predicate_id    INT(10) UNSIGNED NOT NULL,
       	object_id       INT(10) UNSIGNED NOT NULL,
	PRIMARY KEY (subject_id,predicate_id,object_id)
) TYPE=INNODB;

CREATE INDEX ontrel_predicateid ON ontology_relationship(predicate_id);
CREATE INDEX ontrel_objectid ON ontology_relationship(object_id);

-- the infamous transitive closure table on ontology term relationships
-- this is a warehouse approach - you will need to update this regularly
--
-- the triple of (subject, predicate, object) is the same as for ontology
-- relationships, with the exception of predicate being the least common
-- denominator of relationships types visited in the path
--
-- See the GO database or Chado schema for other (and possibly better
-- documented) implementations of the transitive closure table approach.
CREATE TABLE ontology_path (
       	subject_id	INT(10) UNSIGNED NOT NULL,
       	predicate_id    INT(10) UNSIGNED NOT NULL,
       	object_id       INT(10) UNSIGNED NOT NULL,
	distance	INT(10) UNSIGNED,
	PRIMARY KEY (subject_id,predicate_id,object_id)
) TYPE=INNODB;

CREATE INDEX ontpath_predicateid ON ontology_path(predicate_id);
CREATE INDEX ontpath_objectid ON ontology_path(object_id);

-- 
-- add foreign key constraints
--

-- ontology_relationship

ALTER TABLE ontology_relationship ADD CONSTRAINT FKontsubject_ont
	FOREIGN KEY (subject_id) REFERENCES ontology_term(ontology_term_id)
	ON DELETE CASCADE;
ALTER TABLE ontology_relationship ADD CONSTRAINT FKontpredicate_ont
       	FOREIGN KEY (predicate_id) REFERENCES ontology_term(ontology_term_id)
	ON DELETE CASCADE;
ALTER TABLE ontology_relationship ADD CONSTRAINT FKontobject_ont
       	FOREIGN KEY (object_id) REFERENCES ontology_term(ontology_term_id)
	ON DELETE CASCADE;

-- ontology_path

ALTER TABLE ontology_path ADD CONSTRAINT FKontsubject_ontpath
	FOREIGN KEY (subject_id) REFERENCES ontology_term(ontology_term_id)
	ON DELETE CASCADE;
ALTER TABLE ontology_path ADD CONSTRAINT FKontpredicate_ontpath
       	FOREIGN KEY (predicate_id) REFERENCES ontology_term(ontology_term_id)
	ON DELETE CASCADE;
ALTER TABLE ontology_path ADD CONSTRAINT FKontobject_ontpath
       	FOREIGN KEY (object_id) REFERENCES ontology_term(ontology_term_id)
	ON DELETE CASCADE;


