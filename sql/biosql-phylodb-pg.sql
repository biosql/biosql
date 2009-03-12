-- $Id$
--
-- Copyright 2006-2008 Hilmar Lapp, William Piel.
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
-- phylogenetic trees or networks (anastomizing and reticulating).
--
-- This was developed independently of but is very similar to the
-- phylogeny module in Chado (the GMOD common relational model).
--
-- Authors: Hilmar Lapp, hlapp at gmx.net
--          Bill Piel, william.piel at yale.edu
--
-- comments to biosql - biosql-l@open-bio.org

-- the tree - conceptually equal to a namespace (a way to scope nodes and edges)
CREATE SEQUENCE tree_pk_seq;
CREATE TABLE tree (
       tree_id INTEGER DEFAULT nextval('tree_pk_seq') NOT NULL,
       name VARCHAR(32) NOT NULL,
       -- shouldn't this be moved to tree_dbxref?
       identifier VARCHAR(32),
       is_rooted boolean DEFAULT TRUE,
       node_id INTEGER NOT NULL, -- startpoint of tree
       biodatabase_id INTEGER NOT NULL
       , PRIMARY KEY (tree_id)
       , CONSTRAINT tree_c1 UNIQUE (name, biodatabase_id)
);

COMMENT ON TABLE tree IS 'A tree basically is a namespace for nodes, and thereby implicitly for their relationships (edges). In this model, tree is also bit of misnomer because we try to support reticulating trees, i.e., networks, too, so arguably it should be called graph. Typically, this will be used for storing phylogenetic trees, sequence trees (a.k.a. gene trees) as much as species trees.';

COMMENT ON COLUMN tree.name IS 'The name of the tree, in essence a label.';

COMMENT ON COLUMN tree.identifier IS 'The identifier of the tree, if there is one.';

COMMENT ON COLUMN tree.is_rooted IS 'Whether or not the tree is rooted. By default, a tree is assumed to be rooted.';

COMMENT ON COLUMN tree.node_id IS 'The starting node of the tree. If the tree is rooted, this will usually be the root node. Note that the root node(s) of a rooted tree must be stored in tree_root, too.';

COMMENT ON COLUMN tree.biodatabase_id IS 'The namespace of the tree itself. Though trees are in a sense named containers themselves (namely for nodes), they also constitute (possibly identifiable!) data objects in their own right. Some data sources may only provide a single tree, so that assigning a namespace for the tree may seem excessive, but others, such as TreeBASE, contain many trees, just as sequence databanks contain many sequences. The choice of how to name a tree is up to the user; one may assign a default namespace (such as "biosql"), or create one named the same as the tree.';

-- qualifier/value pairs (metadata) for trees
CREATE TABLE tree_qualifier_value (
       tree_id INTEGER NOT NULL,
       term_id INTEGER NOT NULL,
       value TEXT,
       rank INTEGER NOT NULL DEFAULT 0
       , UNIQUE (tree_id, term_id, rank)
);

COMMENT ON TABLE tree_qualifier_value IS 'Tree metadata as attribute/value pairs. Attribute names are from a controlled vocabulary (or ontology).';

COMMENT ON COLUMN tree_qualifier_value.tree_id IS 'The tree with which the metadata is being associated.';

COMMENT ON COLUMN tree_qualifier_value.term_id IS 'The name of the metadate element as a term from a controlled vocabulary (or ontology).';

COMMENT ON COLUMN tree_qualifier_value.value IS 'The value of the metadata element.';

COMMENT ON COLUMN tree_qualifier_value.rank IS 'The index of the metadata value if there is more than one value for the same metadata element. If there is only one value, this may be left at the default of zero.';

-- dbxrefs, such as identifiers, for trees
CREATE TABLE tree_dbxref (
       tree_id INTEGER NOT NULL,
       dbxref_id INTEGER NOT NULL,
       term_id INTEGER NOT NULL
       , UNIQUE (tree_id, dbxref_id, term_id)
);

CREATE INDEX tree_dbxref_i1 ON tree_dbxref (dbxref_id);

