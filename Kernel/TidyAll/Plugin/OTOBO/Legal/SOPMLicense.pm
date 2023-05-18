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

package TidyAll::Plugin::OTOBO::Legal::SOPMLicense;

use strict;
use warnings;

use Moo;

extends qw(TidyAll::Plugin::OTOBO::Base);

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # Replace license with GPL3
    $Code
        =~ s{<License> .*? </License>}{<License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>}gsmx;

    return $Code;
}

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    if ( $Code !~ m{<License> .+? </License>}smx ) {
        return $Self->DieWithError("Could not find a valid OPM license header.");
    }

    if (
        $Code
        !~ m{<License>GNU \s GENERAL \s PUBLIC \s LICENSE \s Version \s 3, \s 29 \s June \s 2007</License>}smx
        )
    {
        return $Self->DieWithError(<<"EOF");
Invalid license found.
Use <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>.
EOF
    }

    return;
}

1;
