--
-- SQL script to load the API, consisting of views, packages, and triggers.
--
-- $Id$
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

--
-- Load the packages.
--
@BS-create-pkg

--
-- Load the views.
--
@BS-create-load-API

--
-- Load the triggers.
--
@BS-create-API-triggers

-- Done.

