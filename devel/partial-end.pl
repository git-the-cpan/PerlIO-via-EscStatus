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

my $str = "\e_EscStatus\e\\";

sub regexp_literal_char {
  my ($c) = @_;
  if ($c eq "\e") {
    return "\\e";
  } else {
    return quotemeta($c);
  }
}

sub partial_end {
  my ($str, $level) = @_;

  my $ret = regexp_literal_char (substr ($str, 0, 1));

  for (my $i = 1; $i < length($str); $i++) {
    my $c = substr ($str, $i, 1);
    $ret .= '(?:$|' . regexp_literal_char ($c);
  }
  $ret .= (')' x (length($str)-1));
}

print partial_end($str),"\n";
exit 0;
