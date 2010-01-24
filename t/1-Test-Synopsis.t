#!/usr/bin/perl

# Copyright 2009, 2010 Kevin Ryde

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


## no critic (ProhibitCallsToUndeclaredSubs)

use strict;
use warnings;
use Test::More;

eval 'use Test::Synopsis; 1'
  or plan skip_all => "due to Test::Synopsis not available -- $@";

plan tests => 5;

# exclude lib/ProgressMonitor/Stringify/ToEscStatus.pm as its synopsis code
# depends on ProgressMonitor
#
synopsis_ok('lib/PerlIO/via/EscStatus.pm');
synopsis_ok('lib/PerlIO/via/EscStatus/ShowAll.pm');
synopsis_ok('lib/PerlIO/via/EscStatus/ShowNone.pm');
synopsis_ok('lib/PerlIO/via/EscStatus/Parser.pm');
synopsis_ok('lib/Regexp/Common/ANSIescape.pm');

exit 0;
