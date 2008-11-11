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
use Test::More tests => 966;

ok ($Regexp::Common::ANSIescape::VERSION >= 3);
ok (Regexp::Common::ANSIescape->VERSION  >= 3);


## no critic (ProhibitEscapedCharacters)

{ my $count = 0;
  foreach my $i (0x40 .. 0x5F) {
    my $str = "\e".chr($i);
    if ($str =~ Regexp::Common::ANSIescape::C1_ALL_7BIT) {
      $count++;
    }
  }
  is ($count, 31);
}
{ my $count = 0;
  foreach my $i (0x80 .. 0x9F) {
    my $str = chr($i);
    if ($str =~ Regexp::Common::ANSIescape::C1_ALL_8BIT) {
      $count++;
    }
  }
  is ($count, 31);
}
{ my $s_count = 0;
  my $n_count = 0;
  foreach my $i (0x40 .. 0x5F) {
    my $str = "\e".chr($i);
    my $s = ($str =~ Regexp::Common::ANSIescape::C1_STR_7BIT);
    my $n = ($str =~ Regexp::Common::ANSIescape::C1_NST_7BIT);
    ok (! ($s && $n));
    if ($s) { $s_count++; }
    if ($n) { $n_count++; }
  }
  is ($s_count, 5);
  is ($n_count, 26);
}
{ my $s_count = 0;
  my $n_count = 0;
  foreach my $i (0x80 .. 0x9F) {
    my $str = chr($i);
    my $s = ($str =~ Regexp::Common::ANSIescape::C1_STR_8BIT);
    my $n = ($str =~ Regexp::Common::ANSIescape::C1_NST_8BIT);
    ok (! ($s && $n));
    if ($s) { $s_count++; }
    if ($n) { $n_count++; }
  }
  is ($s_count, 5);
  is ($n_count, 26);
}

{ my $str = "zz\e[34mmm";  # SGR
  ok ($str =~ $RE{ANSIescape}{-keep});
  is ($1, "\e[34m");
  is ($2, "34");
  is ($3, "m");
}
{ my $str = "zz\e[0 mzz";  # SGR with space flag
  ok ($str =~ $RE{ANSIescape}{-keep});
  is ($1, "\e[0 m");
  is ($2, "0");
  is ($3, " m");
}
{ my $str = "zz\e[1;2;3\x{20}\x{21}\x{22}\x{23}\x{24}\x{25}\x{26}\x{27}\x{28}\x{29}\x{2A}\x{2B}\x{2C}\x{2D}\x{2E}\x{2F}mmm";  # SGR with zany flags
  ok ($str =~ $RE{ANSIescape}{-keep});
  is ($1, "\e[1;2;3\x{20}\x{21}\x{22}\x{23}\x{24}\x{25}\x{26}\x{27}\x{28}\x{29}\x{2A}\x{2B}\x{2C}\x{2D}\x{2E}\x{2F}m");
  is ($2, "1;2;3");
  is ($3, "\x{20}\x{21}\x{22}\x{23}\x{24}\x{25}\x{26}\x{27}\x{28}\x{29}\x{2A}\x{2B}\x{2C}\x{2D}\x{2E}\x{2F}m");
}


my @seven = ("zz\e\@zz",    # C1
             "zz\e[34mmm",  # SGR
             "zz\e[0m\e\e", # SGR
             "zz\e[0 mzz",  # SGR with space flag
             "zz\e[0/mzz",  # SGR with / flag
             "zz\e\\aa",    # ST
            );
my @seven_with_string;
my @seven_without_string;

my @eight = ("zz\x{80}zz",    # C1
             "zz\x{9B}30maa", # SGR
             "zz\x{9C}aa",    # ST
            );
my @eight_with_string;
my @eight_without_string;

my @mixed_with_string = ();

# C1 forms taking a string: DCS,SOS,OSC,PM,APC
my @with_string = (0x50,0x58,0x5D,0x5E,0x5F);

# C1 forms not taking a string, and not SGR
my @without_string = do { my %without;
                          @without{0x40 .. 0x5F} = 1;
                          delete @without{@with_string, 0x5B};
                          sort keys %without;
                        };

foreach my $s (@with_string) {
  push @seven_with_string, "zz\e".chr($s)."STRING\e\\zz";
  push @eight_with_string, "zz".chr($s+0x40)."STRING\x{9C}zz";

  push @seven_without_string, "zz\e".chr($s)."zz";
  push @eight_without_string, "zz".chr($s+0x40)."zz";

  push @mixed_with_string, "zz\e]STRING\x{9C}zz";    # 7/8 mixed
  push @mixed_with_string, "zz\x{9D}STRING\e\\zz";   # 8/7 mixed
}
foreach my $s (@without_string) {
  push @seven, "zz\e".chr($s)."zz";
  push @eight, "zz".chr($s+0x40)."zz";
}


foreach my $elem ([$RE{ANSIescape}{-sepstring}{-only8bit}, 'sep8',
                   [ @eight, @eight_without_string ]],

                  [$RE{ANSIescape}{-sepstring}{-only7bit}, 'sep7',
                   [ @seven, @seven_without_string ]],

                  [$RE{ANSIescape}{-sepstring}, 'sep7+8',
                   [ @seven, @seven_without_string,
                     @eight, @eight_without_string ]],

                  [$RE{ANSIescape}, '7+8',
                   [ @seven, @seven_with_string,
                     @eight, @eight_with_string,
                     @mixed_with_string ]],

                  [$RE{ANSIescape}{-only7bit}, 'only7',
                   [ @seven, @seven_with_string ]],

                  [$RE{ANSIescape}{-only8bit}, 'only8',
                   [ @eight, @eight_with_string ]]) {

  my ($re, $name, $strs) = @$elem;
  require Data::Dumper;
  # print "$re\n";

  foreach my $str (@$strs) {
    my $dumper = Data::Dumper->new ([$str],['str']);
    $dumper->Useqq(1);
    my $printstr = $dumper->Dump;

    ok ($str =~ $re,           "$name match $printstr");
    is ($-[0], 2,              "$name match begin $printstr");
    is ($+[0], length($str)-2, "$name match end $printstr");
  }
}

exit 0;
