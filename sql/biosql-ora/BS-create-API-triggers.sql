--
-- SQL script to create the triggers enabling the load API.
--
--
-- $GNF: projects/gi/symgene/src/DB/BS-create-API-triggers.sql,v 1.8 2003/05/23 17:42:27 hlapp Exp $
--

--
-- (c) Hilmar Lapp, hlapp at gnf.org, 2002.
-- (c) GNF, Genomics Institute of the Novartis Research Foundation, 2002.
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

prompt Trigger for SGLD_Terms API

@load-trgs/Terms.trg

prompt Trigger for SGLD_Term_Assocs API

@load-trgs/Term_Assocs.trg

prompt Trigger for SGLD_Bioentries API

@load-trgs/Bioentries.trg

prompt Trigger for SGLD_Bioentry_Qualifier_Assocs API

@load-trgs/Bioentry_Qualifier_Assocs.trg

prompt Trigger for SGLD_Chr_Map_Assocs API

@load-trgs/Chr_Map_Assocs.trg

