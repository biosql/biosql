-- Copyright 2004-2008 Len Trigg <len at reeltwo.com>
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
-- These are carefully ordered to avoid foreign key constraint problems
DROP TABLE term_relationship_term;
DROP TABLE term_synonym;
DROP TABLE term_relationship;
DROP TABLE term_path;
DROP TABLE term_dbxref;
DROP TABLE taxon_name;
DROP TABLE seqfeature_relationship;
DROP TABLE seqfeature_qualifier_value;
DROP TABLE seqfeature_path;
DROP TABLE seqfeature_dbxref;
DROP TABLE location_qualifier_value;
DROP TABLE location;
DROP TABLE seqfeature;
DROP TABLE dbxref_qualifier_value;
DROP TABLE biosequence; 
DROP TABLE bioentry_relationship;
DROP TABLE bioentry_reference;
DROP TABLE reference;
DROP TABLE bioentry_qualifier_value;
DROP TABLE bioentry_path;
DROP TABLE bioentry_dbxref;
DROP TABLE dbxref;
DROP TABLE anncomment;
DROP TABLE bioentry;
DROP TABLE biodatabase;
DROP TABLE taxon;
DROP TABLE term;
DROP TABLE ontology;
