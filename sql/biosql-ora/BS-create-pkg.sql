--
-- SQL script to create all PL/SQL API packages.
--
-- $GNF: projects/gi/symgene/src/DB/BS-create-pkg.sql,v 1.11 2003/07/08 23:15:27 hlapp Exp $
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
-- a few package depend on a list type being present, so create it right here
--
CREATE TYPE Oid_List_t AS TABLE OF INTEGER;
/

--
-- Package headers
--
prompt Creating package SGAPI

@PkgAPI/SGAPI.pkg

prompt Creating package BSStd

@PkgAPI/BSStd.pkg

prompt Creating package for entity Biodatabase

@PkgAPI/Biodatabase.pkg

prompt Creating package for entity Bioentry

@PkgAPI/Bioentry.pkg

prompt Creating package for entity Bioentry_Assoc

@PkgAPI/Bioentry_Assoc.pkg

prompt Creating package for entity Bioentry_Path

@PkgAPI/Bioentry_Path.pkg

prompt Creating package for entity Bioentry_Qualifier_Assoc

@PkgAPI/Bioentry_Qualifier_Assoc.pkg

prompt Creating package for entity Bioentry_Ref_Assoc

@PkgAPI/Bioentry_Ref_Assoc.pkg

prompt Creating package for entity Bioentry_Dbxref_Assoc

@PkgAPI/Bioentry_Dbxref_Assoc.pkg

prompt Creating package for entity Biosequence

@PkgAPI/Biosequence.pkg

prompt Creating package for entity Chr_Map_Assoc

@PkgAPI/Chr_Map_Assoc.pkg

prompt Creating package for entity Comment

@PkgAPI/Comment.pkg

prompt Creating package for entity Dbxref

@PkgAPI/Dbxref.pkg

prompt Creating package for entity Dbxref_Qualifier_Assoc

@PkgAPI/Dbxref_Qualifier_Assoc.pkg

prompt Creating package for entity Location

@PkgAPI/Location.pkg

prompt Creating package for entity Location_Qualifier_Assoc

@PkgAPI/Location_Qualifier_Assoc.pkg

prompt Creating package for entity Ontology

@PkgAPI/Ontology.pkg

prompt Creating package for entity Reference

@PkgAPI/Reference.pkg

prompt Creating package for entity Seqfeature

@PkgAPI/Seqfeature.pkg

prompt Creating package for entity Seqfeature_Dbxref_Assoc

@PkgAPI/Seqfeature_Dbxref_Assoc.pkg

prompt Creating package for entity Seqfeature_Assoc

@PkgAPI/Seqfeature_Assoc.pkg

prompt Creating package for entity Seqfeature_Path

@PkgAPI/Seqfeature_Path.pkg

prompt Creating package for entity Seqfeature_Qualifier_Assoc

@PkgAPI/Seqfeature_Qualifier_Assoc.pkg

prompt Creating package for entity Similarity

@PkgAPI/Similarity.pkg

prompt Creating package for entity Taxon

@PkgAPI/Taxon.pkg

prompt Creating package for entity Taxon_Name

@PkgAPI/Taxon_Name.pkg

prompt Creating package for entity Term

@PkgAPI/Term.pkg

prompt Creating package for entity Term_Synonym

@PkgAPI/Term_Synonym.pkg

prompt Creating package for entity Term_Dbxref_Assoc

@PkgAPI/Term_Dbxref_Assoc.pkg

prompt Creating package for entity Term_Assoc

@PkgAPI/Term_Assoc.pkg

prompt Creating package for entity Term_Path

@PkgAPI/Term_Path.pkg


--
-- Package bodies
--
prompt Creating package body for SGAPI

@PkgAPI/SGAPI.pkb

prompt Creating package body for BSStd

@PkgAPI/BSStd.pkb

prompt Creating package body for entity Biodatabase

@PkgAPI/Biodatabase.pkb

prompt Creating package body for entity Bioentry

@PkgAPI/Bioentry.pkb

prompt Creating package body for entity Bioentry_Assoc

@PkgAPI/Bioentry_Assoc.pkb

prompt Creating package body for entity Bioentry_Path

@PkgAPI/Bioentry_Path.pkb

prompt Creating package body for entity Bioentry_Qualifier_Assoc

@PkgAPI/Bioentry_Qualifier_Assoc.pkb

prompt Creating package body for entity Bioentry_Ref_Assoc

@PkgAPI/Bioentry_Ref_Assoc.pkb

prompt Creating package body for entity Bioentry_Dbxref_Assoc

@PkgAPI/Bioentry_Dbxref_Assoc.pkb

prompt Creating package body for entity Biosequence

@PkgAPI/Biosequence.pkb

prompt Creating package body for entity Chr_Map_Assoc

@PkgAPI/Chr_Map_Assoc.pkb

prompt Creating package body for entity Comment

@PkgAPI/Comment.pkb

prompt Creating package body for entity Dbxref

@PkgAPI/Dbxref.pkb

prompt Creating package body for entity Dbxref_Qualifier_Assoc

@PkgAPI/Dbxref_Qualifier_Assoc.pkb

prompt Creating package body for entity Location

@PkgAPI/Location.pkb

prompt Creating package body for entity Location_Qualifier_Assoc

@PkgAPI/Location_Qualifier_Assoc.pkb

prompt Creating package body for entity Ontology

@PkgAPI/Ontology.pkb

prompt Creating package body for entity Reference

@PkgAPI/Reference.pkb

prompt Creating package body for entity Seqfeature

@PkgAPI/Seqfeature.pkb

prompt Creating package body for entity Seqfeature_Assoc

@PkgAPI/Seqfeature_Assoc.pkb

prompt Creating package body for entity Seqfeature_Path

@PkgAPI/Seqfeature_Path.pkb

prompt Creating package body for entity Seqfeature_Dbxref_Assoc

@PkgAPI/Seqfeature_Dbxref_Assoc.pkb

prompt Creating package body for entity Seqfeature_Qualifier_Assoc

@PkgAPI/Seqfeature_Qualifier_Assoc.pkb

prompt Creating package body for entity Similarity

@PkgAPI/Similarity.pkb

prompt Creating package body for entity Taxon

@PkgAPI/Taxon.pkb

prompt Creating package body for entity Taxon_Name

@PkgAPI/Taxon_Name.pkb

prompt Creating package body for entity Term

@PkgAPI/Term.pkb

prompt Creating package body for entity Term_Synonym

@PkgAPI/Term_Synonym.pkb

prompt Creating package body for entity Term_Dbxref_Assoc

@PkgAPI/Term_Dbxref_Assoc.pkb

prompt Creating package body for entity Term_Assoc

@PkgAPI/Term_Assoc.pkb

prompt Creating package body for entity Term_Path

@PkgAPI/Term_Path.pkb

