--
-- SQL script to prepopulate tables in the SymGENE/BioSQL database as
-- far as it is needed.
--
-- $Id$
--

--
-- (c) Hilmar Lapp, hlapp at gnf.org, 2002.
-- (c) GNF, Genomics Institute of the Novartis Research Foundation, 2002.
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

--
-- Ontology terms: relationship types
--
INSERT INTO SGLD_Ontology_Terms (Ont_Name, Ont_Definition)
VALUES ('Relationship type', 'Relationship types referenced by association tables');

INSERT INTO SGLD_Ontology_Terms (Ont_Name, Ont_Definition)
VALUES ('is-a', 'instance-of or specialization-of relationship type');

INSERT INTO SGLD_Ontology_Terms (Ont_Name, Ont_Definition)
VALUES ('part-of', 'part-of relationship type');

INSERT INTO SGLD_Ontology_Terms (Ont_Name, Ont_Definition)
VALUES ('synonym', 'The associated entries are synonyms for each other.');

-- add associations
INSERT INTO SGLD_Ontology_Term_Assocs (Src_Ont_Name, Type_Ont_Name, Ont_Name)
VALUES ('is-a', 'is-a', 'Relationship type');

INSERT INTO SGLD_Ontology_Term_Assocs (Src_Ont_Name, Type_Ont_Name, Ont_Name)
VALUES ('part-of', 'is-a', 'Relationship type');

INSERT INTO SGLD_Ontology_Term_Assocs (Src_Ont_Name, Type_Ont_Name, Ont_Name)
VALUES ('synonym', 'is-a', 'Relationship type');

--
-- General qualifier names
--
INSERT INTO SGLD_Ontology_Terms (Ont_Name, Ont_Definition)
VALUES ('Tag_Ontology', 'tag names or general qualifier names');

INSERT INTO SGLD_Ontology_Terms (Ont_Name, Ont_Definition)
VALUES ('Bioentry qualifier', 'qualifier name for a bioentry');

INSERT INTO SGLD_Ontology_Terms (Ont_Name, Ont_Definition)
VALUES ('Celera qualifier', 'qualifiers used by Celera Genomics databases');

INSERT INTO SGLD_Ontology_Terms (Ont_Name, Ont_Definition)
VALUES ('tag', 'the tag name of a tag/value pair');

INSERT INTO SGLD_Ontology_Terms (Ont_Name, Ont_Definition)
VALUES ('type', 'the type of a specific entity');

INSERT INTO SGLD_Ontology_Terms (Ont_Name, Ont_Definition)
VALUES ('comment', 'a (short but arbitrary) comment for a specific entity');

-- associations:
INSERT INTO SGLD_Ontology_Term_Assocs (Ont_Name, Type_Ont_Name, Src_Ont_Name)
VALUES ('Bioentry qualifier', 'part-of', 'Tag_Ontology');

INSERT INTO SGLD_Ontology_Term_Assocs (Ont_Name, Type_Ont_Name, Src_Ont_Name)
VALUES ('Celera qualifier', 'is-a', 'Tag_Ontology');

INSERT INTO SGLD_Ontology_Term_Assocs (Ont_Name, Type_Ont_Name, Src_Ont_Name)
VALUES ('tag', 'is-a', 'Tag_Ontology');

INSERT INTO SGLD_Ontology_Term_Assocs (Ont_Name, Type_Ont_Name, Src_Ont_Name)
VALUES ('type', 'is-a', 'tag');

INSERT INTO SGLD_Ontology_Term_Assocs (Ont_Name, Type_Ont_Name, Src_Ont_Name)
VALUES ('comment', 'is-a', 'tag');

INSERT INTO SGLD_Ontology_Term_Assocs (Ont_Name, Type_Ont_Name, Src_Ont_Name)
VALUES ('type', 'is-a', 'Celera qualifier');

INSERT INTO SGLD_Ontology_Term_Assocs (Ont_Name, Type_Ont_Name, Src_Ont_Name)
VALUES ('comment', 'is-a', 'Celera qualifier');

--
-- Ontology terms: bioentry qualifiers
--
INSERT INTO SGLD_Ontology_Terms (Ont_Name, Ont_Definition)
VALUES ('scaffold_class', 'Celera Genome Assembly scaffold class');

-- add associations
INSERT INTO SGLD_Ontology_Term_Assocs (Ont_Name, Type_Ont_Name, Src_Ont_Name)
VALUES ('scaffold_class', 'is-a', 'Celera qualifier');

INSERT INTO SGLD_Ontology_Term_Assocs (Ont_Name, Type_Ont_Name, Src_Ont_Name)
VALUES ('scaffold_class', 'is-a', 'Bioentry qualifier');

