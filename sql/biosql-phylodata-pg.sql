-- $Id$
--
-- Copyright 2009 Hilmar Lapp.
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
-- Schema extension on top of the BioSQL core schema for representing
-- phylogenetic data matrices.
--
-- This was developed independently but is very similar to the
-- phylogeny module in Chado (the GMOD common relational model).
--
-- Authors: Hilmar Lapp, hlapp at gmx.net
--
-- comments to biosql - biosql-l@open-bio.org

-- the character matrix
CREATE SEQUENCE charmatrix_pk_seq;
CREATE TABLE charmatrix (
       charmatrix_id INTEGER DEFAULT nextval('charmatrix_pk_seq') NOT NULL,
       name VARCHAR(32) NOT NULL,
       identifier VARCHAR(32),
       biodatabase_id INTEGER NOT NULL
       , PRIMARY KEY (charmatrix_id)
       , CONSTRAINT charmatrix_c1 UNIQUE (name, biodatabase_id)
);

COMMENT ON TABLE charmatrix IS 'A character matrix is the collection of characters, OTUs, and character state values that form a unit of analysis.';

COMMENT ON COLUMN charmatrix.name IS 'The name of the character matrix, in essence a label.';

COMMENT ON COLUMN charmatrix.identifier IS 'The identifier of the character matrix, if there is one.';

COMMENT ON COLUMN charmatrix.biodatabase_id IS 'The namespace of the character matrix. If the concept of namespace (often a collection name) encapsulating several matrices does not apply, one may assign a default namespace (such as "biosql"), or create one named the same as the data matrix.';

-- qualifier/value pairs (metadata) for character matrices
CREATE TABLE charmatrix_qualifier_value (
       charmatrix_id INTEGER NOT NULL,
       term_id INTEGER NOT NULL,
       value TEXT,
       rank INTEGER NOT NULL DEFAULT 0
       , UNIQUE (charmatrix_id, term_id, rank)
);

COMMENT ON TABLE charmatrix_qualifier_value IS 'Character matrix metadata as attribute/value pairs. Attribute names are from a controlled vocabulary (or ontology).';

COMMENT ON COLUMN charmatrix_qualifier_value.charmatrix_id IS 'The character matrix with which the metadata is being associated.';

COMMENT ON COLUMN charmatrix_qualifier_value.term_id IS 'The name of the metadate element as a term from a controlled vocabulary (or ontology).';

COMMENT ON COLUMN charmatrix_qualifier_value.value IS 'The value of the metadata element.';

COMMENT ON COLUMN charmatrix_qualifier_value.rank IS 'The index of the metadata value if there is more than one value for the same metadata element. If there is only one value, this may be left at the default of zero.';

-- dbxrefs, such as identifiers, for character matrices
CREATE TABLE charmatrix_dbxref (
       charmatrix_id INTEGER NOT NULL,
       dbxref_id INTEGER NOT NULL,
       term_id INTEGER NOT NULL
       , PRIMARY KEY (charmatrix_id, dbxref_id, term_id)
);

CREATE INDEX charmatrix_dbxref_i1 ON charmatrix_dbxref (dbxref_id);

COMMENT ON TABLE charmatrix_dbxref IS 'Secondary identifiers and other database cross-references for character matrices. There can only be one dbxref of a specific type for a character matrix.';

COMMENT ON COLUMN charmatrix_dbxref.charmatrix_id IS 'The character matrix to which the database corss-reference is being assigned.';

COMMENT ON COLUMN charmatrix_dbxref.dbxref_id IS 'The database cross-reference being assigned to the character matrix.';

COMMENT ON COLUMN charmatrix_dbxref.term_id IS 'The type of the database cross-reference as a controlled vocabulary or ontology term. The type of a tree accession should be ''primary identifier''.';

-- matrix data characters
CREATE SEQUENCE mchar_pk_seq;
CREATE TABLE mchar (
       mchar_id INTEGER DEFAULT nextval('mchar_pk_seq') NOT NULL,
       label VARCHAR(255),
       description TEXT
       , PRIMARY KEY (node_id)
-- CONFIG: you might like to enforce uniqueness of a node's label within a tree,
-- though keep in mind that data providers often violate this constraint
--       , CONSTRAINT mchar_c1 UNIQUE (label,mchar_id)
);

-- CONFIG: if you decided on the unique key constraint on character
-- label within a matrix, you won't need the index on label, so
-- comment it out for efficiency.
CREATE INDEX mchar_i1 ON node (label);

COMMENT ON TABLE mchar IS 'A character in a character data matrix.';

COMMENT ON COLUMN mchar.label IS 'The label of the character.';

