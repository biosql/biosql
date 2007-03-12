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
       identifier VARCHAR(16),
       node_id INTEGER NOT NULL -- startpoint of tree
       , PRIMARY KEY (tree_id)
       , UNIQUE (name)
);

-- nodes in a tree
CREATE SEQUENCE node_pk_seq;
CREATE TABLE node (
       node_id INTEGER DEFAULT nextval('node_pk_seq') NOT NULL,
       label VARCHAR(255),
       tree_id INTEGER NOT NULL,
       gene_id INTEGER,
       taxon_id INTEGER,
       left_idx INTEGER,
       right_idx INTEGER
       , PRIMARY KEY (node_id)
       , UNIQUE (label,tree_id)
       , UNIQUE (left_idx,tree_id)
       , UNIQUE (right_idx,tree_id)
);

-- edges between nodes
CREATE SEQUENCE edge_pk_seq;
CREATE TABLE edge (
       edge_id INTEGER DEFAULT nextval('edge_pk_seq') NOT NULL,
       child_node_id INTEGER NOT NULL,
       parent_node_id INTEGER NOT NULL
       , PRIMARY KEY (edge_id)
       , UNIQUE (child_node_id,parent_node_id)
);       

-- transitive closure over edges between nodes
CREATE TABLE node_path (
       child_node_id INTEGER NOT NULL,
       parent_node_id INTEGER NOT NULL,
       path TEXT,
       distance INTEGER
       , PRIMARY KEY (child_node_id,parent_node_id,distance)
);       

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
       FOREIGN KEY (gene_id) REFERENCES bioentry (bioentry_id);

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
