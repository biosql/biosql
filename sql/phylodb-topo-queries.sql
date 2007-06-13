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

-- 2) a) Find the subtree rooted at LCA(A,B) of nodes A and B (minimal
-- spanning clade) (as all edges constituting the subtree; the labels
-- are optional and obviously not part of the edges)
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
-- b) variant: find the subtree rooted at a node (as all edges
-- constituting the subtree; the labels are optional and obviously not
-- part of the edges)
SELECT e.edge_id, pt.node_id, pt.label, ch.node_id, ch.label 
FROM node_path p, edge e, node pt, node ch 
WHERE 
    e.child_node_id = p.child_node_id
AND pt.node_id = e.parent_node_id
AND ch.node_id = e.child_node_id
AND p.parent_node_id = ?

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
 
-- 5) Tree projection: obtain the subtree induced by the chosen set of
-- nodes A_1, ..., A_n
-- Two steps:
-- i) Find the last common ancestor node LCA = LCA(A_1,...,A_n)
-- ii) Obtain the minimum spanning clade rooted at LCA, and prune off
-- non-matching terminal nodes, and non-shared internal nodes.
--
-- The solution below is a single hit query, after obtaining the
-- LCA. It looks a bit hideous, but it seems to work pretty well. For
-- a subtree induced by 3 terminal nodes on the ITIS plant tree it
-- returns within less than a second. We should try and convert this
-- into a stored function accepting the array of query nodes as input,
-- and returning a set of edges.
--
-- Suggestions for a simpler query are greatly welcome. There are also
-- no guearantees yet that this works entirely correct for all input.
--
-- We return the subtree as a set of edges that defines the tree.
SELECT paths.child_node_id, paths.parent_node_id
FROM node_path paths, 
     (
     -- all possible parents of the edges we wish to return, i.e.,
     -- internal nodes shared among the paths between the query nodes
     -- and the LCA
     SELECT p.parent_node_id AS node_id
     FROM node_path p, node_path clade
     WHERE clade.parent_node_id = :lca
     AND clade.child_node_id = p.parent_node_id
     AND p.child_node_id IN (:a_1, :a_2, ..., :a_n)
     AND p.distance > 0
     GROUP BY p.parent_node_id
     HAVING COUNT(p.parent_node_id) > 1
     ) parents, 
     (
     -- all possible children of the edges we wish to return, i.e.,
     -- internal nodes shared among the paths between the query nodes
     -- and the LCA, and the query nodes themselves
     SELECT p.parent_node_id AS node_id
     FROM node_path p, node_path clade
     WHERE clade.parent_node_id = :lca
     AND clade.child_node_id = p.parent_node_id
     AND p.child_node_id IN (:a_1, :a_2, ..., :a_n)
     AND p.distance > 0
     GROUP BY p.parent_node_id
     HAVING COUNT(p.parent_node_id) > 1
     UNION
     SELECT n.node_id 
     FROM node n
     WHERE n.node_id IN (:a_1, :a_2, ..., :a_n)
     ) children
WHERE 
     paths.parent_node_id = parents.node_id
AND  paths.child_node_id = children.node_id
AND  paths.distance > 0
-- for each child node, we only want to report the edge corresponding
-- to the path with minimum length of all matching paths (provided the
-- length is greated than zero), so prune those with longer distance
AND NOT EXISTS (
     SELECT 1
     FROM node_path p1
     WHERE 
          p1.child_node_id = paths.child_node_id
     AND  p1.parent_node_id IN (
          SELECT p.parent_node_id AS node_id
     	  FROM node_path p, node_path clade
     	  WHERE clade.parent_node_id = :lca
     	  AND clade.child_node_id = p.parent_node_id
     	  AND p.child_node_id IN (:a_1, :a_2, ..., :a_n)
     	  AND p.distance > 0
     	  GROUP BY p.parent_node_id
          HAVING COUNT(p.parent_node_id) > 1
     )
     AND p1.distance < paths.distance
     AND p1.distance > 0
)

-- 6) Subsetting trees:
-- a) all trees that have at least the given nodes, identified by label
SELECT t.tree_id, MIN(t.name), MIN(t.node_id)
FROM tree t, node q
WHERE q.label IN (...)     -- enumerate labels here
AND q.tree_id = t.tree_id
GROUP BY t.tree_id
HAVING COUNT(t.name) >= ?  -- substitute number of labels