COMMENT ON TABLE tree_dbxref IS 'Secondary identifiers and other database cross-references for trees. There can only be one dbxref of a specific type for a tree.';

COMMENT ON COLUMN tree_dbxref.tree_id IS 'The tree to which the database corss-reference is being assigned.';

COMMENT ON COLUMN tree_dbxref.dbxref_id IS 'The database cross-reference being assigned to the tree.';

COMMENT ON COLUMN tree_dbxref.term_id IS 'The type of the database cross-reference as a controlled vocabulary or ontology term. The type of a tree accession should be ''primary identifier''.';

-- nodes in a tree
CREATE SEQUENCE node_pk_seq;
CREATE TABLE node (
       node_id INTEGER DEFAULT nextval('node_pk_seq') NOT NULL,
       label VARCHAR(255),
       tree_id INTEGER NOT NULL,
       left_idx INTEGER,
       right_idx INTEGER
       , PRIMARY KEY (node_id)
-- CONFIG: you might like to enforce uniqueness of a node's label within a tree,
-- though keep in mind that data providers often violate this constraint
--       , CONSTRAINT node_c1 UNIQUE (label,tree_id)
       , UNIQUE (left_idx,tree_id)
       , UNIQUE (right_idx,tree_id)
);

-- CONFIG: if you decided on the unique key constraint on label within
-- a tree, you won't need the index on label, so comment it out for
-- efficiency.
CREATE INDEX node_i1 ON node (label);
CREATE INDEX node_i2 ON node (tree_id);

COMMENT ON TABLE node IS 'A node in a tree. Typically, this will be a node in a phylogenetic tree, resembling either a nucleotide or protein sequence, or a taxon, or more generally an ''operational taxonomic unit'' (OTU).';

COMMENT ON COLUMN node.label IS 'The label of a node. This may the latin binomial of the taxon, the accession number of a sequences, or any other construct that uniquely identifies the node within one tree.';

COMMENT ON COLUMN node.tree_id IS 'The tree of which this node is a part of.';

COMMENT ON COLUMN node.left_idx IS 'The left value of the nested set optimization structure for efficient hierarchical queries. Needs to be precomputed by a program, see J. Celko, SQL for Smarties.';

COMMENT ON COLUMN node.right_idx IS 'The right value of the nested set optimization structure for efficient hierarchical queries. Needs to be precomputed by a program, see J. Celko, SQL for Smarties.';

-- dbxrefs, such as identifiers, for nodes
CREATE TABLE node_dbxref (
       node_id INTEGER NOT NULL,
       dbxref_id INTEGER NOT NULL,
       term_id INTEGER NOT NULL
       , UNIQUE (node_id, dbxref_id, term_id)
);

CREATE INDEX node_dbxref_i1 ON node_dbxref (dbxref_id);

COMMENT ON TABLE node_dbxref IS 'Identifiers and other database cross-references for nodes. There can only be one dbxref of a specific type for a node.';

COMMENT ON COLUMN node_dbxref.node_id IS 'The node to which the database cross-reference is being assigned.';

COMMENT ON COLUMN node_dbxref.dbxref_id IS 'The database cross-reference being assigned to the node.';

COMMENT ON COLUMN node_dbxref.term_id IS 'The type of the database cross-reference as a controlled vocabulary or ontology term. The type of a node identifier should be ''primary identifier''.';

-- linking nodes to bioentries (sequences, or genes) - in concatenated
-- alignments we may need to link to more than one sequence
CREATE SEQUENCE node_bioentry_pk_seq ;
CREATE TABLE node_bioentry (
       node_bioentry_id INTEGER DEFAULT nextval('node_bioentry_pk_seq') NOT NULL,
       node_id INTEGER NOT NULL,
       bioentry_id INTEGER NOT NULL,
       rank INTEGER NOT NULL DEFAULT 0
       , PRIMARY KEY (node_bioentry_id)
       , UNIQUE (node_id, bioentry_id, rank)
);

COMMENT ON TABLE node_bioentry IS 'Links tree nodes to sequences (or other bioentries). If the alignment is concatenated on molecular data, there will be more than one sequence, and rank can be used to order these appropriately.';

