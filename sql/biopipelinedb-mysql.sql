#
# Table structure for table 'job'
#
CREATE TABLE job (
  job_id        int(10) unsigned DEFAULT '0' NOT NULL auto_increment,
  input_id      varchar(40) DEFAULT '' NOT NULL,
  analysis_id   int(10) unsigned DEFAULT '0' NOT NULL,
  queue_id      int(10) unsigned DEFAULT '0',
  stdout_file   varchar(100) DEFAULT '' NOT NULL,
  stderr_file   varchar(100) DEFAULT '' NOT NULL,
  object_file   varchar(100) DEFAULT '' NOT NULL,
  retry_count   int default 0,

  PRIMARY KEY (job_id),
  KEY input_index (input_id),
  KEY analysis_index (analysis_id)
);


#General refactoring to standard table_id naming
#LSFid changed to queue_id
#removed class

#
# Table structure for table 'jobstatus'
#
CREATE TABLE jobstatus (
  job_id   int(10) unsigned DEFAULT '0' NOT NULL,
  status   varchar(40) DEFAULT 'CREATED' NOT NULL,
  time     datetime DEFAULT '0000-00-00 00:00:00' NOT NULL,

  KEY intid (job_id),
  KEY status_index (status),
  KEY time (time)
);

CREATE TABLE rule_goal (
  rule_id       int unsigned default '0' not null auto_increment,
  analysis_id   int unsigned,
 
  PRIMARY KEY (rule_id)
);

CREATE TABLE rule_conditions (
  rule_id       int unsigned not null,
  analysis_id   varchar(20),
 
  PRIMARY KEY (rule_id)
);

CREATE TABLE input_analysis (
  input_id      varchar(40) not null,
  analysis_id   int not null,
  created       datetime not null,

  PRIMARY KEY   (analysis_id, input_id),
  KEY created   (created),
  KEY analaysis (analysis_id),
  KEY input_id  (input_id)
);

#removed class, added index to analysis

CREATE TABLE datasource (
   datasource_id        int unsigned DEFAULT '0' NOT NULL auto_increment,
   db_adaptor           varchar(100) DEFAULT '' NOT NULL,
   db_locator           varchar(100) DEFAULT '' NOT NULL,
   biodbadaptor         varchar(100) DEFAULT '' NOT NULL,
   biodbname            varchar(40) DEFAULT '' NOT NULL,
   data_adaptor         varchar(40) DEFAULT '' NOT NULL,
   data_adaptor_method  varchar(40) DEFAULT '' NOT NULL,

   PRIMARY KEY (datasource_id)
);

CREATE TABLE IO (
   IO_id          int unsigned DEFAULT '0' NOT NULL auto_increment,
   datasource_id  int unsigned DEFAULT '0' NOT NULL,
   IO_type        enum ("input","output") not null,

   PRIMARY KEY (IO_id,datasource_id),
   KEY type(IO_type)
);

CREATE TABLE input (
   input_id       int unsigned DEFAULT '0' NOT NULL auto_increment,
   datasource_id  int unsigned DEFAULT '0' NOT NULL,
   name           varchar(40) DEFAULT '' NOT NULL,

   PRIMARY KEY (input_id),
   KEY ds(datasource_id)
);

CREATE TABLE analysis (
  analysis_id      int(10) unsigned DEFAULT '0' NOT NULL auto_increment,
  created          datetime DEFAULT '0000-00-00 00:00:00' NOT NULL,
  logic_name       varchar(40) not null,
  db               varchar(120),
  db_version       varchar(40),
  db_file          varchar(120),
  program          varchar(80),
  program_version  varchar(40),
  program_file     varchar(80),
  parameters       varchar(80),
  runnable         varchar(80),
  IO_id            int(10) unsigned DEFAULT '0' NOT NULL,
  gff_source       varchar(40),
  gff_feature      varchar(40),

  PRIMARY KEY (analysis_id)
);
#Added IO_id, changed module to runnable and removed module_version



