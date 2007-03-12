-- $Id$

-- Common topological queries on a database of phylogenetic trees.
-- 1a) Find the LCA (least common ancestor) of nodes A and B
-- 1b) Find the oldest ancestor node of A such that B is not
-- descended from the ancestor
-- 2) Find the subtree rooted at LCA(A,B) of nodes A and B (minimal 
-- spanning clade)
-- 3) Find the maximim spanning clade that includes nodes A and B but not C
-- (stem query)
-- 4) Tree pattern match - all trees that have the same topology between a
-- chosen set of taxa (or genes)
-- a) all trees for which the minimum spanning clade of nodes A and B
-- includes node C (as identified by label)
-- b) all trees for which the minimum spanning clade of nodes A and B
-- does not include node C (as identified by label) 
-- 5) Tree projection: obtain the subtree induced by the chosen set of nodes
--    NOT DONE YET!
-- 6) Subsetting trees:
-- a) all trees that have at least the given nodes, identified by label

-- Authors: Hilmar Lapp
--
-- (c) Hilmar Lapp, hlapp at gmx.net, 2007
-- (c) Bill Piel, william.piel at yale.edu, 2007. 
-- You may use, modify, and distribute this code under the same terms as Perl.
-- See the Perl Artistic License.
--
-- comments to biosql - biosql-l@open-bio.org

-- 1a) Find the LCA (least common ancestor) of nodes A and B
SELECT lca.node_id, lca.label, 
       pA.distance AS distance_a, pB.distance AS distance_b
FROM node lca, node_path pA, node_path pB
WHERE pA.parent_node_id = pB.parent_node_id
AND   lca.node_id = pA.parent_node_id
AND   pA.child_node_id = ? 
AND   pB.child_node_id = ?
ORDER BY pA.distance
LIMIT 1;
-- return only first row (minimum combined distance)
-- (could use either distance too)

-- 1b) Find the oldest ancestor node of A such that B is not
-- descended from the ancestor
SELECT dca.node_id, dca.label, pA.distance
FROM node dca, node_path pA
WHERE
     dca.node_id = pA.parent_node_id
AND  pA.child_node_id = ?
AND NOT EXISTS (
       SELECT 1 FROM node_path pB
       WHERE pB.parent_node_id = pA.parent_node_id
       AND   pB.child_node_id = ?
)
ORDER BY pA.distance DESC
LIMIT 1;

-- 2) Find the subtree rooted at LCA(A,B) of nodes A and B (minimal 
-- spanning clade)
SELECT e.edge_id, pt.node_id, pt.label, ch.node_id, ch.label 
FROM node_path p, edge e, node pt, node ch 
WHERE 
    e.child_node_id = p.child_node_id
AND pt.node_id = e.parent_node_id
AND ch.node_id = e.child_node_id
AND p.parent_node_id IN (
      SELECT pA.parent_node_id
      FROM   node_path pA, node_path pB
      WHERE pA.parent_node_id = pB.parent_node_id
      AND   pA.child_node_id = ? 
      AND   pB.child_node_id = ?
      ORDER BY pA.distance
      LIMIT 1
)

-- 3) Find the maximim spanning clade that includes nodes A and B but not C
-- (stem query)
SELECT e.edge_id, pt.node_id, pt.label, ch.node_id, ch.label 
FROM node_path p, edge e, node pt, node ch 
WHERE 
    e.child_node_id = p.child_node_id
AND pt.node_id = e.parent_node_id
AND ch.node_id = e.child_node_id
AND p.parent_node_id IN (
      SELECT pA.parent_node_id
      FROM   node_path pA, node_path pB
      WHERE pA.parent_node_id = pB.parent_node_id
      AND   pA.child_node_id = ? 
      AND   pB.child_node_id = ?
)
AND NOT EXISTS (
    SELECT 1 FROM node_path np
    WHERE 
        np.child_node_id  = ?
    AND np.parent_node_id = p.parent_node_id
)


-- 4) Tree pattern match - all trees that have the same topology between a
-- chosen set of taxa (or genes)
-- a) all trees for which the minimum spanning clade of nodes A and B
-- includes node C (as identified by label)
SELECT t.tree_id, t.name
FROM tree t, node_path p, node C
WHERE
    p.child_node_id = C.node_id
AND C.tree_id = t.tree_id
AND p.parent_node_id IN (
      SELECT pA.parent_node_id
      FROM   node_path pA, node_path pB, node A, node B
      WHERE pA.parent_node_id = pB.parent_node_id
      AND   pA.child_node_id = A.node_id
      AND   pB.child_node_id = B.node_id
      AND   A.label = ? -- 'Anticlea elegans'
      AND   B.label = ? -- 'Zigadenus glaberrimus'
      ORDER BY pA.distance
      LIMIT 1
)
AND C.label = ? -- 'Toxicoscordion nuttallii'
;

-- b) all trees for which the minimum spanning clade of nodes A and B
-- does not include node C (as identified by label)
SELECT t.tree_id, t.name
FROM tree t, node_path p, node n
WHERE
    p.parent_node_id = n.node_id
AND n.tree_id = t.tree_id
AND p.parent_node_id IN (
      SELECT pA.parent_node_id
      FROM   node_path pA, node_path pB, node A, node B
      WHERE pA.parent_node_id = pB.parent_node_id
      AND   pA.child_node_id = A.node_id
      AND   pB.child_node_id = B.node_id
      AND   A.label = ? -- 'Anticlea elegans'
      AND   B.label = ? -- 'Zigadenus glaberrimus'
      ORDER BY pA.distance
      LIMIT 1
)
AND NOT EXISTS (
    SELECT 1 FROM node C, node_path np
    WHERE 
        np.child_node_id = C.node_id
    AND np.parent_node_id = p.parent_node_id
    AND C.label = ? -- 'Toxicoscordion nuttallii'
)
;
 
-- 5) Tree projection: obtain the subtree induced by the chosen set of nodes


-- 6) Subsetting trees:
-- a) all trees that have at least the given nodes, identified by label
SELECT t.tree_id, MIN(t.name), MIN(t.node_id)
FROM tree t, node q
WHERE q.label IN (...)     -- enumerate labels here
AND q.tree_id = t.tree_id
GROUP BY t.tree_id
HAVING COUNT(t.name) >= ?  -- substitute number of labels