COMMENT ON COLUMN node_bioentry.node_id IS 'The node to which the bioentry is being linked.';

COMMENT ON COLUMN node_bioentry.bioentry_id IS 'The bioentry being linked to the node.';

COMMENT ON COLUMN node_bioentry.rank IS 'The index of this bioentry within the list of bioentries being linked to the node, if the order is significant. Typically, this will be used to represent the position of the respective sequence within the concatenated alignment, or the partition index.';  

-- linking nodes to taxa - in concatenated alignments we may need to
-- link to more than one taxon
CREATE SEQUENCE node_taxon_pk_seq ;
CREATE TABLE node_taxon (
       node_taxon_id INTEGER DEFAULT nextval('node_taxon_pk_seq') NOT NULL,
       node_id INTEGER NOT NULL,
       taxon_id INTEGER NOT NULL,
       rank INTEGER NOT NULL DEFAULT 0
       , PRIMARY KEY (node_taxon_id)
       , UNIQUE (node_id, taxon_id, rank)
);

COMMENT ON TABLE node_taxon IS 'Links tree nodes to taxa. If the alignment is concatenated on molecular data, there may be more than one sequence, and these may not necessarily be from the same taxon (e.g., they might be from subspecies). Rank can be used to order these appropriately.';

COMMENT ON COLUMN node_taxon.node_id IS 'The node to which the taxon is being linked.';

COMMENT ON COLUMN node_taxon.taxon_id IS 'The taxon being linked to the node.';

COMMENT ON COLUMN node_taxon.rank IS 'The index of this taxon within the list of taxa being linked to the node, if the order is significant. Typically, this will be used to represent the position of the respective sequence within the concatenated alignment, or the partition index.';

-- root node(s) for the tree, if any
CREATE SEQUENCE tree_root_pk_seq;
CREATE TABLE tree_root (
       tree_root_id INTEGER DEFAULT nextval('tree_root_pk_seq') NOT NULL,
       tree_id INTEGER NOT NULL,
       node_id INTEGER NOT NULL,
       is_alternate boolean DEFAULT FALSE,
       significance real
       , PRIMARY KEY (tree_root_id)
       , UNIQUE (tree_id,node_id)
);

COMMENT ON TABLE tree_root IS 'Root node for a rooted tree. A phylogenetic analysis might suggest several alternative root nodes, with possible probabilities.';

COMMENT ON COLUMN tree_root.tree_id IS 'The tree for which the referenced node is a root node.';

COMMENT ON COLUMN tree_root.node_id IS 'The node that is a root for the referenced tree.';

COMMENT ON COLUMN tree_root.is_alternate IS 'True if the root node is the preferential (most likely) root node of the tree, and false otherwise.';

COMMENT ON COLUMN tree_root.significance IS 'The significance (such as likelihood, or posterior probability) with which the node is the root node. This only has meaning if the method used for reconstructing the tree calculates this value.'; 

-- edges between nodes
CREATE SEQUENCE edge_pk_seq;
CREATE TABLE edge (
       edge_id INTEGER DEFAULT nextval('edge_pk_seq') NOT NULL,
       child_node_id INTEGER NOT NULL,
       parent_node_id INTEGER NOT NULL
       , PRIMARY KEY (edge_id)
       , UNIQUE (child_node_id,parent_node_id)
);

CREATE INDEX edge_i1 ON edge (parent_node_id);

COMMENT ON TABLE edge IS 'An edge between two nodes in a tree (or graph).';

COMMENT ON COLUMN edge.child_node_id IS 'The endpoint node of the two nodes connected by a directed edge. In a phylogenetic tree, this is the descendant.';

COMMENT ON COLUMN edge.parent_node_id IS 'The startpoint node of the two nodes connected by a directed edge. In a phylogenetic tree, this is the ancestor.';

-- transitive closure over edges between nodes
CREATE TABLE node_path (
       child_node_id INTEGER NOT NULL,
       parent_node_id INTEGER NOT NULL,
       path TEXT,
       distance INTEGER
       , PRIMARY KEY (child_node_id,parent_node_id,distance)
);

