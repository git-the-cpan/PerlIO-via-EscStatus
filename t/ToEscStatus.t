#!/usr/bin/perl

# Copyright 2008 Kevin Ryde

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

if (eval { require ProgressMonitor; 1 }) {
  plan tests => 4;
} else {
  plan skip_all => "ProgressMonitor not installed: $@";
}

require ProgressMonitor::Stringify::ToEscStatus;
ok ($ProgressMonitor::Stringify::ToEscStatus::VERSION >= 1);
ok (ProgressMonitor::Stringify::ToEscStatus->VERSION >= 1);

ok (ProgressMonitor::Stringify::ToEscStatus->new);

ok (! eval { ProgressMonitor::Stringify::ToEscStatus->new({stream=>123}); 1},
    'bad stream file handle');

exit 0;
