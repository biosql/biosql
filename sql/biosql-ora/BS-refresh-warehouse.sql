--
-- SQL script to refresh the Data Warehouse views for SYMGENE/BioSQL
--
-- $GNF: projects/gi/symgene/src/DB/BS-refresh-warehouse.sql,v 1.8 2003/05/15 23:01:30 hlapp Exp $
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
-- do the refresh
--
BEGIN
	DBMS_MVIEW.refresh(list                 => 'SG_ENT_CHR_MAP',
	                   method               => '?',
	                   push_deferred_rpc    => TRUE,
	                   atomic_refresh       => FALSE);
END;
/

-- exit sqlplus
exit
