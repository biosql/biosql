-- $Id: oracle.ddl,v 1.1 2002-09-23 07:22:26 lapp Exp $
--
-- Submitted by Robin Emig <Robin.Emig@maxygen.com>
-- (c) Robin Emig, 2002.
-- 
-- You can use, modify, and distribute this code under the same terms as Perl.
-- See the Perl Artistic License for the terms of the license under which
-- you may use this code.
CREATE TABLE %SCHEMA_NAME%."biodatabase"
(
"biodatabase_id" NUMBER(10) NOT NULL,
"name" VARCHAR2(40) NOT NULL,
  CONSTRAINT "PRIMARY" PRIMARY KEY ("biodatabase_id")
)


CREATE TABLE %SCHEMA_NAME%."bioentry"
(
"bioentry_id" NUMBER(10) NOT NULL,
"biodatabase_id" NUMBER(10) NOT NULL,
"display_id" VARCHAR2(40) NOT NULL,
"accession" VARCHAR2(40) NOT NULL,
"entry_version" NUMBER(10),
"division" CHAR(3) NOT NULL,
  CONSTRAINT "PRIMARY1" PRIMARY KEY ("bioentry_id")
)


CREATE TABLE %SCHEMA_NAME%."bioentry_direct_links"
(
"bio_dblink_id" NUMBER(10) NOT NULL,
"source_bioentry_id" NUMBER(10) NOT NULL,
"dbxref_id" NUMBER(10) NOT NULL,
  CONSTRAINT "PRIMARY2" PRIMARY KEY ("bio_dblink_id")
)


CREATE TABLE %SCHEMA_NAME%."bioentry_qualifier_value"
(
"bioentry_id" NUMBER(10) NOT NULL,
"ontology_term_id" NUMBER(10) NOT NULL,
"qualifier_value" LONG
)


CREATE TABLE %SCHEMA_NAME%."bioentry_reference"
(
"bioentry_id" NUMBER(10) NOT NULL,
"reference_id" NUMBER(10) NOT NULL,
"reference_start" NUMBER(10),
"reference_end" NUMBER(10),
"reference_rank" NUMBER(5) NOT NULL,
  CONSTRAINT "PRIMARY3" PRIMARY KEY ("bioentry_id", "reference_id", "reference_rank")
)


CREATE TABLE %SCHEMA_NAME%."bioentry_taxa"
(
"bioentry_id" NUMBER(10) NOT NULL,
"taxa_id" NUMBER(10) NOT NULL,
  CONSTRAINT "PRIMARY4" PRIMARY KEY ("bioentry_id")
)


CREATE TABLE %SCHEMA_NAME%."biosequence"
(
"biosequence_id" NUMBER(10) NOT NULL,
"bioentry_id" NUMBER(10) NOT NULL,
"seq_version" NUMBER(6),
"seq_length" NUMBER(10),
"biosequence_str" LONG,
"molecule" VARCHAR2(10),
  CONSTRAINT "PRIMARY5" PRIMARY KEY ("biosequence_id")
)


CREATE TABLE %SCHEMA_NAME%."cache_corba_support"
(
"biodatabase_id" NUMBER(10) NOT NULL,
"http_ior_string" VARCHAR2(255),
"direct_ior_string" VARCHAR2(255),
  CONSTRAINT "PRIMARY6" PRIMARY KEY ("biodatabase_id")
)


CREATE TABLE %SCHEMA_NAME%."comment"
(
"comment_id" NUMBER(10) NOT NULL,
"bioentry_id" NUMBER(10) NOT NULL,
"comment_text" LONG NOT NULL,
"comment_rank" NUMBER(5) NOT NULL,
  CONSTRAINT "PRIMARY7" PRIMARY KEY ("comment_id")
)


CREATE TABLE %SCHEMA_NAME%."dbxref"
(
"dbxref_id" NUMBER(10) NOT NULL,
"dbname" VARCHAR2(40) NOT NULL,
"accession" VARCHAR2(40) NOT NULL,
  CONSTRAINT "PRIMARY8" PRIMARY KEY ("dbxref_id")
)


