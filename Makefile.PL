#!/usr/bin/perl
# $Id: Makefile.PL,v 1.2 2000/03/27 23:24:17 troc Exp $

use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence the
# contents of the Makefile that is written.

WriteMakefile
  ( NAME         => 'CDDB',
    AUTHOR       => 'Rocco Caputo <troc+cddb@netrus.net>',
    ABSTRACT     => 'High-level object interface to CDDB servers.',
    VERSION_FROM => 'CDDB.pm',
    dist         => { COMPRESS => 'gzip -9',
                      SUFFIX   => 'gz',
                    },
  );
