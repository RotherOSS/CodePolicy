# --
# OTOBO is a web-based ticketing system for service organisations.
# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# Copyright (C) 2019-2021 Rother OSS GmbH, https://otobo.de/
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

package TidyAll::Plugin::OTOBO::XML::Configuration::Navigation;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTOBO::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return       if $Self->IsFrameworkVersionLessThan( 6, 0 );

    my ( $Counter, $ErrorMessage );

    my $CurrentSettingName;

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;

        if ( $Line =~ m{<Setting\s+Name="(.*?)"}smx ) {
            $CurrentSettingName = $1;
        }
        my ($NavigationContent) = $Line =~ m{<Navigation>(.*?)</Navigation>}smx;

        next LINE if !$NavigationContent;

        my @Rules = (
            {
                Name                   => 'Valid toplevel entries',
                MatchSettingName       => qr{.*},
                MatchNavigationValue   => qr{.*},
                RequireNavigationMatch => qr{^(CloudService|Core|Daemon|GenericInterface|Frontend|WebApp)(::|$)},
                ErrorMessage =>
                    'Invalid top level group found (only CloudService|Core|Daemon|GenericInterface|Frontend|WebApp are allowed).',
            },
            {
                Name                   => 'Event handlers',
                MatchSettingName       => qr{::EventModule},
                MatchNavigationValue   => qr{.*},
                RequireNavigationMatch => qr{^Core::Event::},
                ErrorMessage           => "Event handler registrations should be grouped in 'Core::Event::*.",
            },
            {
                Name                   => 'Valid Frontend subgroups',
                MatchSettingName       => qr{.*},
                MatchNavigationValue   => qr{^Frontend},                                                      # no entries allowed in "Frontend" directly
                RequireNavigationMatch => qr{^Frontend::(Admin|Agent|Base|Customer|Public|External)(::|$)},
                ErrorMessage =>
                    'Invalid top Frontend subgroup found (only Admin|Agent|Base|Customer|Public|External are allowed).',
            },
            {
                Name                   => 'Main Loader config',
                MatchSettingName       => qr{^Loader::(Agent|Customer|Enabled)},
                MatchNavigationValue   => qr{.*},
                RequireNavigationMatch => qr{^Frontend::Base::Loader$},
                ErrorMessage           => "Main Loader settings should be grouped in 'Frontend::Base::Loader'.",
            },
            {
                Name                   => 'Loader config for Admin interface',
                MatchSettingName       => qr{^Loader::Module::Admin},
                MatchNavigationValue   => qr{.*},
                RequireNavigationMatch => qr{^Frontend::Admin::ModuleRegistration::Loader},
                ErrorMessage =>
                    "Loader config for Admin interface should be grouped in 'Frontend::Admin::ModuleRegistration::Loader'.",
            },
            {
                Name                   => 'Loader config for Agent interface',
                MatchSettingName       => qr{^Loader::Module::Agent},
                MatchNavigationValue   => qr{.*},
                RequireNavigationMatch => qr{^Frontend::Agent::ModuleRegistration::Loader},
                ErrorMessage =>
                    "Loader settings for Agent interface should be grouped in 'Frontend::Agent::ModuleRegistration::Loader'.",
            },
            {
                Name                   => 'Loader config for Customer interface',
                MatchSettingName       => qr{^Loader::Module::Customer},
                MatchNavigationValue   => qr{.*},
                RequireNavigationMatch => qr{^Frontend::Customer::ModuleRegistration::Loader},
                ErrorMessage =>
                    "Loader settings for Customer interface should be grouped in 'Frontend::Customer::ModuleRegistration::Loader'.",
            },
            {
                Name                   => 'Loader config for Public interface',
                MatchSettingName       => qr{^Loader::Module::Public},
                MatchNavigationValue   => qr{.*},
                RequireNavigationMatch => qr{^Frontend::Public::ModuleRegistration},
                ErrorMessage =>
                    "Loader settings for Public interface should be grouped in 'Frontend::Public::ModuleRegistration'.",
            },
            {
                Name                   => 'Frontend navigation config for Admin interface',
                MatchSettingName       => qr{^Frontend::Navigation###Admin},
                MatchNavigationValue   => qr{.*},
                RequireNavigationMatch => qr{^Frontend::Admin::ModuleRegistration::MainMenu},
                ErrorMessage =>
                    "Frontend navigation config for Admin interface should be grouped in 'Frontend::Admin::ModuleRegistration::MainMenu'.",
            },
            {
                Name                   => 'Frontend navigation config for Agent interface',
                MatchSettingName       => qr{^Frontend::Navigation###Agent},
                MatchNavigationValue   => qr{.*},
                RequireNavigationMatch => qr{^Frontend::Agent::ModuleRegistration::MainMenu},
                ErrorMessage =>
                    "Frontend navigation config for Agent interface should be grouped in 'Frontend::Agent::ModuleRegistration::MainMenu'.",
            },
            {
                Name                   => 'Frontend navigation config for Customer interface',
                MatchSettingName       => qr{^CustomerFrontend::Navigation###Customer},
                MatchNavigationValue   => qr{.*},
                RequireNavigationMatch => qr{^Frontend::Customer::ModuleRegistration::MainMenu},
                ErrorMessage =>
                    "Frontend navigation config for Customer interface should be grouped in 'Frontend::Customer::ModuleRegistration::MainMenu'.",
            },
            {
                Name                   => 'Frontend navigation config for Public interface',
                MatchSettingName       => qr{^PublicFrontend::(Module|Navigation)},
                MatchNavigationValue   => qr{.*},
                RequireNavigationMatch => qr{^Frontend::Public::ModuleRegistration},
                ErrorMessage =>
                    "Module registration config for Public interface should be grouped in 'Frontend::Public::ModuleRegistration'.",
            },
            {
                Name                   => 'Navigation module config',
                MatchSettingName       => qr{^Frontend::NavigationModule},
                MatchNavigationValue   => qr{.*},
                RequireNavigationMatch => qr{^Frontend::Admin::ModuleRegistration::AdminOverview},
                ErrorMessage =>
                    "Navigation module config should be grouped in 'Frontend::Admin::ModuleRegistration::AdminOverview'.",
            },
            {
                Name                   => 'Search router config for Admin interface',
                MatchSettingName       => qr{^Frontend::Search.*?###Admin},
                MatchNavigationValue   => qr{.*},
                RequireNavigationMatch => qr{^Frontend::Admin::ModuleRegistration::MainMenu::Search},
                ErrorMessage =>
                    "Search router config for Admin interface should be grouped in 'Frontend::Admin::ModuleRegistration::Search'.",
            },
            {
                Name                   => 'Search router config for Agent interface',
                MatchSettingName       => qr{^Frontend::Search.*?###Agent},
                MatchNavigationValue   => qr{.*},
                RequireNavigationMatch => qr{^Frontend::Agent::ModuleRegistration::MainMenu::Search},
                ErrorMessage =>
                    "Search router config for Agent interface should be grouped in 'Frontend::Agent::ModuleRegistration::Search'.",
            },
            {
                Name                   => 'Output filters',
                MatchSettingName       => qr{(Output::Filter|OutputFilter)},
                MatchNavigationValue   => qr{.*},
                RequireNavigationMatch => qr{^Frontend::Base::OutputFilter},
                ErrorMessage =>
                    "Output filter settings should be grouped in 'Frontend::Base::OutputFilter' or subgroups.",
            },
            {
                Name                   => 'Valid frontend views',
                MatchSettingName       => qr{.*},
                MatchNavigationValue   => qr{^Frontend::(Admin|Agent|Customer|Public)::(.+::)*View.+$},
                RequireNavigationMatch => qr{^Frontend::(Admin|Agent|Customer|Public)::View::.+$},
                ErrorMessage =>
                    "Screen specific settings should be added in Frontend::(Admin|Agent|Customer|Public)::View.",
            },
        );

        RULE:
        for my $Rule (@Rules) {
            next RULE if $CurrentSettingName !~ $Rule->{MatchSettingName};
            next RULE if $NavigationContent  !~ $Rule->{MatchNavigationValue};

            if (
                $Rule->{SkipForFrameworkVersionLessThan}
                && $Self->IsFrameworkVersionLessThan( @{ $Rule->{SkipForFrameworkVersionLessThan} } )
                )
            {
                next RULE;
            }

            if ( $NavigationContent !~ $Rule->{RequireNavigationMatch} ) {
                $ErrorMessage
                    .= "Invalid navigation value found for setting $CurrentSettingName: $Rule->{ErrorMessage}\n";
                $ErrorMessage .= "Line $Counter: $Line\n";
            }
        }
    }

    if ($ErrorMessage) {
        return $Self->DieWithError(<<"EOF");
Problems were found in the navigation structure of the XML configuration:
$ErrorMessage
EOF
    }

    return;
}

1;
