#
# Table structure for table 'job'
#
CREATE TABLE job (
  job_id             int(10) unsigned DEFAULT '0' NOT NULL auto_increment,
  analysis_id        int(10) unsigned DEFAULT '0',
  queue_id           int(10) unsigned DEFAULT '0',
  stdout_file        varchar(100) DEFAULT '',
  stderr_file        varchar(100) DEFAULT '',
  object_file        varchar(100) DEFAULT '',
  status             varchar(20) DEFAULT 'NEW' NOT NULL,
  stage              varchar(20) DEFAULT '',
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

CREATE TABLE iohandler (
   iohandler_id         int(10) unsigned DEFAULT '0' NOT NULL auto_increment,
   dbadaptor_id         int(10) DEFAULT '0' NOT NULL,
   type                 enum ('INPUT','OUTPUT') NOT NULL,

   PRIMARY KEY (iohandler_id),
   KEY dbadaptor (dbadaptor_id)
);
# note-  the column type is meant for differentiating the input adaptors from the output adaptors
#        each analysis should only have ONE output adaptor.

CREATE TABLE datahandler(
    datahandler_id     int(10) unsigned NOT NULL auto_increment,
    iohandler_id        int(10) DEFAULT '0' NOT NULL,
    method              varchar(60) DEFAULT '' NOT NULL,
    argument            varchar(40) DEFAULT '' ,
    rank                int(10) DEFAULT 1 NOT NULL,

    PRIMARY KEY (datahandler_id),
    KEY iohandler (iohandler_id)
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
   input_id         int(10) unsigned DEFAULT '0' NOT NULL auto_increment,
   iohandler_id     int(10) unsigned NOT NULL,
   job_id           int(10) unsigned NOT NULL,
   name             varchar(40) DEFAULT '' NOT NULL,

   PRIMARY KEY (input_id),
   KEY iohandler (iohandler_id),
   KEY job (job_id)
);


CREATE TABLE analysis (
  analysis_id      int(10) unsigned DEFAULT '0' NOT NULL auto_increment,
  created          datetime DEFAULT '0000-00-00 00:00:00' NOT NULL,
  logic_name       varchar(40) not null,
  runnable         varchar(80),
  db               varchar(120),
  db_version       varchar(40),
  db_file          varchar(120),
  program          varchar(80),
  program_version  varchar(40),
  program_file     varchar(80),
  parameters       varchar(80),
  gff_source       varchar(40),
  gff_feature      varchar(40),

  PRIMARY KEY (analysis_id)
);

# created new table to relect the fact that many analysis can share an io 
# and that an analysis can have more than 1 io

CREATE TABLE analysis_iohandler(
  analysis_iohandler_id     int(10) unsigned DEFAULT'0' NOT NULL auto_increment,
  analysis_id               int(10) NOT NULL,
  iohandler_id              int(10) NOT NULL,

  PRIMARY KEY (analysis_iohandler_id),
  KEY analysis (analysis_id),
  KEY iohandler (iohandler_id)

);

#Added IO_id, changed module to runnable and removed module_version

#table to keep track of job histories

CREATE TABLE completed_jobs (
  completed_job_id      int(10) unsigned DEFAULT '0' NOT NULL auto_increment,
  analysis_id           int(10) unsigned DEFAULT '0',
  queue_id              int(10) unsigned DEFAULT '0',
  stdout_file           varchar(100) DEFAULT '' NOT NULL,
  stderr_file           varchar(100) DEFAULT '' NOT NULL,
  object_file           varchar(100) DEFAULT '' NOT NULL,
  time                  datetime DEFAULT '0000-00-00 00:00:00' NOT NULL,
  retry_count           int default 0,

  PRIMARY KEY (completed_job_id),
  KEY analysis (analysis_id)
);
