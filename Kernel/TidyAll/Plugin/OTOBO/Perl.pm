# --
# OTOBO is a web-based ticketing system for service organisations.
# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# Copyright (C) 2019-2023 Rother OSS GmbH, https://otobo.de/
# --
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
# --

package TidyAll::Plugin::OTOBO::Perl;

use strict;
use warnings;
use v5.24;
use utf8;

use Moo;

extends qw(TidyAll::Plugin::OTOBO::Base);

use Pod::Strip();

# Process Perl code and replace all Pod sections with comments.
sub StripPod {
    my ( $Self, %Param ) = @_;

    my $PodStrip = Pod::Strip->new();
    $PodStrip->replace_with_comments(1);
    my $Code;
    $PodStrip->output_string( \$Code );
    $PodStrip->parse_string_document( $Param{Code} );
    return $Code;
}

sub StripComments {
    my ( $Self, %Param ) = @_;

    my $Code = $Param{Code};
    $Code =~ s/^ \s* \# .*? $/\n/smxg;
    return $Code;
}

1;
