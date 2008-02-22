--
-- SQL script to create the database files (tablespaces) for the schema.
--
-- H.Lapp, GNF, 2002.
--
-- $GNF: projects/gi/symgene/src/DB/BS-create-tablespaces.sql,v 1.4 2003/05/02 02:24:44 hlapp Exp $
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

@BS-defs.sql-local

--
-- Create the tablespaces.
--

CREATE TABLESPACE &biosql_data
       DATAFILE '&datalocation/&biosql_data..dbf' SIZE 32M REUSE
       DEFAULT STORAGE (INITIAL 1024K NEXT 16M 
		        MINEXTENTS 1 MAXEXTENTS UNLIMITED PCTINCREASE 0)
;
ALTER DATABASE DATAFILE '&datalocation/&biosql_data..dbf'
      AUTOEXTEND ON NEXT 128M MAXSIZE  UNLIMITED
;

CREATE TABLESPACE &biosql_index
       DATAFILE '&datalocation/&biosql_index..dbf' SIZE 128M REUSE
       DEFAULT STORAGE (INITIAL 2048K NEXT 24M
		        MINEXTENTS 1 MAXEXTENTS UNLIMITED PCTINCREASE 0)
;
ALTER DATABASE DATAFILE '&datalocation/&biosql_index..dbf'
      AUTOEXTEND ON NEXT 192M MAXSIZE  UNLIMITED
;


CREATE TABLESPACE &biosql_lob
       DATAFILE '&datalocation/&biosql_lob..dbf' SIZE 48M REUSE
       DEFAULT STORAGE (INITIAL 8M NEXT 48M
		        MINEXTENTS 1 MAXEXTENTS UNLIMITED PCTINCREASE 0)
;
ALTER DATABASE DATAFILE '&datalocation/&biosql_lob..dbf'
      AUTOEXTEND ON NEXT 96M MAXSIZE  UNLIMITED
;

