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

package TidyAll::Plugin::OTOBO::Perl::SortKeys;

use strict;
use warnings;

## nofilter(TidyAll::Plugin::OTOBO::Perl::SortKeys)

use File::Basename;

use parent qw(TidyAll::Plugin::OTOBO::Perl);

=head1 SYNOPSIS

This module inserts a sort statements to lines like

    for my $Module (sort keys %Modules) ...

because the keys randomness can be a source of problems
that is hard to debug.

=cut

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    $Code =~ s{ ^ (\s* for \s+ my \s+ \$ \w+ \s+ \( \s*) keys \s+ }{$1sort keys }xmsg;
    $Code =~ s{ ^ (\s* for \s+ \( \s*) keys \s+ }{$1sort keys }xmsg;

    return $Code;
}

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my ( $Counter, $ErrorMessage );

    LINE:
    for my $Line ( split( /\n/, $Code ) ) {
        $Counter++;

        if ( $Line =~ m{ (?: sort)?[ ]keys \s+ [\$|\\] }xms ) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
    }

    if ($ErrorMessage) {
        return $Self->DieWithError(<<"EOF");
Dont use hash references while accesing its keys
$ErrorMessage
EOF
    }

    return;
}

1;