CREATE INDEX node_path_i1 ON node_path (parent_node_id);

COMMENT ON TABLE node_path IS 'An path between two nodes in a tree (or graph). Two nodes A and B are connected by a (directed) path if B can be reached from A by following nodes that are connected by (directed) edges.';

COMMENT ON COLUMN node_path.child_node_id IS 'The endpoint node of the two nodes connected by a (directed) path. In a phylogenetic tree, this is the descendant.';

COMMENT ON COLUMN node_path.parent_node_id IS 'The startpoint node of the two nodes connected by a (directed) path. In a phylogenetic tree, this is the ancestor.';

COMMENT ON COLUMN node_path.path IS 'The path from startpoint to endpoint as the series of nodes visited along the path. The nodes may be identified by label, or, typically more efficient, by their primary key, or left or right value. The latter or often smaller than the primary key, and hence consume less space. One may increase efficiency further by using a base-34 numeric representation (24 letters of the alphabet, plus 10 digits) instead of decimal (base-10) representation. The actual method used is not important, though it should be used consistently.';

COMMENT ON COLUMN node_path.distance IS 'The distance (or length) of the path. The path between a node and itself has length zero, and length 1 between two nodes directly connected by an edge. If there is a path of length l between two nodes A and Z and an edge between Z and B, there is a path of length l+1 between nodes A and B.'; 

-- attribute/value pairs for edges
CREATE TABLE edge_qualifier_value (
       value text,
       rank INTEGER NOT NULL DEFAULT 0,
       edge_id INTEGER NOT NULL,
       term_id INTEGER NOT NULL
       , UNIQUE (edge_id,term_id,rank)
);

COMMENT ON TABLE edge_qualifier_value IS 'Edge metadata as attribute/value pairs. Attribute names are from a controlled vocabulary (or ontology).';

COMMENT ON COLUMN edge_qualifier_value.edge_id IS 'The tree edge to which the metadata is being associated.';

COMMENT ON COLUMN edge_qualifier_value.term_id IS 'The name of the metadate element as a term from a controlled vocabulary (or ontology).';

COMMENT ON COLUMN edge_qualifier_value.value IS 'The value of the attribute/value pair association of metadata (if applicable).';

COMMENT ON COLUMN edge_qualifier_value.rank IS 'The index of the metadata value if there is more than one value for the same metadata element. If there is only one value, this may be left at the default of zero.';

-- attribute/value pairs for nodes
CREATE TABLE node_qualifier_value (
       value text,
       rank INTEGER NOT NULL DEFAULT 0,
       node_id INTEGER NOT NULL,
       term_id INTEGER NOT NULL
       , UNIQUE (node_id,term_id)
);

COMMENT ON TABLE node_qualifier_value IS 'Tree (or network) node metadata as attribute/value pairs. Attribute names are from a controlled vocabulary (or ontology).';

COMMENT ON COLUMN node_qualifier_value.node_id IS 'The tree (or network) node to which the metadata is being associated.';

COMMENT ON COLUMN node_qualifier_value.term_id IS 'The name of the metadate element as a term from a controlled vocabulary (or ontology).';

COMMENT ON COLUMN node_qualifier_value.value IS 'The value of the attribute/value pair association of metadata (if applicable).';

COMMENT ON COLUMN node_qualifier_value.rank IS 'The index of the metadata value if there is more than one value for the same metadata element. If there is only one value, this may be left at the default of zero.';

-- tree
ALTER TABLE tree ADD CONSTRAINT FKnode
       FOREIGN KEY (node_id) REFERENCES node (node_id)
           DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE tree ADD CONSTRAINT FKbiodatabase
       FOREIGN KEY (biodatabase_id) REFERENCES biodatabase (biodatabase_id);

-- tree_qualifier_value
ALTER TABLE tree_qualifier_value ADD CONSTRAINT FKtree_treequal
       FOREIGN KEY (tree_id) REFERENCES tree (tree_id)
           ON DELETE CASCADE;
