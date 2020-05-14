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

package TidyAll::Plugin::OTOBO::Migrations::OTOBO7::DeprecatedSettings;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTOBO::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 7, 0 );
    return if !$Self->IsFrameworkVersionLessThan( 8, 0 );

    my ( $Counter, $ErrorMessage );

    my $CurrentSettingName;

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;

        next LINE if $Line !~ m{<Setting\s+Name="(.*?)"}smx;

        $CurrentSettingName = $1;

        my @Rules = (
            {
                Name             => 'Obsolete frontend setting',
                MatchSettingName => qr{^(Customer|Public)Frontend::},
                ErrorMessage =>
                    'Obsolete frontend setting, (Public|Customer)Frontend not allowed anymore.',
            },
            {
                Name             => 'Obsolete loader setting',
                MatchSettingName => qr{^Loader::(Customer|Public)},
                ErrorMessage =>
                    'Obsolete loader setting, Loader::(Customer|Public) not allowed anymore.',
            },
            {
                Name             => 'Obsolete loader module setting',
                MatchSettingName => qr{^Loader::Module::(Customer|Public)},
                ErrorMessage =>
                    'Obsolete loader module setting, Loader::Module::(Customer|Public) not allowed anymore.',
            },
            {
                Name             => 'Obsolete search router setting',
                MatchSettingName => qr{^Frontend::Search},
                ErrorMessage =>
                    'Obsolete search router setting, Frontend::Search not allowed anymore.',
            },
        );

        RULE:
        for my $Rule (@Rules) {
            next RULE if $CurrentSettingName !~ $Rule->{MatchSettingName};

            if (
                $Rule->{SkipForFrameworkVersionLessThan}
                && $Self->IsFrameworkVersionLessThan( @{ $Rule->{SkipForFrameworkVersionLessThan} } )
                )
            {
                next RULE;
            }

            $ErrorMessage
                .= "Deprecated setting found $CurrentSettingName: $Rule->{ErrorMessage}\n";
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
    }

    if ($ErrorMessage) {
        return $Self->DieWithError(<<"EOF");
Problems were found in the XML configuration:
$ErrorMessage
EOF
    }

    return;
}

1;
