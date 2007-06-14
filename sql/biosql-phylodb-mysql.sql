-- $Id$

-- Schema extension on top of the BioSQL core schema for representing
-- phylogenetic trees or networks (anastomizing and reticulating).
--
-- This was developed independently but is very similar to the
-- phylogeny module in Chado (the GMOD common relational model).

-- Authors: Hilmar Lapp, Bill Piel, Jamie Estill
--
-- (c) Hilmar Lapp, hlapp at gmx.net, 2007
-- (c) Bill Piel, william.piel at yale.edu, 2007. 
-- You may use, modify, and distribute this code under the same terms as Perl.
-- See the Perl Artistic License.
--
-- comments to biosql - biosql-l@open-bio.org


-- the tree - conceptually equal to a namespace (a way to scope nodes and edges)
CREATE TABLE tree (
       tree_id INT(10) UNSIGNED NOT NULL auto_increment,
       name VARCHAR(32) NOT NULL,
       identifier VARCHAR(32),
       is_rooted ENUM ('FALSE', 'TRUE') DEFAULT 'TRUE',	
       node_id INT(10) UNSIGNED NOT NULL -- startpoint of tree
       , PRIMARY KEY (tree_id)
       , UNIQUE (name)
) TYPE=INNODB;

CREATE INDEX tree_node_id ON tree(node_id);

-- nodes in a tree
CREATE TABLE node (
       node_id INT(10) UNSIGNED NOT NULL auto_increment,
       label VARCHAR(255),
       tree_id INT(10) UNSIGNED NOT NULL,
       bioentry_id INT(10) UNSIGNED,
       taxon_id INT(10) UNSIGNED,
       left_idx INT(10) UNSIGNED,
       right_idx INT(10) UNSIGNED
       , PRIMARY KEY (node_id)
       , UNIQUE (label,tree_id)
       , UNIQUE (left_idx,tree_id)
       , UNIQUE (right_idx,tree_id)
) TYPE=INNODB;


--CREATE INDEX tree_tree_id ON tree(tree_id);
CREATE INDEX node_tree_id ON node(tree_id);

CREATE INDEX node_bioentry_id ON node(bioentry_id);

CREATE INDEX node_taxon_id ON node(taxon_id);

-- edges between nodes
CREATE TABLE edge (
       edge_id INT(10) UNSIGNED NOT NULL auto_increment,
       child_node_id INT(10) UNSIGNED NOT NULL,
       parent_node_id INT(10) UNSIGNED NOT NULL
       , PRIMARY KEY (edge_id)
       , UNIQUE (child_node_id,parent_node_id)
) TYPE=INNODB;       

CREATE INDEX edge_parent_node_id ON edge(parent_node_id);

-- transitive closure over edges between nodes
CREATE TABLE node_path (
       child_node_id INT(10) UNSIGNED NOT NULL,
       parent_node_id INT(10) UNSIGNED NOT NULL,
       path TEXT,
       distance INT(10) UNSIGNED
       , PRIMARY KEY (child_node_id,parent_node_id,distance)
) TYPE=INNODB;       

CREATE INDEX node_path_parent_node_id ON node_path(parent_node_id);

-- attribute/value pairs for edges
CREATE TABLE edge_attribute_value (
       value text,
       edge_id INT(10) UNSIGNED NOT NULL,
       term_id INT(10) UNSIGNED NOT NULL
       , UNIQUE (edge_id,term_id)
) TYPE=INNODB;

CREATE INDEX ea_val_term_id ON edge_attribute_value(term_id);

-- attribute/value pairs for nodes
CREATE TABLE node_attribute_value (
       value text,
       node_id INT(10) UNSIGNED NOT NULL,
       term_id INT(10) UNSIGNED NOT NULL
       , UNIQUE (node_id,term_id)
) TYPE=INNODB;

CREATE INDEX na_val_term_id ON node_attribute_value(term_id);

-- The pg below
--ALTER TABLE tree ADD CONSTRAINT FKnode
--       FOREIGN KEY (node_id) REFERENCES node (node_id)
--           DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE tree ADD CONSTRAINT FKnode
       FOREIGN KEY (node_id) REFERENCES node (node_id);

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