ALTER TABLE tree_qualifier_value ADD CONSTRAINT FKterm_treequal
       FOREIGN KEY (term_id) REFERENCES term (term_id);

-- tree_root
ALTER TABLE tree_root ADD CONSTRAINT FKtree_treeroot
       FOREIGN KEY (tree_id) REFERENCES tree (tree_id)
           ON DELETE CASCADE;
ALTER TABLE tree_root ADD CONSTRAINT FKnode_treeroot
       FOREIGN KEY (node_id) REFERENCES node (node_id)
           ON DELETE CASCADE;

-- tree_dbxref
ALTER TABLE tree_dbxref ADD CONSTRAINT FKtree_treedbxref
       FOREIGN KEY (tree_id) REFERENCES tree (tree_id)
           ON DELETE CASCADE;
ALTER TABLE tree_dbxref ADD CONSTRAINT FKdbxref_treedbxref
       FOREIGN KEY (dbxref_id) REFERENCES dbxref (dbxref_id)
           ON DELETE CASCADE;

-- node
ALTER TABLE node ADD CONSTRAINT FKnode_tree
       FOREIGN KEY (tree_id) REFERENCES tree (tree_id);

-- node_dbxref
ALTER TABLE node_dbxref ADD CONSTRAINT FKnode_nodedbxref
       FOREIGN KEY (node_id) REFERENCES node (node_id)
           ON DELETE CASCADE;
ALTER TABLE node_dbxref ADD CONSTRAINT FKdbxref_nodedbxref
       FOREIGN KEY (dbxref_id) REFERENCES dbxref (dbxref_id)
           ON DELETE CASCADE;

-- node_qualifier_value
ALTER TABLE node_qualifier_value ADD CONSTRAINT FKnav_node
       FOREIGN KEY (node_id) REFERENCES node (node_id)
           ON DELETE CASCADE;
ALTER TABLE node_qualifier_value ADD CONSTRAINT FKnav_term
       FOREIGN KEY (term_id) REFERENCES term (term_id);

-- node_bioentry
ALTER TABLE node_bioentry ADD CONSTRAINT FKnodebioentry_bioentry
       FOREIGN KEY (bioentry_id) REFERENCES bioentry (bioentry_id)
           ON DELETE CASCADE;
ALTER TABLE node_bioentry ADD CONSTRAINT FKnodebioentry_node
       FOREIGN KEY (node_id) REFERENCES node (node_id)
           ON DELETE CASCADE;

-- node_taxon
ALTER TABLE node_taxon ADD CONSTRAINT FKnodetaxon_taxon
       FOREIGN KEY (taxon_id) REFERENCES taxon (taxon_id)
           ON DELETE CASCADE;
ALTER TABLE node_taxon ADD CONSTRAINT FKnodetaxon_node
       FOREIGN KEY (node_id) REFERENCES node (node_id)
           ON DELETE CASCADE;

-- edge
ALTER TABLE edge ADD CONSTRAINT FKedge_child
       FOREIGN KEY (child_node_id) REFERENCES node (node_id)
           ON DELETE CASCADE;
ALTER TABLE edge ADD CONSTRAINT FKedge_parent
       FOREIGN KEY (parent_node_id) REFERENCES node (node_id)
           ON DELETE CASCADE;

-- node_path
ALTER TABLE node_path ADD CONSTRAINT FKnpath_child
       FOREIGN KEY (child_node_id) REFERENCES node (node_id)
           ON DELETE CASCADE;
ALTER TABLE node_path ADD CONSTRAINT FKnpath_parent
       FOREIGN KEY (parent_node_id) REFERENCES node (node_id)
           ON DELETE CASCADE;

-- edge_qualifier_value
ALTER TABLE edge_qualifier_value ADD CONSTRAINT FKeav_edge
       FOREIGN KEY (edge_id) REFERENCES edge (edge_id)
           ON DELETE CASCADE;
ALTER TABLE edge_qualifier_value ADD CONSTRAINT FKeav_term
       FOREIGN KEY (term_id) REFERENCES term (term_id);