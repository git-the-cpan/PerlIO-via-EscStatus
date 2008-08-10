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
use Test::More tests => 473;

use PerlIO::via::EscStatus;

ok ($PerlIO::via::EscStatus::VERSION >= 1);
ok (PerlIO::via::EscStatus->VERSION >= 1);


#------------------------------------------------------------------------------
# _IsZero

## no critic (ProhibitEscapedCharacters)
my $_81_str = "\x{81}";
my $_9B_str = "\x{9B}";
my $_9F_str = "\x{9F}";
my $AD_str  = "\x{AD}";

ok ("\a"       =~ /\p{PerlIO::via::EscStatus::_IsZero}/);
ok ("\r"       =~ /\p{PerlIO::via::EscStatus::_IsZero}/);
ok ("\t"       !~ /\p{PerlIO::via::EscStatus::_IsZero}/);
ok ("\e"       !~ /\p{PerlIO::via::EscStatus::_IsZero}/);
ok ("X"        !~ /\p{PerlIO::via::EscStatus::_IsZero}/);
ok ($_81_str   !~ /\p{PerlIO::via::EscStatus::_IsZero}/);
ok ($_9B_str   !~ /\p{PerlIO::via::EscStatus::_IsZero}/);
ok ($_9F_str   !~ /\p{PerlIO::via::EscStatus::_IsZero}/);
ok ($AD_str    !~ /\p{PerlIO::via::EscStatus::_IsZero}/);
ok ("\x{0300}" =~ /\p{PerlIO::via::EscStatus::_IsZero}/); # Mn
ok ("\x{0488}" =~ /\p{PerlIO::via::EscStatus::_IsZero}/); # Me
ok ("\x{1100}" !~ /\p{PerlIO::via::EscStatus::_IsZero}/); # W
ok ("\x{FF10}" !~ /\p{PerlIO::via::EscStatus::_IsZero}/); # F
ok ("\x{FEFF}" =~ /\p{PerlIO::via::EscStatus::_IsZero}/); # BOM


#------------------------------------------------------------------------------
# _IsDouble

ok ("\a"       !~ /\p{PerlIO::via::EscStatus::_IsDouble}/);
ok ("\r"       !~ /\p{PerlIO::via::EscStatus::_IsDouble}/);
ok ("\t"       !~ /\p{PerlIO::via::EscStatus::_IsDouble}/);
ok ("\e"       !~ /\p{PerlIO::via::EscStatus::_IsDouble}/);
ok ("X"        !~ /\p{PerlIO::via::EscStatus::_IsDouble}/);
ok ($AD_str    !~ /\p{PerlIO::via::EscStatus::_IsDouble}/);
ok ($_81_str   !~ /\p{PerlIO::via::EscStatus::_IsDouble}/);
ok ($_9B_str   !~ /\p{PerlIO::via::EscStatus::_IsDouble}/);
ok ($_9F_str   !~ /\p{PerlIO::via::EscStatus::_IsDouble}/);
ok ("\x{0300}" !~ /\p{PerlIO::via::EscStatus::_IsDouble}/); # Mn
ok ("\x{0488}" !~ /\p{PerlIO::via::EscStatus::_IsDouble}/); # Me
ok ("\x{1100}" =~ /\p{PerlIO::via::EscStatus::_IsDouble}/); # W
ok ("\x{FF10}" =~ /\p{PerlIO::via::EscStatus::_IsDouble}/); # F
ok ("\x{FEFF}" !~ /\p{PerlIO::via::EscStatus::_IsDouble}/); # BOM


#------------------------------------------------------------------------------
# _IsOther

