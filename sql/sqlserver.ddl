-- $Id: sqlserver.ddl,v 1.1 2002-09-23 07:22:26 lapp Exp $
--
-- Submitted by Robin Emig <Robin.Emig@maxygen.com>
-- (c) Robin Emig, 2002.
--
-- You can use, modify, and distribute this code under the same terms as Perl.  
-- See the Perl Artistic License for the terms of the license under which
-- you may use this code.
CREATE TABLE %SCHEMA_NAME%."biodatabase"
(
"biodatabase_id" int identity,
"name" varchar(40) NOT NULL,
  CONSTRAINT "PRIMARY" PRIMARY KEY ("biodatabase_id")
)


CREATE TABLE %SCHEMA_NAME%."bioentry"
(
"bioentry_id" int identity,
"biodatabase_id" int identity,
"display_id" varchar(40) NOT NULL,
"accession" varchar(40) NOT NULL,
"entry_version" int identity,
"division" char(3) NOT NULL,
  CONSTRAINT "PRIMARY1" PRIMARY KEY ("bioentry_id")
)


CREATE TABLE %SCHEMA_NAME%."bioentry_direct_links"
(
"bio_dblink_id" int identity,
"source_bioentry_id" int identity,
"dbxref_id" int identity,
  CONSTRAINT "PRIMARY2" PRIMARY KEY ("bio_dblink_id")
)


CREATE TABLE %SCHEMA_NAME%."bioentry_qualifier_value"
(
"bioentry_id" int identity,
"ontology_term_id" int identity,
"qualifier_value" text
)


CREATE TABLE %SCHEMA_NAME%."bioentry_reference"
(
"bioentry_id" int identity,
"reference_id" int identity,
"reference_start" int identity,
"reference_end" int identity,
"reference_rank" int identity,
  CONSTRAINT "PRIMARY3" PRIMARY KEY ("bioentry_id", "reference_id", "reference_rank")
)


CREATE TABLE %SCHEMA_NAME%."bioentry_taxa"
(
"bioentry_id" int identity,
"taxa_id" int identity,
  CONSTRAINT "PRIMARY4" PRIMARY KEY ("bioentry_id")
)


CREATE TABLE %SCHEMA_NAME%."biosequence"
(
"biosequence_id" int identity,
"bioentry_id" int identity,
"seq_version" int identity,
"seq_length" int identity,
"biosequence_str" text,
"molecule" varchar(10),
  CONSTRAINT "PRIMARY5" PRIMARY KEY ("biosequence_id")
)


CREATE TABLE %SCHEMA_NAME%."cache_corba_support"
(
"biodatabase_id" int identity,
"http_ior_string" varchar(255),
"direct_ior_string" varchar(255),
  CONSTRAINT "PRIMARY6" PRIMARY KEY ("biodatabase_id")
)


CREATE TABLE %SCHEMA_NAME%."comment"
(
"comment_id" int identity,
"bioentry_id" int identity,
"comment_text" text NOT NULL,
"comment_rank" int identity,
  CONSTRAINT "PRIMARY7" PRIMARY KEY ("comment_id")
)


CREATE TABLE %SCHEMA_NAME%."dbxref"
(
"dbxref_id" int identity,
"dbname" varchar(40) NOT NULL,
"accession" varchar(40) NOT NULL,
  CONSTRAINT "PRIMARY8" PRIMARY KEY ("dbxref_id")
)


CREATE TABLE %SCHEMA_NAME%."dbxref_qualifier_value"
(
"dbxref_qualifier_value_id" int identity,
"dbxref_id" int identity,
"ontology_term_id" int identity,
"qualifier_value" text,
  CONSTRAINT "PRIMARY9" PRIMARY KEY ("dbxref_qualifier_value_id")
)


CREATE TABLE %SCHEMA_NAME%."location_qualifier_value"
(
"seqfeature_location_id" int identity,
"ontology_term_id" int identity,
"qualifier_value" char(255) NOT NULL,
"qualifier_int_value" int identity
)


CREATE TABLE %SCHEMA_NAME%."ontology_term"
(
"ontology_term_id" int identity,
"term_name" varchar(255),
"term_definition" text,
  CONSTRAINT "PRIMARY10" PRIMARY KEY ("ontology_term_id")
)


CREATE TABLE %SCHEMA_NAME%."reference"
(
"reference_id" int identity,
"reference_location" text NOT NULL,
"reference_title" text,
"reference_authors" text NOT NULL,
"reference_medline" int identity,
  CONSTRAINT "PRIMARY11" PRIMARY KEY ("reference_id")
)


CREATE TABLE %SCHEMA_NAME%."remote_seqfeature_name"
(
"seqfeature_location_id" int identity,
"accession" varchar(40) NOT NULL,
"version" int identity,
  CONSTRAINT "PRIMARY12" PRIMARY KEY ("seqfeature_location_id")
)


CREATE TABLE %SCHEMA_NAME%."seqfeature"
(
"seqfeature_id" int identity,
"bioentry_id" int identity,
"seqfeature_key_id" int identity,
"seqfeature_source_id" int identity,
"seqfeature_rank" int identity,
  CONSTRAINT "PRIMARY13" PRIMARY KEY ("seqfeature_id")
)


CREATE TABLE %SCHEMA_NAME%."seqfeature_location"
(
"seqfeature_location_id" int identity,
"seqfeature_id" int identity,
"seq_start" int identity,
"seq_end" int identity,
"seq_strand" int identity,
"location_rank" int identity,
  CONSTRAINT "PRIMARY14" PRIMARY KEY ("seqfeature_location_id")
)


CREATE TABLE %SCHEMA_NAME%."seqfeature_qualifier_value"
(
"seqfeature_id" int identity,
"ontology_term_id" int identity,
"qualifier_rank" int identity,
"qualifier_value" text NOT NULL,
  CONSTRAINT "PRIMARY15" PRIMARY KEY ("seqfeature_id", "ontology_term_id", "qualifier_rank")
)


CREATE TABLE %SCHEMA_NAME%."seqfeature_relationship"
(
"seqfeature_relationship_id" int identity,
"parent_seqfeature_id" int identity,
"child_seqfeature_id" int identity,
"relationship_type_id" int identity,
"relationship_rank" int identity,
  CONSTRAINT "PRIMARY16" PRIMARY KEY ("seqfeature_relationship_id")
)


CREATE TABLE %SCHEMA_NAME%."seqfeature_source"
(
"seqfeature_source_id" int identity,
"source_name" varchar(255) NOT NULL,
  CONSTRAINT "PRIMARY17" PRIMARY KEY ("seqfeature_source_id")
)


CREATE TABLE %SCHEMA_NAME%."taxa"
(
"taxa_id" int identity,
"full_lineage" text NOT NULL,
"common_name" varchar(255) NOT NULL,
"ncbi_taxa_id" int identity,
  CONSTRAINT "PRIMARY18" PRIMARY KEY ("taxa_id")
)