CREATE TABLE %SCHEMA_NAME%."dbxref_qualifier_value"
(
"dbxref_qualifier_value_id" NUMBER(10) NOT NULL,
"dbxref_id" NUMBER(10) NOT NULL,
"ontology_term_id" NUMBER(10) NOT NULL,
"qualifier_value" LONG,
  CONSTRAINT "PRIMARY9" PRIMARY KEY ("dbxref_qualifier_value_id")
)


CREATE TABLE %SCHEMA_NAME%."location_qualifier_value"
(
"seqfeature_location_id" NUMBER(10) NOT NULL,
"ontology_term_id" NUMBER(10) NOT NULL,
"qualifier_value" CHAR(255) NOT NULL,
"qualifier_int_value" NUMBER(10)
)


CREATE TABLE %SCHEMA_NAME%."ontology_term"
(
"ontology_term_id" NUMBER(10) NOT NULL,
"term_name" VARCHAR2(255),
"term_definition" LONG,
  CONSTRAINT "PRIMARY10" PRIMARY KEY ("ontology_term_id")
)


CREATE TABLE %SCHEMA_NAME%."reference"
(
"reference_id" NUMBER(10) NOT NULL,
"reference_location" LONG NOT NULL,
"reference_title" LONG,
"reference_authors" LONG NOT NULL,
"reference_medline" NUMBER(10),
  CONSTRAINT "PRIMARY11" PRIMARY KEY ("reference_id")
)


CREATE TABLE %SCHEMA_NAME%."remote_seqfeature_name"
(
"seqfeature_location_id" NUMBER(10) NOT NULL,
"accession" VARCHAR2(40) NOT NULL,
"version" NUMBER(10) NOT NULL,
  CONSTRAINT "PRIMARY12" PRIMARY KEY ("seqfeature_location_id")
)


CREATE TABLE %SCHEMA_NAME%."seqfeature"
(
"seqfeature_id" NUMBER(10) NOT NULL,
"bioentry_id" NUMBER(10) NOT NULL,
"seqfeature_key_id" NUMBER(10),
"seqfeature_source_id" NUMBER(10),
"seqfeature_rank" NUMBER(5),
  CONSTRAINT "PRIMARY13" PRIMARY KEY ("seqfeature_id")
)


CREATE TABLE %SCHEMA_NAME%."seqfeature_location"
(
"seqfeature_location_id" NUMBER(10) NOT NULL,
"seqfeature_id" NUMBER(10) NOT NULL,
"seq_start" NUMBER(10),
"seq_end" NUMBER(10),
"seq_strand" NUMBER(1) NOT NULL,
"location_rank" NUMBER(5) NOT NULL,
  CONSTRAINT "PRIMARY14" PRIMARY KEY ("seqfeature_location_id")
)


CREATE TABLE %SCHEMA_NAME%."seqfeature_qualifier_value"
(
"seqfeature_id" NUMBER(10) NOT NULL,
"ontology_term_id" NUMBER(10) NOT NULL,
"qualifier_rank" NUMBER(5) NOT NULL,
"qualifier_value" LONG NOT NULL,
  CONSTRAINT "PRIMARY15" PRIMARY KEY ("seqfeature_id", "ontology_term_id", "qualifier_rank")
)


CREATE TABLE %SCHEMA_NAME%."seqfeature_relationship"
(
"seqfeature_relationship_id" NUMBER(10) NOT NULL,
"parent_seqfeature_id" NUMBER(10) NOT NULL,
"child_seqfeature_id" NUMBER(10) NOT NULL,
"relationship_type_id" NUMBER(10) NOT NULL,
"relationship_rank" NUMBER(5),
  CONSTRAINT "PRIMARY16" PRIMARY KEY ("seqfeature_relationship_id")
)


CREATE TABLE %SCHEMA_NAME%."seqfeature_source"
(
"seqfeature_source_id" NUMBER(10) NOT NULL,
"source_name" VARCHAR2(255) NOT NULL,
  CONSTRAINT "PRIMARY17" PRIMARY KEY ("seqfeature_source_id")
)


CREATE TABLE %SCHEMA_NAME%."taxa"
(
"taxa_id" NUMBER(10) NOT NULL,
"full_lineage" LONG NOT NULL,
"common_name" VARCHAR2(255) NOT NULL,
"ncbi_taxa_id" NUMBER(10),
  CONSTRAINT "PRIMARY18" PRIMARY KEY ("taxa_id")
)


