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


# Usage: ./term-sprog.pl
#
# This is a bit of fun putting Term::Sprog status strings through EscStatus.
#
# Normally Term::Sprog prints its own backspace overwriting, but you can get
# strings with $sprog->get_line, strip off the backspacing, and put it
# through EscStatus.
#
# The "freq" parameter doesn't apply when using $sprog->get_line, you have
# to manage output update frequency yourself, ie. print only every 1 second
# or whatever (as per "OTHER NOTES" in the PerlIO::via::EscStatus docs).
#

use strict;
use warnings;
use PerlIO::via::EscStatus qw(print_status);
use Term::Sprog;
use Time::HiRes 'usleep';

binmode (STDOUT, ':via(EscStatus)')
  or die "Cannot push EscStatus layer: $!";

sub undo_sprog_backspaces {
  my ($str) = @_;
  $str =~ s/([\b]+) +\1//;
  return $str;
}

my $target = 500;
my $sprog = Term::Sprog->new ('%d %3c records, %5t elapsed, [%10b] %3p',
                              {base   => 0,
                               target => $target,
                               quiet   => 1})
  or die "Term::Sprog error ${Term::Sprog::errcode}: $Term::Sprog::errmsg";

# initial status
print_status undo_sprog_backspaces($sprog->get_line);

my $step = 75;
my $r = 0;
while ($r < $target) {
  if ($r == 300) { print "Past half way\n"; }
  sleep 1;

  $r += $step;
  $sprog->up ($step);

  # new status, if there is one to show yet
  if (my $status = $sprog->get_line) {
    print_status undo_sprog_backspaces($status);
  }
}

print_status '';
exit 0;
