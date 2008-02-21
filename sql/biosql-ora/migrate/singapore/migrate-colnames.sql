--
-- This SQL script is to migrate the Bioentry table from the pre-Singapore
-- Oracle version of the BioSQL schema to the so-called Singapore version.
--
-- Disclaimer: This script and scripts it launches will modify the schema. It
-- will modify and drop tables, indexes, column names, triggers, sequences,
-- and possibly more. YOU SHOULD BACKUP YOUR DATABASE BEFORE RUNNING THIS
-- SCRIPT, or any of the scripts it launches. You should also verify that
-- you can actually restore from your backup. If you fail to properly take
-- a backup that restores the database to its prior status, serious
-- consequences up to and including complete loss of your data may result
-- from the operation of this script. THIS PACKAGE IS PROVIDED WITHOUT ANY
-- WARRANTIES WHATSOEVER. Please read the license under which you may use
-- this script and those that come with it.
--
-- $GNF: projects/gi/symgene/src/sql/migrate/singapore/migrate-colnames.sql,v 1.4 2003/07/08 22:48:35 hlapp Exp $
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

PROMPT Migrating column definitions for various tables

-- Seqfeature:
PROMPT     - Seqfeature

ALTER TABLE SG_Seqfeature RENAME COLUMN Ont_Oid TO Type_Trm_Oid;
ALTER TABLE SG_Seqfeature MODIFY (Type_Trm_Oid NOT NULL);
ALTER TABLE SG_Seqfeature RENAME COLUMN FSrc_Oid TO Source_Trm_Oid;
ALTER TABLE SG_Seqfeature MODIFY (Source_Trm_Oid NOT NULL);
ALTER TABLE SG_Seqfeature ADD (
	Display_Name		VARCHAR2(64) NULL
);

-- we rename the existing index using a spool file to make sure there is
-- no error if it was renamed before
set timing off
set heading off
set termout off
set feedback off

spool _rename_idx.sql

SELECT 'ALTER INDEX ' || index_name || ' RENAME TO XIF1Seqfeature;'
FROM user_indexes 
WHERE table_name = 'SG_SEQFEATURE' AND index_name LIKE 'XIF%';

spool off

set timing on
set heading on
set termout on
set feedback on

-- we didn't have this one before; its primary use case is to speed up the
-- look up when deleting terms (Oracle does this to make sure the FK
-- constraint isn't violated)
CREATE INDEX XIF2Seqfeature ON SG_Seqfeature
(
       Source_Trm_Oid
)
    	 TABLESPACE &biosql_index
;

-- Biodatabase:
PROMPT     - Biodatabase

ALTER TABLE SG_Biodatabase ADD (
	Description	VARCHAR2(256) NULL
);

-- Bioentry: 
PROMPT     - Bioentry

ALTER TABLE SG_Bioentry RENAME COLUMN Display_ID TO Name;

-- Bioentry DBXRef Association
PROMPT     - Bioentry/DBXRef Associations

ALTER TABLE SG_Bioentry_DBXRef_Assoc ADD (
	Rank	NUMBER(4) DEFAULT 0 NOT NULL 
);

-- Bioentry Qualifier Association
PROMPT     - Bioentry Qualifier Associations

ALTER TABLE SG_Bioentry_Qualifier_Assoc RENAME COLUMN Ont_Oid TO Trm_Oid;

-- Seqfeature Qualifier Association
PROMPT     - Seqfeature Qualifier Associations

ALTER TABLE SG_Seqfeature_Qualifier_Assoc RENAME COLUMN Ont_Oid TO Trm_Oid;

-- Location Qualifier Association
PROMPT     - Location Qualifier Associations

ALTER TABLE SG_Location_Qualifier_Assoc RENAME COLUMN Ont_Oid TO Trm_Oid;

-- Term
PROMPT     - Term

ALTER TABLE SG_Term ADD (
	Is_Obsolete		VARCHAR2(1) NULL,
	CONSTRAINT IsObsolete1 CHECK (Is_Obsolete = 'X')
)
;

-- Seqfeature_Location changed to Location
PROMPT     - Location

set timing off
set heading off
set termout off
set feedback off

spool _rename_seqfealoc_objs.sql

SELECT DECODE(Object_Type,
              'TABLE', 'RENAME ' || Object_Name,
	      'INDEX', 'ALTER INDEX ' || Object_Name || ' RENAME') ||
       ' TO ' ||
       REPLACE(Object_Name, 'SEQFEATURE_') ||
       ';'
FROM user_objects 
WHERE Object_Name LIKE '%SEQFEATURE_LOCATION%'
AND   Object_Type IN ('TABLE','INDEX')
;
SELECT 'ALTER TABLE ' ||
       REPLACE(Table_Name, 'SEQFEATURE_') ||
       ' RENAME CONSTRAINT ' ||
       Constraint_Name ||
       ' TO ' ||
       REPLACE(Constraint_Name, 'SEQFEATURE_') ||
       ';'
FROM user_constraints
WHERE Constraint_Name LIKE '%SEQFEATURE_LOCATION%'
;

spool off

set timing on
set heading on
set termout on
set feedback on

start _rename_seqfealoc_objs

-- add optional foreign key to Term
ALTER TABLE SG_Location ADD (
	Trm_Oid INTEGER NULL
);

ALTER TABLE SG_Location
       ADD  ( CONSTRAINT FKTrm_Loc
              FOREIGN KEY (Trm_Oid)
                             REFERENCES SG_Term (Oid) ) ;

CREATE INDEX XIF2Location ON SG_Location
(
       Trm_Oid
)
    	 TABLESPACE &biosql_index
;

-- need to change the name of the trigger, which requires dropping it and
-- recreating from scratch
DROP TRIGGER BIR_Seqfeature_Location;

CREATE OR REPLACE TRIGGER BIR_Location
  BEFORE INSERT
  on SG_Location
  -- 
  for each row
/* Template for auto-generation of primary key (H.Lapp, lapp@gnf.org) */
/* Default body for BIR_Location */
BEGIN
IF :new.Oid IS NULL THEN
    SELECT SG_SEQUENCE_Fea.nextval INTO :new.Oid FROM DUAL;
END IF;
END;
/

