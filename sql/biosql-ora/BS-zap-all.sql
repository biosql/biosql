--
-- SQL script to zap the entire Symgene/Biosql database.
--
-- Use with caution - the content is gone afterwards - you can't rollback.
--
-- $Id$
--

set timing off
set heading off
set termout off
set feedback off

spool _zap-symgene.sql

SELECT 'ALTER TABLE ' || table_name || 
       ' MODIFY CONSTRAINT ' || constraint_name || 
       ' DISABLE;' 
FROM user_constraints WHERE constraint_type = 'R';

SELECT 'TRUNCATE TABLE ' || table_name || ';' 
FROM user_tables WHERE table_name LIKE 'SG_%';

SELECT 'ALTER TABLE ' || table_name || 
       ' MODIFY CONSTRAINT ' || constraint_name || 
       ' ENABLE;' 
FROM user_constraints WHERE constraint_type = 'R';

spool off

set timing on
set heading on
set termout on
set feedback on

start _zap-symgene
