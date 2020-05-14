# --
# OTOBO is a web-based ticketing system for service organisations.
# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# Copyright (C) 2019-2020 Rother OSS GmbH, https://otobo.de/
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

package TidyAll::Plugin::OTOBO::XML::Configuration::YAMLIndentation;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTOBO::Base);

=head1 SYNOPSIS

This plugin removes any unneeded indentation from YAML.

    ---
        Key:    Value
        SubHash:
            Subkey: Subvalue

will become:

    ---
    Key:    Value
    SubHash:
        Subkey: Subvalue

=cut

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan( 8, 0 );

    $Code =~ s{
        (<Item[^>]+ValueType="YAML"[^>]*>\s*<!\[CDATA\[---\n)
        (.*?)
        ^\s*(\]\]>)\s*(</Item>)}{
            $1.RemoveLeadingWhitespaces($2).$3.$4;
        }exmsg;

    return $Code;
}

sub RemoveLeadingWhitespaces {
    my ($YAMLString) = @_;

    return $YAMLString if !$YAMLString;

    my @Lines = split( m{\n}, $YAMLString );

    # Detect if we have an unneeded common indentation on all lines.
    my $CommonIndent = 1000;
    LINE:
    for my $Line (@Lines) {
        my ($Whitespace) = $Line =~ m{^(\s+)}xms;
        my $WhitespaceLength = length( $Whitespace // '' );
        $CommonIndent = $WhitespaceLength if $CommonIndent > $WhitespaceLength;
    }

    # Remove common indent if found.
    if ($CommonIndent) {
        @Lines = map { substr( $_, $CommonIndent ) } @Lines;
    }

    return join( "\n", @Lines ) . "\n";

}

1;
