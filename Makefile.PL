#!/usr/bin/perl
# $Id: Makefile.PL,v 1.3 2001/03/25 03:48:15 troc Exp $

use ExtUtils::MakeMaker;

WriteMakefile
  ( NAME         => 'CDDB',
    AUTHOR       => 'Rocco Caputo <troc+cddb@netrus.net>',
    ABSTRACT     => 'High-level object interface to CDDB/FreeDB servers.',
    VERSION_FROM => 'CDDB.pm',
    dist         => { COMPRESS => 'gzip -9',
                      SUFFIX   => 'gz',
                    },
  );
