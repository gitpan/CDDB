#!/usr/bin/perl
# $Id: Makefile.PL,v 1.3 2001/03/25 03:48:15 troc Exp troc $

use ExtUtils::MakeMaker;

WriteMakefile
  ( NAME         => 'CDDB',
    AUTHOR       => 'Rocco Caputo <troc+cddb@netrus.net>',
    ABSTRACT     => 'High-level interface to CDDB and freedb servers.',
    VERSION_FROM => 'CDDB.pm',
    dist         => { COMPRESS => 'gzip -9',
                      SUFFIX   => 'gz',
                    },
  );
