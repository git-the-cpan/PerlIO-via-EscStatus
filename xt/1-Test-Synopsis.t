#!/usr/bin/perl -w

# Copyright 2009, 2010, 2011, 2012 Kevin Ryde

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


use strict;
use warnings;
use Test::More;

eval 'use Test::Synopsis; 1'
  or plan skip_all => "due to Test::Synopsis not available -- $@";

my $manifest = ExtUtils::Manifest::maniread();
my @files = grep {m{^lib/.*\.pm$}} keys %$manifest;

if (! eval { require ProgressMonitor }) {
  diag "skip ProgressMonitor::Stringify::ToEscStatus since ProgressMonitor.pm not available -- $@";
  @files = grep {! m{/ProgressMonitor/Stringify/ToEscStatus.pm} } @files;
}

plan tests => 1 * scalar @files;

Test::Synopsis::synopsis_ok(@files);
exit 0;
