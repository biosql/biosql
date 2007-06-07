-- $Id$

-- Schema extension on top of the BioSQL core schema for representing
-- phylogenetic trees or networks (anastomizing and reticulating).
--
-- This was developed independently but is very similar to the
-- phylogeny module in Chado (the GMOD common relational model).

-- Authors: Hilmar Lapp, Bill Piel
--
-- (c) Hilmar Lapp, hlapp at gmx.net, 2007
-- (c) Bill Piel, william.piel at yale.edu, 2007. 
-- You may use, modify, and distribute this code under the same terms as Perl.
-- See the Perl Artistic License.
--
-- comments to biosql - biosql-l@open-bio.org

-- the tree - conceptually equal to a namespace (a way to scope nodes and edges)
CREATE SEQUENCE tree_pk_seq;
CREATE TABLE tree (
       tree_id INTEGER DEFAULT nextval('tree_pk_seq') NOT NULL,
       name VARCHAR(32) NOT NULL,
       identifier VARCHAR(32),
       is_rooted boolean DEFAULT TRUE,
       node_id INTEGER NOT NULL -- startpoint of tree
       , PRIMARY KEY (tree_id)
       , UNIQUE (name)
);

COMMENT ON TABLE tree IS 'A tree basically is a namespace for nodes, and thereby implicitly for their relationships (edges). In this model, tree is also bit of misnomer because we try to support reticulating trees, i.e., networks, too, so arguably it should be called graph. Typically, this will be used for storing phylogenetic trees, sequence trees (a.k.a. gene trees) as much as species trees.';

COMMENT ON COLUMN tree.name IS 'The name of the tree, in essence a label.';

COMMENT ON COLUMN tree.identifier IS 'The identifier of the tree, if there is one.';

COMMENT ON COLUMN tree.is_rooted IS 'Whether or not the tree is rooted. By default, a tree is assumed to be rooted.';

COMMENT ON COLUMN tree.node_id IS 'The starting node of the tree. If the tree is rooted, this will be the root node.';

-- nodes in a tree
CREATE SEQUENCE node_pk_seq;
CREATE TABLE node (
       node_id INTEGER DEFAULT nextval('node_pk_seq') NOT NULL,
       label VARCHAR(255),
       tree_id INTEGER NOT NULL,
       bioentry_id INTEGER,
       taxon_id INTEGER,
       left_idx INTEGER,
       right_idx INTEGER
       , PRIMARY KEY (node_id)
       , UNIQUE (label,tree_id)
       , UNIQUE (left_idx,tree_id)
       , UNIQUE (right_idx,tree_id)
);

COMMENT ON TABLE node IS 'A node in a tree. Typically, this will be a node in a phylogenetic tree, resembling either a nucleotide or protein sequence, or a taxon, or more generally an ''operational taxonomic unit'' (OTU).';

COMMENT ON COLUMN node.label IS 'The label of a node. This may the latin binomial of the taxon, the accession number of a sequences, or any other construct that uniquely identifies the node within one tree.';

COMMENT ON COLUMN node.tree_id IS 'The tree of which this node is a part of.';

COMMENT ON COLUMN node.bioentry_id IS 'Optionally, the bioentry the node corresponds too, for example the sequence.';

COMMENT ON COLUMN node.taxon_id IS 'Optionally, the taxon the node corresponds to.';

COMMENT ON COLUMN node.left_idx IS 'The left value of the nested set optimization structure for efficient hierarchical queries. Needs to be precomputed by a program, see J. Celko, SQL for Smarties.';

COMMENT ON COLUMN node.right_idx IS 'The right value of the nested set optimization structure for efficient hierarchical queries. Needs to be precomputed by a program, see J. Celko, SQL for Smarties.';

-- edges between nodes
CREATE SEQUENCE edge_pk_seq;
CREATE TABLE edge (
       edge_id INTEGER DEFAULT nextval('edge_pk_seq') NOT NULL,
       child_node_id INTEGER NOT NULL,
       parent_node_id INTEGER NOT NULL
       , PRIMARY KEY (edge_id)
       , UNIQUE (child_node_id,parent_node_id)
);

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

