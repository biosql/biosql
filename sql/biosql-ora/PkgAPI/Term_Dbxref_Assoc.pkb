-- -*-Sql-*- mode (to keep my emacs happy)
--
-- API Package Body for Term_Dbxref_Assoc.
--
-- Scaffold auto-generated by gen-api.pl. gen-api.pl is
-- (c) Hilmar Lapp, lapp@gnf.org, GNF, 2002.
--
-- $GNF: projects/gi/symgene/src/DB/PkgAPI/Term_Dbxref_Assoc.pkb,v 1.3 2003/05/21 09:33:18 hlapp Exp $
--

--
-- (c) Hilmar Lapp, hlapp at gnf.org, 2003.
-- (c) GNF, Genomics Institute of the Novartis Research Foundation, 2003.
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

CREATE OR REPLACE
PACKAGE BODY TrmDbxA IS

TrmDbxA_cached	SG_TERM_DBXREF_ASSOC.TRM_OID%TYPE DEFAULT NULL;
cache_key		VARCHAR2(128) DEFAULT NULL;

CURSOR TrmDbxA_c (TrmDbxA_TRM_OID	IN SG_TERM_DBXREF_ASSOC.TRM_OID%TYPE,
		  TrmDbxA_DBX_OID	IN SG_TERM_DBXREF_ASSOC.DBX_OID%TYPE)
RETURN SG_TERM_DBXREF_ASSOC%ROWTYPE IS
	SELECT t.* FROM SG_TERM_DBXREF_ASSOC t
	WHERE
		t.TRM_OID = TrmDbxA_TRM_OID
	AND	t.DBX_OID = TrmDbxA_DBX_OID
	;

FUNCTION get_oid(
		TRM_OID	IN SG_TERM_DBXREF_ASSOC.TRM_OID%TYPE DEFAULT NULL,
		DBX_OID	IN SG_TERM_DBXREF_ASSOC.DBX_OID%TYPE DEFAULT NULL,
		TrmDbxA_RANK	IN SG_TERM_DBXREF_ASSOC.RANK%TYPE DEFAULT NULL,
		Trm_NAME	IN SG_TERM.NAME%TYPE DEFAULT NULL,
		ONT_OID	IN SG_TERM.ONT_OID%TYPE DEFAULT NULL,
		ONT_NAME	IN SG_ONTOLOGY.NAME%TYPE DEFAULT NULL,
		Trm_IDENTIFIER	IN SG_TERM.IDENTIFIER%TYPE DEFAULT NULL,
		Dbx_ACCESSION	IN SG_DBXREF.ACCESSION%TYPE DEFAULT NULL,
		Dbx_DBNAME	IN SG_DBXREF.DBNAME%TYPE DEFAULT NULL,
		Dbx_VERSION	IN SG_DBXREF.VERSION%TYPE DEFAULT NULL,
		do_DML		IN NUMBER DEFAULT BSStd.DML_NO)
RETURN SG_TERM_DBXREF_ASSOC.TRM_OID%TYPE
IS
	pk	SG_TERM_DBXREF_ASSOC.TRM_OID%TYPE DEFAULT NULL;
	TrmDbxA_row TrmDbxA_c%ROWTYPE;
	TRM_OID_	SG_TERM.OID%TYPE DEFAULT TRM_OID;
	DBX_OID_	SG_DBXREF.OID%TYPE DEFAULT DBX_OID;
	key_str	VARCHAR2(128) DEFAULT TRM_OID || '|' || TRM_NAME || '|' || ONT_OID || '|' || ONT_NAME || '|' || TRM_IDENTIFIER || '|' || Dbx_Accession || '|' || Dbx_DBName || '|' || Dbx_Version || '|' || DBX_OID;
BEGIN
	-- initialize
	-- look up
	IF pk IS NULL THEN
		IF (key_str = cache_key) THEN
			pk := TrmDbxA_cached;
		ELSE
			-- reset cache
			cache_key := NULL;
			TrmDbxA_cached := NULL;
                	-- look up SG_TERM
                	IF (TRM_OID_ IS NULL) THEN
                		TRM_OID_ := Trm.get_oid(
                			Trm_NAME => Trm_NAME,
                			ONT_OID => ONT_OID,
                			ONT_NAME => ONT_NAME,
                			Trm_IDENTIFIER => Trm_IDENTIFIER);
                	END IF;
                	-- look up SG_DBXREF
                	IF (DBX_OID_ IS NULL) THEN
                		DBX_OID_ := Dbx.get_oid(
                			Dbx_ACCESSION => Dbx_ACCESSION,
                			Dbx_DBNAME => Dbx_DBNAME,
                			Dbx_VERSION => Dbx_VERSION);
                	END IF;
			-- do the look up
			FOR TrmDbxA_row IN TrmDbxA_c (TRM_OID_, DBX_OID_) LOOP
		        	pk := TrmDbxA_row.TRM_OID;
				-- cache result
			    	cache_key := key_str;
			    	TrmDbxA_cached := pk;
			END LOOP;
		END IF;
	END IF;
	-- insert/update if requested
	IF (pk IS NULL) AND 
	   ((do_DML = BSStd.DML_I) OR (do_DML = BSStd.DML_UI)) THEN
	    	-- look up foreign keys if not provided:
		-- look up SG_TERM successful?
		IF (TRM_OID_ IS NULL) THEN
			raise_application_error(-20101,
				'failed to look up Trm <' || Trm_NAME || '|' || ONT_OID || '|' || ONT_NAME || '|' || Trm_IDENTIFIER || '>');
		END IF;
		-- look up SG_DBXREF successful?
		IF (DBX_OID_ IS NULL) THEN
			raise_application_error(-20101,
				'failed to look up Dbx <' || Dbx_ACCESSION || '|' || Dbx_DBNAME || '|' || Dbx_VERSION || '>');
		END IF;
	    	-- insert the record and obtain the primary key
	    	pk := do_insert(
		        TRM_OID => TRM_OID_,
		        DBX_OID => DBX_OID_,
			RANK => TrmDbxA_RANK);
	END IF; -- no update here
	-- return the primary key
	RETURN pk;
END;

FUNCTION do_insert(
		TRM_OID	IN SG_TERM_DBXREF_ASSOC.TRM_OID%TYPE,
		DBX_OID	IN SG_TERM_DBXREF_ASSOC.DBX_OID%TYPE,
		RANK	IN SG_TERM_DBXREF_ASSOC.RANK%TYPE)
RETURN SG_TERM_DBXREF_ASSOC.TRM_OID%TYPE 
IS
BEGIN
	-- insert the record
	INSERT INTO SG_TERM_DBXREF_ASSOC (
		TRM_OID,
		DBX_OID,
		RANK)
	VALUES (TRM_OID,
		DBX_OID,
		RANK)
	;
	-- return the foreign key value
	RETURN TRM_OID;
END;

END TrmDbxA;
/
