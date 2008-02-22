--
-- Copyright 2002-2003 Thomas Down
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
-- BioSQL accelerator procedures for PostgreSQL
-- By Thomas Down

DROP FUNCTION biosql_accelerators_level ();

CREATE FUNCTION biosql_accelerators_level () RETURNS int AS '
  BEGIN
    RETURN 2;
  END;
' LANGUAGE 'plpgsql';

DROP FUNCTION intern_ontology_term (text);

CREATE FUNCTION intern_ontology_term (text) RETURNS int AS '
  DECLARE
    t_name ALIAS FOR $1;
    t_id integer;
  BEGIN
    select into t_id term_id from term where name = t_name;
    IF NOT FOUND THEN
      INSERT INTO term (name) VALUES (t_name);
      RETURN currval(''term_pk_seq'');
    END IF;
    RETURN t_id;
  END;
' LANGUAGE 'plpgsql';

DROP FUNCTION create_seqfeature (integer, text, text);

CREATE FUNCTION create_seqfeature (integer, text, text) RETURNS int AS '
  DECLARE
    cs_bioentry_id ALIAS FOR $1;
    cs_key         ALIAS FOR $2;
    cs_source      ALIAS FOR $3;
  BEGIN
    INSERT INTO seqfeature 
           (bioentry_id, type_term_id, source_term_id)
    VALUES (cs_bioentry_id, intern_ontology_term(cs_key), intern_ontology_term(cs_source));
    
    RETURN currval(''seqfeature_pk_seq'');
  END;
' LANGUAGE 'plpgsql';

DROP FUNCTION create_seqfeature_onespan (integer, text, text, integer, integer, integer);

CREATE FUNCTION create_seqfeature_onespan (integer, text, text, integer, integer, integer) RETURNS int AS '
  DECLARE
    cs_bioentry_id ALIAS FOR $1;
    cs_key         ALIAS FOR $2;
    cs_source      ALIAS FOR $3;
    cs_start       ALIAS FOR $4;
    cs_end         ALIAS FOR $5;
    cs_strand      ALIAS FOR $6;
    sf_id          integer;
  BEGIN
    INSERT INTO seqfeature 
           (bioentry_id, type_term_id, source_term_id)
    VALUES (cs_bioentry_id, intern_ontology_term(cs_key), intern_ontology_term(cs_source));
    
    sf_id := currval(''seqfeature_pk_seq'');

    INSERT INTO seqfeature_location
           (seqfeature_id, start_pos, end_pos, strand, rank)
    VALUES (sf_id, cs_start, cs_end, cs_strand, 1);

    RETURN sf_id;
  END;
' LANGUAGE 'plpgsql';