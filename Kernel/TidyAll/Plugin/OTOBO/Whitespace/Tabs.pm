# --
# OTOBO is a web-based ticketing system for service organisations.
# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# Copyright (C) 2019-2024 Rother OSS GmbH, https://otobo.de/
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

package TidyAll::Plugin::OTOBO::Whitespace::Tabs;

use strict;
use warnings;

use Moo;

extends qw(TidyAll::Plugin::OTOBO::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my $Counter = 1;
    my $ErrorMessage;

    #
    # Check for stray tabs
    #
    LINE:
    for my $Line ( split( /\n/, $Code ) ) {

        $Counter++;

        if ( $Line =~ m/\t/ ) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }

    }

    if ($ErrorMessage) {
        return $Self->DieWithError(<<"EOF");
Please substitute all tabulators with four spaces.
$ErrorMessage
EOF
    }
}

1;
