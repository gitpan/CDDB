# $Id: Makefile.PL,v 1.1 1998/10/24 02:57:19 troc Exp $

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile
  (
   'NAME'         => 'CDDB',
   'VERSION_FROM' => 'CDDB.pm',
   'dist'         => { 'COMPRESS' => 'gzip -9',
                       'SUFFIX'   => 'gz',
                     },
  );
