#
# Table structure for table 'job'
#
CREATE TABLE job (
  job_id             int(10) unsigned DEFAULT '0' NOT NULL auto_increment,
  analysis_id        int(10) unsigned DEFAULT '0',
  queue_id           int(10) unsigned DEFAULT '0',
  stdout_file        varchar(100) DEFAULT '' NOT NULL,
  stderr_file        varchar(100) DEFAULT '' NOT NULL,
  object_file        varchar(100) DEFAULT '' NOT NULL,
  status             varchar(40) DEFAULT 'CREATED' NOT NULL,
  time               datetime DEFAULT '0000-00-00 00:00:00' NOT NULL,
  retry_count        int default 0,

  PRIMARY KEY (job_id),
  KEY (analysis_id)
);


CREATE TABLE rule_goal (
  rule_id       int(10) unsigned default '0' not null auto_increment,
  analysis_id   int(10) unsigned,
 
  PRIMARY KEY (rule_id),
  KEY(analysis_id)
);

CREATE TABLE rule_conditions (
  rule_id       int(10) unsigned not null,
  analysis_id   varchar(20),
 
  PRIMARY KEY (rule_id),
  KEY(analysis_id)

);

#removed class, added index to analysis

CREATE TABLE input_dba(
   input_dba_id             int(10) unsigned DEFAULT '0' NOT NULL auto_increment,
   analysis_id          int(10) DEFAULT '0' NOT NULL,
   dbadaptor_id         int(10) DEFAULT '0' NOT NULL,
   biodbadaptor         varchar(100) DEFAULT '' NOT NULL,
   biodbname            varchar(40) DEFAULT '' NOT NULL,
   data_adaptor         varchar(40) DEFAULT '' NOT NULL,
   data_adaptor_method  varchar(40) DEFAULT '' NOT NULL,

   PRIMARY KEY (input_dba_id),
   KEY (dbadaptor_id),
   KEY (analysis_id)
);

CREATE TABLE output_dba (
   output_dba_id        int(10) unsigned DEFAULT '0' NOT NULL auto_increment,
   analysis_id          int(10) unsigned DEFAULT '0' NOT NULL,
   dbadaptor_id         int(10) unsigned DEFAULT '0' NOT NULL,
   biodbadaptor         varchar(100) DEFAULT '' NOT NULL,
   biodbname            varchar(40) DEFAULT '' NOT NULL,
   data_adaptor         varchar(40) DEFAULT '' NOT NULL,
   data_adaptor_method  varchar(40) DEFAULT '' NOT NULL,

   PRIMARY KEY (output_dba_id),
   KEY (dbadaptor_id),
   KEY (analysis_id)
);

CREATE TABLE dbadaptor (
   dbadaptor_id   int(10) unsigned DEFAULT '0' NOT NULL auto_increment,
   dbname         varchar(40) DEFAULT '' NOT NULL,
   driver         varchar (40) DEFAULT '' NOT NULL,
   host           varchar (40) DEFAULT '',
   user           varchar (40) DEFAULT '',
   pass           varchar (40) DEFAULT '',
   module         varchar (100) DEFAULT '',
   
   PRIMARY KEY (dbadaptor_id)
);

CREATE TABLE input (
   input_id    int(10) unsigned DEFAULT '0' NOT NULL auto_increment,
   input_dba_id  int(10) unsigned NOT NULL,
   job_id            int(10) unsigned NOT NULL,
   name              varchar(40) DEFAULT '' NOT NULL,

   PRIMARY KEY (input_id),
   KEY (input_dba_id),
   KEY (job_id)
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
  gff_source       varchar(40),
  gff_feature      varchar(40),

  PRIMARY KEY (analysis_id)
);
#Added IO_id, changed module to runnable and removed module_version