ok ("\a"       !~ /\p{PerlIO::via::EscStatus::_IsOther}/);
ok ("\r"       !~ /\p{PerlIO::via::EscStatus::_IsOther}/);
ok ("\t"       !~ /\p{PerlIO::via::EscStatus::_IsOther}/);
ok ("\e"       !~ /\p{PerlIO::via::EscStatus::_IsOther}/);
ok ("X"        =~ /\p{PerlIO::via::EscStatus::_IsOther}/);
ok ($AD_str    =~ /\p{PerlIO::via::EscStatus::_IsOther}/);
ok ($_81_str   !~ /\p{PerlIO::via::EscStatus::_IsOther}/);
ok ($_9B_str   !~ /\p{PerlIO::via::EscStatus::_IsOther}/);
ok ($_9F_str   !~ /\p{PerlIO::via::EscStatus::_IsOther}/);
ok ("\x{0300}" !~ /\p{PerlIO::via::EscStatus::_IsOther}/); # Mn
ok ("\x{0488}" !~ /\p{PerlIO::via::EscStatus::_IsOther}/); # Me
ok ("\x{1100}" !~ /\p{PerlIO::via::EscStatus::_IsOther}/); # W
ok ("\x{FF10}" !~ /\p{PerlIO::via::EscStatus::_IsOther}/); # F
ok ("\x{FEFF}" !~ /\p{PerlIO::via::EscStatus::_IsOther}/); # BOM


#------------------------------------------------------------------------------
# _trunc

# singles
{ my ($trunc, $cols) = PerlIO::via::EscStatus::_truncate ("", 0);
  is ($trunc, "");
  is ($cols, 0);
}
{ my ($trunc, $cols) = PerlIO::via::EscStatus::_truncate ("xyz", 0);
  is ($trunc, "");
  is ($cols, 0);
}
{ my ($trunc, $cols) = PerlIO::via::EscStatus::_truncate ("xyz", 1);
  is ($trunc, "x");
  is ($cols, 1);
}
{ my ($trunc, $cols) = PerlIO::via::EscStatus::_truncate ("xyz", 2);
  is ($trunc, "xy");
  is ($cols, 2);
}
{ my ($trunc, $cols) = PerlIO::via::EscStatus::_truncate ("xyz", 3);
  is ($trunc, "xyz");
  is ($cols, 3);
}
{ my ($trunc, $cols) = PerlIO::via::EscStatus::_truncate ("xyz", 4);
  is ($trunc, "xyz");
  is ($cols, 3);
}

# doubles
{ my ($trunc, $cols) = PerlIO::via::EscStatus::_truncate
    ("\x{1101}\x{1102}\x{1103}\x{1104}", 5);
  is ($trunc, "\x{1101}\x{1102}");
  is ($cols, 4);
}
{ my ($trunc, $cols) = PerlIO::via::EscStatus::_truncate
    ("\x{1101}\x{1102}\x{1103}\x{1104}\r", 8);
  is ($trunc, "\x{1101}\x{1102}\x{1103}\x{1104}\r");
  is ($cols, 8);
}

# tabs
{ my ($trunc, $cols) = PerlIO::via::EscStatus::_truncate ("\tAB\a", 9);
  is ($trunc, "\tA");
  is ($cols, 9);
}
{ my ($trunc, $cols) = PerlIO::via::EscStatus::_truncate ("ZZ\tAB\a", 9);
  is ($trunc, "ZZ\tA");
  is ($cols, 9);
}

# ANSI
{ my ($trunc, $cols) = PerlIO::via::EscStatus::_truncate ("\e[34mfoo\e[0m", 3);
  is ($trunc, "\e[34mfoo\e[0m");
  is ($cols, 3);
}
{ my ($trunc, $cols) = PerlIO::via::EscStatus::_truncate ("\e[34mfoobar\e[0m", 3);
  is ($trunc, "\e[34mfoo\e[0m");
  is ($cols, 3);
}
{ my ($trunc, $cols) = PerlIO::via::EscStatus::_truncate ("\x{9B}35mfoobar\x{9B}30m", 3);
  is ($trunc, "\x{9B}35mfoo\x{9B}30m");
  is ($cols, 3);
}
{ my ($trunc, $cols) = PerlIO::via::EscStatus::_truncate ("\e[34m\e[0mfoobar", 3);
  is ($trunc, "\e[34m\e[0mfoo");
  is ($cols, 3);
}

# non-ANSI Esc, counted as width one
{ my ($trunc, $cols) = PerlIO::via::EscStatus::_truncate ("\eXYZ", 3);
  is ($trunc, "\eXY");
  is ($cols, 3);
}

