--
-- SQL script to migrate tables from pre-1.0 to the version that became
-- Biosql 1.0.
--
-- $GNF: projects/gi/symgene/src/sql/migrate/1.0/migrate-all.sql,v 1.4 2004/09/03 01:49:22 hlapp Exp $
--

--
-- (c) Hilmar Lapp, hlapp at gnf.org, 2004.
-- (c) GNF, Genomics Institute of the Novartis Research Foundation, 2004.
--
-- You may distribute this module under the same terms as Perl.
-- Refer to the Perl Artistic License (see the license accompanying this
-- software package, or see http://www.perl.com/language/misc/Artistic.html)
-- for the terms under which you may use, modify, and redistribute this module.
-- 
-- THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
-- WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
-- MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
--

-- first bring in local configuration
@BS-defs-local

-- SG_Bioentry_Ref_Assoc.Rank was constrained to only 2 digit integers
PROMPT Fixing constraint on SG_Bioentry_Ref_Assoc.Rank

ALTER TABLE SG_Bioentry_Ref_Assoc MODIFY (rank NUMBER(4));

-- SG_DBXRef.Accession needs more characters due to certain Term dbxrefs
PROMPT Fixing width of SG_DBXRef.Accession

ALTER TABLE SG_DBXRef MODIFY (Accession VARCHAR2(64));

-- SG_Term_Synonym.Name is too short to accommodate GO
PROMPT Fixing width of SG_Term_Synonym.Name

ALTER TABLE SG_Term_Synonym MODIFY (Name VARCHAR2(256));

-- SG_Term.Definition is too short for InterPro (actually, 4000 still is)
PROMPT Fixing width of SG_Term.Definition

ALTER TABLE SG_Term MODIFY (Definition VARCHAR2(4000));

-- SG_Ontology.Name had to be widened from 32 chars
PROMPT Fixing width of SG_Ontology.Name

ALTER TABLE SG_Ontology MODIFY (Name VARCHAR2(64));

-- SG_Taxon.NCBI_Taxon_ID had to be widened to make the repair-taxonomy
-- algorithm work when OIDs go into 9 digit numbers.
PROMPT Fixing precision of SG_Taxon.NCBI_Taxon_ID

ALTER TABLE SG_Taxon MODIFY (NCBI_Taxon_ID INTEGER);

-- We added a column CRC to Biosequence.
PROMPT Adding column CRC to Biosequence

ALTER TABLE SG_Biosequence ADD (CRC VARCHAR2(32) NULL);

-- We had to widen Biodatabase.Acronym for our purposes.
PROMPT Fixing width of SG_Biodatabase.Acronym

ALTER TABLE SG_Biodatabase MODIFY (Acronym VARCHAR2(12));

-- We adopted the term_relationship_term addition driven from Biojava.
PROMPT Adopting the term_relationship_term addition coming from Biojava

ALTER TABLE SG_Term_Assoc ADD (Trm_Oid INTEGER NULL);
ALTER TABLE SG_Term_Assoc
       ADD ( CONSTRAINT XAK2Term_Assoc UNIQUE (Trm_Oid)
             USING INDEX TABLESPACE &biosql_index);
ALTER TABLE SG_Term_Assoc
       ADD  ( CONSTRAINT FKTrm_TrmA
              FOREIGN KEY (Trm_Oid)
                             REFERENCES SG_Term (Oid)
			     ON DELETE SET NULL ) ;

