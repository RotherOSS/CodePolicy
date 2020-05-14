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

package TidyAll::Plugin::OTOBO::Migrations::OTOBO8::UselessComments;

use strict;
use warnings;

use parent 'TidyAll::Plugin::OTOBO::Base';

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan( 8, 0 );
    return $Code if !$Self->IsFrameworkVersionLessThan( 9, 0 );

    my @CleanupRegexes = (
        qr{^[ ]* [#] [ ]+ (?: [gG]et | [cC]heck ) [ ] needed [ ] (?:objects|variables|stuff|params|data) [.]? \n}smx,
        qr{^[ ]* [#] [ ]+ [gG]et [ ] [a-zA-Z0-9_]{2,} [ ] object [.]? \n}smx,
        qr{^[ ]* [#] [ ]+ [gG]et [ ] script [ ] alias [.]? \n}smx,
        qr{^[ ]* [#] [ ]+ [gG]et [ ] valid [ ] list [.]? \n}smx,
        qr{^[ ]* [#] [ ]+ [aA]llocate [ ] new [ ] hash [ ] for [ ] object [.]? \n}smx,
    );

    for my $Regex (@CleanupRegexes) {
        $Code =~ s{$Regex}{}smxg;
    }

    return $Code;
}

1;