# mixture
{ my ($trunc, $cols) = PerlIO::via::EscStatus::_truncate ("\x{1100}", 1);
  is ($trunc, "");
  is ($cols, 0);
}
{ my ($trunc, $cols) = PerlIO::via::EscStatus::_truncate ("\x{1100}", 2);
  is ($trunc, "\x{1100}");
  is ($cols, 2);
}
{ my ($trunc, $cols) = PerlIO::via::EscStatus::_truncate ("Z\x{1100}", 2);
  is ($trunc, "Z");
  is ($cols, 1);
}
{ my ($trunc, $cols) = PerlIO::via::EscStatus::_truncate ("Z\a", 1);
  is ($trunc, "Z\a");
  is ($cols, 1);
}
{ my $str = ("\x{FF10}\x{FF11}\x{FF12}\x{FF13}\x{FF14}"
             . "\x{FF15}\x{FF16}\x{FF17}\x{FF18}\x{FF19}") x 20;
  my ($trunc, $cols) = PerlIO::via::EscStatus::_truncate ($str, 79);
  is ($trunc, substr($str,0,39));
  is ($cols, 78);
}
{
  foreach my $i (0x20 .. 0x7F, 0xA0 .. 0xFF) {
    my $str = chr($i); # byte, without utf8 flag
    my ($trunc, $cols) = PerlIO::via::EscStatus::_truncate ($str, 1);
    is ($trunc, $str);
    is ($cols, 1);
  }
}


#------------------------------------------------------------------------------
# FLUSH propagation

package PerlIO::via::MyLowlevel;
use strict;
use warnings;

sub PUSHED {
  my ($class, $mode, $fh) = @_;
  return bless {}, $class;
}

my $saw_flush = 0;
sub saw_flush { return $saw_flush; }
sub reset_saw { $saw_flush = 0; }

sub FLUSH {
  my ($self, $fh) = @_;
  # print STDERR "MyLowlevel: FLUSH\n";
  $saw_flush = 1;
  return 0; # success
}

sub WRITE {
  my ($self, $buf, $fh) = @_;
  # print STDERR "MyLowlevel: WRITE ",length($buf),"\n";
  return length ($buf);
}

package main;
use strict;
use warnings;

# the first two here just to make sure the test framework is doing what it
# should
{
  open (my $out, '> :via(MyLowlevel)', '/dev/null') or die;

  require IO::Handle;
  PerlIO::via::MyLowlevel::reset_saw();
  $out->flush;
  is (PerlIO::via::MyLowlevel::saw_flush(),
      1,
      'bare MyLowlevel sees flush call');
  close $out or die;
}
{
  print "with encoding\n";
  open (my $out, '> :via(MyLowlevel) :encoding(latin-1)', '/dev/null') or die;

  print $out "x";
  PerlIO::via::MyLowlevel::reset_saw();
  $out->flush;
  is (PerlIO::via::MyLowlevel::saw_flush(),
      1,
      'with encoding on top see flush call');

  close $out or die;
}
{
  print "with ttystatus\n";
  open (my $out, '> :via(MyLowlevel) :via(EscStatus)', '/dev/null') or die;

  print $out "x";
  PerlIO::via::MyLowlevel::reset_saw();
  $out->flush;
  is (PerlIO::via::MyLowlevel::saw_flush(),
      1,
      'with EscStatus on top see flush call');
  close $out or die;
}


#------------------------------------------------------------------------------
# _term_width fd use

sub next_fd {
  require POSIX;
  my $next_fd = POSIX::dup(0);
  POSIX::close ($next_fd);
  return $next_fd;
}

{
  my $fd1 = next_fd();
  PerlIO::via::EscStatus::_term_width (\*STDIN);
  my $fd2 = next_fd();
  is ($fd1, $fd2);
}

#------------------------------------------------------------------------------
# to string

{
 SKIP: {
    if ($] < 5.008) { skip "due to no string opens in Perl $]", 1; }
    my $buf = '';
    open my $out, '>', \$buf or die;
    binmode ($out, ':via(EscStatus)') or die;
    print $out PerlIO::via::EscStatus::make_status('hello');
    ok (close $out,
        'close with status showing');
  }
}

exit 0;
