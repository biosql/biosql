-- BioSQL accelerator procedures for PostgreSQL
-- By Thomas Down

DROP FUNCTION biosql_accelerators_level ();

CREATE FUNCTION biosql_accelerators_level () RETURNS int AS '
  BEGIN
    RETURN 1;
  END;
' LANGUAGE 'plpgsql';

DROP FUNCTION intern_seqfeature_key (text);

CREATE FUNCTION intern_seqfeature_key (text) RETURNS int AS '
  DECLARE
    kname ALIAS FOR $1;
    kid int;
  BEGIN
    select into kid seqfeature_key_id from seqfeature_key where key_name = kname;
    IF NOT FOUND THEN
      INSERT INTO seqfeature_key (key_name) VALUES (kname);
      RETURN currval(''seqfeature_ke_seqfeature_ke_seq'');
    END IF;
    RETURN kid;
  END;
' LANGUAGE 'plpgsql';

DROP FUNCTION intern_seqfeature_source (text);

CREATE FUNCTION intern_seqfeature_source (text) RETURNS int AS '
  DECLARE
    kname ALIAS FOR $1;
    kid int;
  BEGIN
    select into kid seqfeature_source_id from seqfeature_source where source_name = kname;
    IF NOT FOUND THEN
      INSERT INTO seqfeature_source (source_name) VALUES (kname);
      RETURN currval(''seqfeature_so_seqfeature_so_seq'');
    END IF;
    RETURN kid;
  END;
' LANGUAGE 'plpgsql';

DROP FUNCTION intern_seqfeature_qualifier (text);

CREATE FUNCTION intern_seqfeature_qualifier (text) RETURNS int AS '
  DECLARE
    kname ALIAS FOR $1;
    kid int;
  BEGIN
    select into kid seqfeature_qualifier_id from seqfeature_qualifier where qualifier_name = kname;
    IF NOT FOUND THEN
      INSERT INTO seqfeature_qualifier (qualifier_name) VALUES (kname);
      RETURN currval(''seqfeature_qu_seqfeature_qu_seq'');
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
    VALUES (cs_bioentry_id, intern_seqfeature_key(cs_key), intern_seqfeature_source(cs_source));
    
    RETURN currval(''seqfeature_seqfeature_id_seq'');
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
    VALUES (cs_bioentry_id, intern_seqfeature_key(cs_key), intern_seqfeature_source(cs_source));
    
    sf_id := currval(''seqfeature_seqfeature_id_seq'');

    INSERT INTO seqfeature_location
           (seqfeature_id, seq_start, seq_end, seq_strand, location_rank)
    VALUES (sf_id, cs_start, cs_end, cs_strand, 1);

    RETURN sf_id;
  END;
' LANGUAGE 'plpgsql';