CREATE SEQUENCE charstate_pk_seq;
CREATE TABLE charstate (
       mcoding_id INTEGER DEFAULT nextval('charstate_pk_seq') NOT NULL,
       label VARCHAR(255),
       description TEXT,
       mchar_id INTEGER NOT NULL
       , PRIMARY KEY (mcoding_id)
       , CONSTRAINT charstate_c1 UNIQUE (mchar_id,label)
);

CREATE INDEX charstate_id ON charstate (label);

-- dbxrefs, such as identifiers, for characters of a data matrix
CREATE TABLE mchar_dbxref (
       mchar_id INTEGER NOT NULL,
       dbxref_id INTEGER NOT NULL,
       term_id INTEGER NOT NULL
       , PRIMARY KEY (mchar_id, dbxref_id, term_id)
);

CREATE INDEX mchar_dbxref_i1 ON mchar_dbxref (dbxref_id);

COMMENT ON TABLE mchar_dbxref IS 'Identifiers and other database cross-references for characters of data matrices. There can only be one dbxref of a specific type for a character.';

COMMENT ON COLUMN mchar_dbxref.mchar_id IS 'The character to which the database cross-reference is being assigned.';

COMMENT ON COLUMN mchar_dbxref.dbxref_id IS 'The database cross-reference being assigned to the character.';

COMMENT ON COLUMN mchar_dbxref.term_id IS 'The type of the database cross-reference as a controlled vocabulary or ontology term. The type of a node identifier should be ''primary identifier''.';

-- OTUs (rows of a character data matrix)
CREATE SEQUENCE otu_pk_seq;
CREATE TABLE otu (
       otu_id INTEGER DEFAULT nextval('otu_pk_seq') NOT NULL,
       label VARCHAR(255)
       , PRIMARY KEY (otu_id)
);

COMMENT ON TABLE otu IS 'An OTU is an Operational Taxonomic Unit, the row in a phylogenetic data matrix.';

COMMENT ON COLUMN otu.label IS 'The label (or name) of an OTU.';

CREATE TABLE node_otu (
       node_id INTEGER NOT NULL,
       otu_id INTEGER NOT NULL,
       rank INTEGER NOT NULL DEFAULT 0
       , PRIMARY KEY (node_id, otu_id)
);

CREATE INDEX node_otu_i1 ON node_otu (otu_id);

CREATE SEQUENCE mpartition_pk_seq;
CREATE TABLE mpartition (
       mpartition_id INTEGER DEFAULT nextval('mpartition_pk_seq') NOT NULL,
       name VARCHAR(255),
       charmatrix_id INTEGER NOT NULL,
       rank INTEGER NOT NULL DEFAULT 0
       , PRIMARY KEY (mpartition_id)
       , CONSTRAINT mpartition_c1 UNIQUE (name,charmatrix_id,rank)
);

CREATE INDEX mpartition_i1 ON mpartition (charmatrix_id);

-- associating characters with character matrix partitions
CREATE TABLE mpartition_mchar (
       mpartition_id INTEGER NOT NULL,
       mchar_id INTEGER NOT NULL,
       rank INTEGER NOT NULL DEFAULT 0
       , PRIMARY KEY (mpartition_id,mchar_id,rank)
);

CREATE INDEX mpartition_mchar_i1 ON mpartition_mchar (mchar_id);

-- associating characters with character matrix partitions
CREATE TABLE mpartition_otu (
       mpartition_id INTEGER NOT NULL,
       otu_id INTEGER NOT NULL,
       rank INTEGER NOT NULL DEFAULT 0
       , PRIMARY KEY (mpartition_id,otu_id,rank)
);

CREATE INDEX mpartition_otu_i1 ON mpartition_otu (otu_id);

CREATE SEQUENCE mcell_pk_seq;
CREATE TABLE mcell (
       mcell_id INTEGER DEFAULT nextval('mcell_pk_seq') NOT NULL,
       mchar_id INTEGER NOT NULL,
       otu_id INTEGER NOT NULL,
       charmatrix_id INTEGER NOT NULL
       , PRIMARY KEY (mcell_id)
       , CONSTRAINT mcell_c1 UNIQUE (mchar_id,otu_id,charmatrix_id)
);

CREATE TABLE mcell_charstate (
       mcell_id INTEGER NOT NULL,
       charstate_id INTEGER NOT NULL,
       rank INTEGER NOT NULL DEFAULT 0
       , PRIMARY KEY (mcell_id,charstate_id,rank)
);

CREATE INDEX mcell_charstate_i1 ON mcell_charstate (charstate_id);