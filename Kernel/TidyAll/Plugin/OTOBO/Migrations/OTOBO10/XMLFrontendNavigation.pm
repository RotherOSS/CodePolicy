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

package TidyAll::Plugin::OTOBO::Migrations::OTOBO10::XMLFrontendNavigation;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTOBO::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    # active only for OTOBO 10
    return unless $Self->IsFrameworkVersionLessThan( 11, 0 );

    my ( $Counter, $ErrorMessage );

    my ( $CurrentSettingName, $InValue, $ValueContent );

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;

        if ( $Line =~ m{<Setting\s+Name="(.*?)"}smx ) {
            $CurrentSettingName = $1;
            $InValue            = 0;
            $ValueContent       = '';
        }

        $InValue = 1 if $Line =~ m{<Value>};
        $ValueContent .= "\n" . $Line if $InValue;
        $InValue = 0 if $Line =~ m{</Value>};

        next LINE if !$ValueContent || $InValue;

        my @Rules = (
            {
                Name                     => 'Valid toplevel entries',
                MatchSettingName         => qr{^(Customer|Public)?Frontend::Navigation###.*},
                RequireValueContentMatch => qr{<Array>.*<DefaultItem[^>]+ValueType="FrontendNavigation"}sm,
            },
        );

        RULE:
        for my $Rule (@Rules) {
            next RULE if $CurrentSettingName !~ $Rule->{MatchSettingName};

            if ( $ValueContent !~ $Rule->{RequireValueContentMatch} ) {
                $ErrorMessage
                    .= "Incorrect main menu registration found in setting $CurrentSettingName:$ValueContent\n";
            }
        }
    }

    if ($ErrorMessage) {
        return $Self->DieWithError(<<"EOF");
Problems were found in the structure of the XML configuration:
$ErrorMessage
EOF
    }

    return;
}

1;
