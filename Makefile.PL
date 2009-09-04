#!/usr/bin/perl

# Copyright 2008, 2009 Kevin Ryde

# This file is part of PerlIO-via-EscStatus.
#
# PerlIO-via-EscStatus is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published
# by the Free Software Foundation; either version 3, or (at your option) any
# later version.
#
# PerlIO-via-EscStatus is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with PerlIO-via-EscStatus.  If not, see <http://www.gnu.org/licenses/>.


# 5.8.5 for unicode properties ...
# otherwise 5.8.1 for utf8::is_utf8
use 5.8.5;
use strict;
use warnings;
use ExtUtils::MakeMaker;
use lib 'inc';
use MyMakeMakerExtras;

WriteMakefile
  (NAME         => 'PerlIO-via-EscStatus',
   ABSTRACT     => 'Printing a status line through an I/O layer.',
   VERSION_FROM => 'lib/PerlIO/via/EscStatus.pm',
   PREREQ_PM    => {
                    # via is builtin in perl 5.8, dunno if it can work
                    # before that anyway
                    'PerlIO::via' => 0,
                    
                    'Regexp::Common' => 0,
                    'Term::Size' => 0,
                    'Encode' => 0,
                   },
   AUTHOR       => 'Kevin Ryde <user42@zip.com.au>',
   LICENSE      => 'gpl',
   SIGN         => 1,

   EXTRA_META => <<'HERE',
recommends:
    Test::Pod: 1.00
    ProgressMonitor: 0
optional_features:
    maximum_tests:
        description: Have "make test" do as much as possible.
        requires:
            Parse::CPAN::Meta: 0
            Test::Pod: 1.00
            Test::NoWarnings: 0
            Test::DistManifest: 0
            Test::YAML::Meta: 0
            YAML: 0
            YAML::Syck: 0
            YAML::Tiny: 0
            YAML::XS: 0
    maximum_examples:
        description: Be able to run all the example programs.
        requires:
            ProgressMonitor: 0
            Term::ANSIColor: 0
            Term::Sk: 0
            Time::HiRes: 0
no_index:
    directory:
        - devel
        - inc
        - t
resources:
    homepage: http://user42.tuxfamily.org/perlio-via-escstatus/index.html
    license: http://www.gnu.org/licenses/gpl.html
HERE
  );


#------------------------------------------------------------------------------
package MY;
sub postamble {
  my ($makemaker) = @_;
  return MyMakeMakerExtras::postamble($makemaker);
}
