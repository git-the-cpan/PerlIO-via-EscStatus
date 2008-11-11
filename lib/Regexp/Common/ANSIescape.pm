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

package Regexp::Common::ANSIescape;
use strict;
use warnings;
use Carp;
use Regexp::Common ('no_defaults', # no $RE import
                    'pattern');    # pattern func

our $VERSION = 3;

## no critic (ProhibitEscapedCharacters)

use constant {
  CSI_7BIT => "\e\\\x{5B}",  # ie. Esc and a literal [ char
  CSI_8BIT => "\x{9B}",

  # C1 Esc @ through Esc _
  # excluding CSI which is Esc 0x5B, and 0x9B
  # Note \x{5C} is "\" so doubled to escape.
  #
  C1_ALL_7BIT => "\e[\x{40}-\x{5A}\\\x{5C}-\x{5F}]",
  C1_ALL_8BIT =>   "[\x{80}-\x{9A}\x{9C}-\x{9F}]",

  # C1 forms taking a string parameter
  #
  #   DCS   Esc P  (0x50 / 0x90)
  #   SOS   Esc X  (0x58 / 0x98)
  #   OSC   Esc ]  (0x5D / 0x9D)
  #   PM    Esc ^  (0x5E / 0x9E)
  #   APC   Esc _  (0x5F / 0x9F)
  #
  # Note \x{5D} "]" first in the char class, and \x{5E} "^" not first.
  #
  C1_STR_7BIT => "\e[\x{5D}\x{50}\x{58}\x{5E}\x{5F}]",
  C1_STR_8BIT =>   "[\x{9D}\x{90}\x{98}\x{9E}\x{9F}]",

  # C1 forms not taking a string parameter
  # ie. C1_ALL except the five in C1_STR (and not CSI 0x5B,0x9B)
  # Note \x{5C} "\" doubled to escape.
  #
  C1_NST_7BIT => "\e[\x{40}-\x{4F}\x{51}-\x{57}\x{59}\x{5A}\\\x{5C}]",
  C1_NST_8BIT =>   "[\x{80}-\x{8F}\x{91}-\x{97}\x{99}\x{9A}\x{9C}]",

  # ST string terminator
  ST_7BIT => "\e\\\\",  # ie. Esc and a backslash
  ST_8BIT => "\x{9C}",
};

use constant {
  CSI_7OR8    => '(?:'. CSI_7BIT    .'|'. CSI_8BIT    .')',
  C1_STR_7OR8 => '(?:'. C1_STR_7BIT .'|'. C1_STR_8BIT .')',
  ST_7OR8     => '(?:'. ST_7BIT     .'|'. ST_8BIT     .')',
};

pattern (name   => ['ANSIescape'],
         create => sub {
           my ($self, $flags) = @_;

           if (exists $flags->{-only7bit} && exists $flags->{-only8bit}) {
             croak 'ANSIescape: cannot have only7bit and only8bit at the same time';
           }

           my @ret;
           push @ret, (exists $flags->{-only7bit}   ? CSI_7BIT  # 7-bit only
                       : exists $flags->{-only8bit} ? CSI_8BIT  # 8-bit only
                       :                              CSI_7OR8) # 7bit or 8bit
           . "(?k:[0-9;]*)(?k:[\x{20}-\x{2F}]*[\x{40}-\x{7E}])";

           if (exists $flags->{-sepstring}) {
             if (! exists $flags->{-only8bit}) { push @ret, C1_ALL_7BIT; }
             if (! exists $flags->{-only7bit}) { push @ret, C1_ALL_8BIT; }
             
           } else {
             if (! exists $flags->{-only8bit}) { push @ret, C1_NST_7BIT; }
             if (! exists $flags->{-only7bit}) { push @ret, C1_NST_8BIT; }
             
             if (exists $flags->{-only7bit}) {
               push @ret, C1_STR_7BIT . '.*?' . ST_7BIT;   # 7-bit only
             } elsif (exists $flags->{-only8bit}) {
               push @ret, C1_STR_8BIT . '.*?' . ST_8BIT;   # 8-bit only
             } else {
               push @ret, C1_STR_7OR8 . '.*?' . ST_7OR8;   # 7-bit or 8-bit
             }
           }
           return '(?k:' . join('|',@ret) . ')';
         });

1;

__END__

=head1 NAME

Regexp::Common::ANSIescape -- regexps for ANSI terminal escapes

=head1 SYNOPSIS

 use Regexp::Common 'ANSIescape';

 if ($str =~ /$RE{ANSIescape}/) {
    ...
 }

 my $re1 = $RE{ANSIescape}{-only7bit};
 my $re2 = $RE{ANSIescape}{-sepstring};

=head1 DESCRIPTION

An ANSIescape pattern matches an ANSI terminal escape sequence like

    Esc[30;48m             # CSI sequence
    EscU                   # C1 control
    Esc_ APPSTRING Esc\    # C1 with string param

    \x9B 30m               # ditto in 8-bit forms
    \x85
    \x9F APPSTRING \x9C         

The 8-bit forms use bytes C<"\x80"> through C<"\x9F">.  Those bytes are
unused in Unicode and the ISO-8859 character sets (Latin-1 etc), so the
regexp won't match ordinary characters.  The C<-only7bit> option below can
omit the 8-bit patterns if you're working with some other charset.  The
7-bit patterns are all simply Esc followed by various combinations of
printable ASCII C<"\x20"> through C<"\x7E">.

=head1 OPTIONS

=over 4

=item C<{-only7bit}>

=item C<{-only8bit}>

Match only the 7-bit forms like C<"\eE">, or only the 8-bit forms like
C<"\x{85}">.  The default is to match both.  The 7-bit forms are the most
common.

=item C<{-sepstring}>

By default the string parameter to APC, DCS, OSC, PM and SOS sequences is
included in the match, for example an APC like "\x{9F}Stringarg\x{9C}".
With C<-sepstring> the pattern instead matches the "\x{9F}" and the
terminator "\x{9C}" individually, leaving the C<Stringarg> unmatched.

=item C<{-keep}>

With the standard C<-keep> option parens are included to set the following
capture variables

=over 4

=item C<$1>

The entire escape sequence.

=item C<$2>

The numeric parameters to a CSI sequence.  For example C<"\e[30;49m"> gives
C<$2> as C<"30;49">.

=item C<$3>

Intermediate characters (if any) and final character of a CSI escape.  For
example C<"\e[30m"> gives C<$3> as C<"m">, or with a "+" intermediate byte
C<< "\e[30+P" >> gives C<$3> as C<< "+P" >>.

=back

=back

=head1 SEE ALSO

L<Regexp::Common>

The ANSI standard can be obtained as ECMA-48 at
L<http://www.ecma-international.org/publications/standards/Ecma-048.htm>

=head1 HOME PAGE

L<http://www.geocities.com/user42_kevin/perlio-via-escstatus/index.html>

=head1 LICENSE

Copyright 2008 Kevin Ryde

PerlIO-via-EscStatus is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 3, or (at your option) any later
version.

PerlIO-via-EscStatus is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
PerlIO-via-EscStatus.  If not, see L<http://www.gnu.org/licenses/>.

=cut