COMMENT ON TABLE node_path IS 'An path between two nodes in a tree (or graph). Two nodes A and B are connected by a (directed) path if B can be reached from A by following nodes that are connected by (directed) edges.';

COMMENT ON COLUMN node_path.child_node_id IS 'The endpoint node of the two nodes connected by a (directed) path. In a phylogenetic tree, this is the descendant.';

COMMENT ON COLUMN node_path.parent_node_id IS 'The startpoint node of the two nodes connected by a (directed) path. In a phylogenetic tree, this is the ancestor.';

COMMENT ON COLUMN node_path.path IS 'The path from startpoint to endpoint as the series of nodes visited along the path. The nodes may be identified by label, or, typically more efficient, by their primary key, or left or right value. The latter or often smaller than the primary key, and hence consume less space. One may increase efficiency further by using a base-34 numeric representation (24 letters of the alphabet, plus 10 digits) instead of decimal (base-10) representation. The actual method used is not important, though it should be used consistently.';

COMMENT ON COLUMN node_path.distance IS 'The distance (or length) of the path. The path between a node and itself has length zero, and length 1 between two nodes directly connected by an edge. If there is a path of length l between two nodes A and Z and an edge between Z and B, there is a path of length l+1 between nodes A and B.'; 

-- attribute/value pairs for edges
CREATE TABLE edge_attribute_value (
       value text,
       edge_id INTEGER NOT NULL,
       term_id INTEGER NOT NULL
       , UNIQUE (edge_id,term_id)
);

-- attribute/value pairs for nodes
CREATE TABLE node_attribute_value (
       value text,
       node_id INTEGER NOT NULL,
       term_id INTEGER NOT NULL
       , UNIQUE (node_id,term_id)
);

ALTER TABLE tree ADD CONSTRAINT FKnode
       FOREIGN KEY (node_id) REFERENCES node (node_id)
           DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE node ADD CONSTRAINT FKnode_tree
       FOREIGN KEY (tree_id) REFERENCES tree (tree_id);

ALTER TABLE node ADD CONSTRAINT FKnode_bioentry
       FOREIGN KEY (bioentry_id) REFERENCES bioentry (bioentry_id);

ALTER TABLE node ADD CONSTRAINT FKnode_taxon
       FOREIGN KEY (taxon_id) REFERENCES taxon (taxon_id);

ALTER TABLE edge ADD CONSTRAINT FKedge_child
       FOREIGN KEY (child_node_id) REFERENCES node (node_id)
           ON DELETE CASCADE;

ALTER TABLE edge ADD CONSTRAINT FKedge_parent
       FOREIGN KEY (parent_node_id) REFERENCES node (node_id)
           ON DELETE CASCADE;

ALTER TABLE node_path ADD CONSTRAINT FKnpath_child
       FOREIGN KEY (child_node_id) REFERENCES node (node_id)
           ON DELETE CASCADE;

ALTER TABLE node_path ADD CONSTRAINT FKnpath_parent
       FOREIGN KEY (parent_node_id) REFERENCES node (node_id)
           ON DELETE CASCADE;

ALTER TABLE edge_attribute_value ADD CONSTRAINT FKeav_edge
       FOREIGN KEY (edge_id) REFERENCES edge (edge_id)
           ON DELETE CASCADE;

ALTER TABLE edge_attribute_value ADD CONSTRAINT FKeav_term
       FOREIGN KEY (term_id) REFERENCES term (term_id);

ALTER TABLE node_attribute_value ADD CONSTRAINT FKnav_node
       FOREIGN KEY (node_id) REFERENCES node (node_id)
           ON DELETE CASCADE;

ALTER TABLE node_attribute_value ADD CONSTRAINT FKnav_term
       FOREIGN KEY (term_id) REFERENCES term (term_id);
