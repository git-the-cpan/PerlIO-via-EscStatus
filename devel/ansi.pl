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
use Regexp::Common 'ANSIescape';

my $str = "\e[30m";
my $re = $RE{ANSIescape}{-keep};

require Data::Dumper;
print Data::Dumper::Dumper("$re");
$Data::Dumper::Useqq = 1;

if ($str =~ /$re/o) {
  print "match\n";
  print Data::Dumper::Dumper($1);
  print Data::Dumper::Dumper($2);
  print Data::Dumper::Dumper($3);
} else {
  print "no match\n";
}
exit 0;
