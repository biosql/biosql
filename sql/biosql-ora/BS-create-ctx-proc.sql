--
-- SQL script to create the procedures used for context indexes.
--
--
-- $GNF: projects/gi/symgene/src/DB/BS-create-ctx-proc.sql,v 1.7 2003/06/25 00:14:33 hlapp Exp $
--

--
-- Copyright 2002-2003 Genomics Institute of the Novartis Research Foundation
-- Copyright 2002-2008 Hilmar Lapp
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

--
-- The procedure for synthesizing the description/keyword query documents.
--
CREATE OR REPLACE PROCEDURE Ctx_Ent_Desc(rid IN ROWID, 
					 doc IN OUT NOCOPY CLOB)
-- CREATE OR REPLACE FUNCTION Ctx_Ent_Desc_Test(rid IN ROWID)
-- RETURN CLOB
IS
	CURSOR entqual_c (
	       rid		IN ROWID, 
	       Obj_Trm_Oid_	IN SG_TERM.OID%TYPE,
	       Pred_Trm_Oid_	IN SG_TERM.OID%TYPE)
	IS
		SELECT REPLACE(Obj.Name,' ','-') Name, EntTrmA.Value
		FROM SG_Bioentry_Qualifier_Assoc EntTrmA, SG_Bioentry Ent,
		     SG_Term_Assoc TrmA, SG_Term Obj
		WHERE
     		     EntTrmA.Trm_Oid	= TrmA.Subj_Trm_Oid
		AND  EntTrmA.Value IS NOT NULL
		AND  TrmA.Pred_Trm_Oid	= Pred_Trm_Oid_
		AND  TrmA.Obj_Trm_Oid	= Obj.Oid
		AND  Obj.Oid		= Obj_Trm_Oid_
		AND  EntTrmA.Ent_Oid    = Ent.Oid
		AND  Ent.Rowid		= rid
		;
	CURSOR entcmt_c (rid IN ROWID)
	IS
		SELECT c.comment_text FROM SG_Bioentry e, SG_Comment c
		WHERE 
		      c.ent_oid = e.oid
		AND   e.rowid = rid
		;
	buf VARCHAR2(8192);
--	doc CLOB;
BEGIN
--	DBMS_LOB.CreateTemporary(doc, FALSE);
	--
	-- add the description of the Bioentry
	--
	FOR desc_c IN (
		SELECT description FROM SG_Bioentry 
		WHERE rowid = rid
		AND   description IS NOT NULL
	)
	LOOP
		-- open description section 
		buf := '<description>';
		DBMS_LOB.WriteAppend(doc, LENGTH(buf), buf);
		-- append description
		DBMS_LOB.WriteAppend(doc,
				     LENGTH(desc_c.description),
				     desc_c.description);
		-- close description section 
		buf := '</description>';
		DBMS_LOB.WriteAppend(doc, LENGTH(buf), buf);
	END LOOP;
	--
	-- add qualifiers we are interested in:
	--
	-- descriptive gene names, function descriptions, and phenotype
	-- descriptions
	--
	FOR gene_c IN entqual_c(rid,
				Trm.get_oid(Trm_Identifier => 'QUO:1000002',
					    cache_By_Id	   => 1),
				Trm.get_oid(Trm_Identifier => 'REO:1000008',
					    cache_By_Id	   => 1))
	LOOP
		buf := '<' || gene_c.Name || '>';
		DBMS_LOB.WriteAppend(doc, LENGTH(buf), buf);
		DBMS_LOB.WriteAppend(doc, LENGTH(gene_c.Value), gene_c.Value);
		buf := '</' || gene_c.Name || '>';
		DBMS_LOB.WriteAppend(doc, LENGTH(buf), buf);
	END LOOP;
	FOR gene_c IN entqual_c(rid,
				Trm.get_oid(Trm_Identifier => 'QUO:1000003',
					    cache_By_Id	   => 1),
				Trm.get_oid(Trm_Identifier => 'REO:1000008',
					    cache_By_Id	   => 1))
	LOOP
		buf := '<' || gene_c.Name || '>';
		DBMS_LOB.WriteAppend(doc, LENGTH(buf), buf);
		DBMS_LOB.WriteAppend(doc, LENGTH(gene_c.Value), gene_c.Value);
		buf := '</' || gene_c.Name || '>';
		DBMS_LOB.WriteAppend(doc, LENGTH(buf), buf);
	END LOOP;
	FOR gene_c IN entqual_c(rid,
				Trm.get_oid(Trm_Identifier => 'QUO:1000004',
					    cache_By_Id	   => 1),
				Trm.get_oid(Trm_Identifier => 'REO:1000008',
					    cache_By_Id	   => 1))
	LOOP
		buf := '<' || gene_c.Name || '>';
		DBMS_LOB.WriteAppend(doc, LENGTH(buf), buf);
		DBMS_LOB.WriteAppend(doc, LENGTH(gene_c.Value), gene_c.Value);
		buf := '</' || gene_c.Name || '>';
		DBMS_LOB.WriteAppend(doc, LENGTH(buf), buf);
	END LOOP;
	--
	-- add the comment(s) of the Bioentry if any
	--
	FOR cmt_c IN entcmt_c(rid)
	LOOP
		buf := '<comment>';
		DBMS_LOB.WriteAppend(doc, LENGTH(buf), buf);
		DBMS_LOB.Copy(doc,
			      cmt_c.comment_text,
			      DBMS_LOB.GetLength(cmt_c.comment_text),
			      DBMS_LOB.GetLength(doc)+1,
			      1);
		buf := '</comment>';
		DBMS_LOB.WriteAppend(doc, LENGTH(buf), buf);
	END LOOP;
--	RETURN doc;
END;
/

