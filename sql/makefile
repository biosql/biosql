SCRIPTS= ../scripts

MYSQL_RUN = mysql
MYSQL_CORE_SCHEMA = biosqldb-mysql.sql
MYSQL_ONTOLOGY_SCHEMA = ontology/biosqldb-ontology-mysql.sql

all:
	echo "type 'gmake mysql-full:[your-dbname]'"

mysql-core\:%: $(MYSQL_CORE_SCHEMA)
	$(MYSQL_RUN) $* < $(MYSQL_CORE_SCHEMA) &&\
	touch $@

mysql-ontology\:%: $(MYSQL_ONTOLOGY_SCHEMA)
	$(MAKE) mysql-core\:$* &&\
	$(MYSQL_RUN) $* < $(MYSQL_ONTOLOGY_SCHEMA) &&\
	touch $@

mysql-full\:%: 
	$(MAKE) mysql-core\:$* &&\
	$(MAKE) mysql-ontology\:$* &&\
	touch $@

mysql-clean:
	-rm mysql-*\:*

PG_RUN = psql
PG_CORE_SCHEMA = biosqldb-pg.sql
PG_ACCELERATORS_SCHEMA = biosql-accelerators-pg.sql
PG_VIEWS_SCHEMA = biosqldb-views-pg.sql
PG_ONTOLOGY_SCHEMA = ontology/biosqldb-ontology-pg.sql

$(PG_CORE_SCHEMA): $(MYSQL_CORE_SCHEMA)
	perl $(SCRIPTS)/transform_sql.pl -t pg $(MYSQL_CORE_SCHEMA) > $@

$(PG_ONTOLOGY_SCHEMA): $(MYSQL_ONTOLOGY_SCHEMA)
	perl $(SCRIPTS)/transform_sql.pl -t pg $(MYSQL_ONTOLOGY_SCHEMA) > $@

pg-core\:%: $(PG_CORE_SCHEMA)
	$(PG_RUN) $* < $(PG_CORE_SCHEMA) &&\
	touch $@

pg-ontology\:%:  $(PG_ONTOLOGY_SCHEMA)
	$(MAKE) pg-core\:$* &&\
	$(PG_RUN) $* < $(PG_ONTOLOGY_SCHEMA) &&\
	touch $@

pg-accelerators\:%: $(PG_ACCELERATORS_SCHEMA)
	$(PG_RUN) $* < $(PG_ACCELERATORS_SCHEMA) &&\
	touch $@

pg-views\:%: $(PG_VIEWS_SCHEMA)
	$(PG_RUN) $* < $(PG_VIEWS_SCHEMA) &&\
	touch $@

#pg-full\:%: pg-core\:$* pg-ontology\:$* pg-accelerators\:$* pg-views\:$*
pg-full\:%: 
	$(MAKE) pg-core\:$* &&\
	$(MAKE) pg-ontology\:$* &&\
	$(MAKE) pg-accelerators\:$* &&\
	$(MAKE) pg-views\:$* &&\
	touch $@

pg-clean:
	-rm pg-*\:*

# END OF PG SPECIFIC

clean: pg-clean mysql-clean
