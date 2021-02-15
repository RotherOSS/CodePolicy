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

use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::OTOBOCodePolicyPlugins;

my $SettingTemplate = <<'EOF';
        <Description Translatable="1">Test config setting definition for purposes of the unit testing.</Description>
        <Navigation>Core::Test</Navigation>
        <Value>
            <Hash>
                <Item Key="Key">Value</Item>
            </Hash>
        </Value>
EOF

my @Tests = (
    {
        Name      => 'Obsolete frontend setting - Valid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Migrations::OTOBO7::DeprecatedSettings)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="PublicFrontend::Module###PublicFAQExplorer" Required="1" Valid="1">
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 0,
    },
    {
        Name      => 'Obsolete frontend setting - Valid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Migrations::OTOBO7::DeprecatedSettings)],
        Framework => '7.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="PublicFrontend::Module###PublicFAQExplorer" Required="1" Valid="1">
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 1,
    },
    {
        Name      => 'Obsolete loader setting - Valid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Migrations::OTOBO7::DeprecatedSettings)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="Loader::Customer::SelectedSkin" Required="1" Valid="1">
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 0,
    },
    {
        Name      => 'Obsolete loader setting - Valid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Migrations::OTOBO7::DeprecatedSettings)],
        Framework => '7.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="Loader::Customer::SelectedSkin" Required="1" Valid="1">
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 1,
    },
    {
        Name      => 'Obsolete loader module setting - Valid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Migrations::OTOBO7::DeprecatedSettings)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="Loader::Module::CustomerTicketMessage###002-Ticket" Required="1" Valid="1">
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 0,
    },
    {
        Name      => 'Obsolete loader module setting - Valid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Migrations::OTOBO7::DeprecatedSettings)],
        Framework => '7.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="Loader::Module::CustomerTicketMessage###002-Ticket" Required="1" Valid="1">
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 1,
    },
    {
        Name      => 'Obsolete search router setting - Valid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Migrations::OTOBO7::DeprecatedSettings)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="Frontend::Search::JavaScript###AgentCustomerInformationCenter" Required="1" Valid="1">
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 0,
    },
    {
        Name      => 'Obsolete search router setting - Valid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Migrations::OTOBO7::DeprecatedSettings)],
        Framework => '7.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="Frontend::Search::JavaScript###AgentCustomerInformationCenter" Required="1" Valid="1">
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 1,
    },
);

$Self->scripts::test::OTOBOCodePolicyPlugins::Run( Tests => \@Tests );

1;
