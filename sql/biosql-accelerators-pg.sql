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
    select into t_id ontology_term_id from ontology_term where term_name = t_name;
    IF NOT FOUND THEN
      INSERT INTO ontology_term (term_name) VALUES (t_name);
      RETURN currval(''ontology_term_pk_seq'');
    END IF;
    RETURN t_id;
  END;
' LANGUAGE 'plpgsql';

DROP FUNCTION intern_seqfeature_source (text);

CREATE FUNCTION intern_seqfeature_source (text) RETURNS int AS '
  DECLARE
    kname ALIAS FOR $1;
    kid integer;
  BEGIN
    select into kid seqfeature_source_id from seqfeature_source where source_name = kname;
    IF NOT FOUND THEN
      INSERT INTO seqfeature_source (source_name) VALUES (kname);
      RETURN currval(''seqfeature_source_pk_seq'');
    END IF;
    RETURN kid;
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
           (bioentry_id, seqfeature_key_id, seqfeature_source_id)
    VALUES (cs_bioentry_id, intern_ontology_term(cs_key), intern_seqfeature_source(cs_source));
    
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
           (bioentry_id, seqfeature_key_id, seqfeature_source_id)
    VALUES (cs_bioentry_id, intern_ontology_term(cs_key), intern_seqfeature_source(cs_source));
    
    sf_id := currval(''seqfeature_pk_seq'');

    INSERT INTO seqfeature_location
           (seqfeature_id, seq_start, seq_end, seq_strand, location_rank)
    VALUES (sf_id, cs_start, cs_end, cs_strand, 1);

    RETURN sf_id;
  END;
' LANGUAGE 'plpgsql';