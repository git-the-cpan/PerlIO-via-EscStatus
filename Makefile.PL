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


# actually suspect it's 5.8.4 or some such before all the char classes and
# perlio goes well enough ...
use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile
  (NAME         => 'PerlIO::via::EscStatus',
   ABSTRACT     => 'Printing a status line through an I/O layer.',
   VERSION_FROM => 'lib/PerlIO/via/EscStatus.pm',
   PREREQ_PM    => {
                    # via is builtin in perl 5.8, dunno if it can work
                    # before that anyway
                    'PerlIO::via' => 0,
                    
                    'Regexp::Common' => 0,
                    'Term::Size' => 0,
                    'Encode' => 0,
                    'List::Util' => 0,

                    # only for the ProgressMonitor bit actually
                    'Scalar::Util' => 0,

                    # tests
                    'Test::More' => 0,
                    'File::Temp' => 0,
                   },
   AUTHOR       => 'Kevin Ryde <user42@zip.com.au>',
   LICENSE      => 'gpl',
   SIGN         => 1,

   EXTRA_META => <<'HERE',
recommends:
    Test::Pod: 1.00
    ProgressMonitor: 0
no_index:
    directory:
        - devel
resources:
    homepage: http://www.geocities.com/user42_kevin/perlio-via-escstatus/index.html
    license: http://www.gnu.org/licenses/#GPL
HERE
  );

sub MY::postamble {
  return <<'MAKE_FRAG';

LINT_FILES = $(TO_INST_PM) t/*.t examples/*.pl devel/*.pl
lint:
	perl -MO=Lint $(LINT_FILES)
pc:
	-podchecker $(LINT_FILES)
	perlcritic $(LINT_FILES)
unused:
	for i in $(LINT_FILES); do perl -Mwarnings::unused -I lib $$i; done

myman:
	mv MANIFEST MANIFEST.old
	touch SIGNATURE
	(make manifest 2>&1; diff -u MANIFEST.old MANIFEST) |less

# find files in the dist with mod times this year, but without this year in
# the copyright line
copyright-years-check:
	year=`date +%Y`; \
	tar tvfz $(DISTVNAME).tar.gz \
	| egrep '$$year-|debian/copyright' \
	| sed 's:^.*$(DISTVNAME)/::' \
	| (result=0; \
	  while read i; do \
	    case $$i in \
	      '' | */ \
	      | debian/changelog | debian/compat \
	      | t/pod.t \
	      | COPYING | MANIFEST* | SIGNATURE | META.yml) \
	      continue ;; \
	    esac; \
	    if test -e "$(srcdir)/$$i"; then f="$(srcdir)/$$i"; \
	    else f="$$i"; fi; \
	    if ! grep -q "Copyright.*$$year" $$f; then \
	      echo "$$i":"1: this file"; \
	      grep Copyright $$f; \
	      result=1; \
	    fi; \
	  done; \
	  exit $$result)

debug-constants-check:
	if egrep -n 'DEBUG => [^0]' $(TO_INST_PM); then exit 1; else exit 0; fi

diff-prev:
	rm -rf diff.tmp
	mkdir diff.tmp
	cd diff.tmp \
	&& tar xfz ../$(DISTNAME)-`expr $(VERSION) - 1`.tar.gz \
	&& tar xfz ../$(DISTNAME)-$(VERSION).tar.gz
	-cd diff.tmp; diff -ur $(DISTNAME)-`expr $(VERSION) - 1` \
	                       $(DISTNAME)-$(VERSION) >tree.diff
	-less diff.tmp/tree.diff
	rm -rf diff.tmp

MAKE_FRAG
}
