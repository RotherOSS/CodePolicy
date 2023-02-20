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

use strict;
use warnings;
use utf8;

use scripts::test::OTOBOCodePolicyPlugins;

# package variables
our $Self;

my $SettingTemplate = <<'EOF';
        <Description Translatable="1">Test config setting definition for purposes of the unit testing.</Description>
        <Value>
            <Hash>
                <Item Key="Key">Value</Item>
            </Hash>
        </Value>
EOF

my @Tests = (
    {
        Name      => 'Top level entry - Valid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::Navigation)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="Stats::StatsHook" Required="1" Valid="1">
        <Navigation>Core::Stats</Navigation>
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 0,
    },
    {
        Name      => 'Top level entry - Invalid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::Navigation)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="Stats::StatsHook" Required="1" Valid="1">
        <Navigation>Stats::Core</Navigation>
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 1,
    },
    {
        Name      => 'Event handler entry - Valid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::Navigation)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="Package::EventModulePost###9000-SupportDataSend" Required="1" Valid="1">
        <Navigation>Core::Event::Package</Navigation>
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 0,
    },
    {
        Name      => 'Event handler entry - Invalid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::Navigation)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="Package::EventModulePost###9000-SupportDataSend" Required="1" Valid="1">
        <Navigation>Package::Core::Events</Navigation>
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 1,
    },
    {
        Name      => 'Valid frontend subgroup',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::Navigation)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="CustomerFrontend::NotifyModule###9-CustomerNotificationModule" Required="1" Valid="1">
        <Navigation>Frontend::Customer::FrontendNotification</Navigation>
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 0,
    },
    {
        Name      => 'Frontend subgroup - Valid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::Navigation)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="CustomerFrontend::NotifyModule###9-CustomerNotificationModule" Required="1" Valid="1">
        <Navigation>Frontend::Customer::FrontendNotification</Navigation>
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 0,
    },
    {
        Name      => 'Frontend subgroup - Invalid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::Navigation)],
        Framework => '7.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="CustomerFrontend::NotifyModule###9-CustomerNotificationModule" Required="1" Valid="1">
        <Navigation>Frontend::Customer::FrontendNotification</Navigation>
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 1,
    },
    {
        Name      => 'Main loader entry - Valid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::Navigation)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="Loader::Agent::CommonCSS###000-Framework" Required="1" Valid="1">
        <Navigation>Frontend::Base::Loader</Navigation>
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 0,
    },
    {
        Name      => 'Main loader entry - Invalid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::Navigation)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="Loader::Agent::CommonCSS###000-Framework" Required="1" Valid="1">
        <Navigation>Frontend::Agent::Loader</Navigation>
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 1,
    },
    {
        Name      => 'Loader config for Admin interface - Valid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::Navigation)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="Loader::Module::AdminSystemConfiguration###001-Framework" Required="1" Valid="1">
        <Navigation>Frontend::Admin::ModuleRegistration::Loader</Navigation>
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 0,
    },
    {
        Name      => 'Loader config for Admin interface - Invalid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::Navigation)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="Loader::Module::AdminSystemConfiguration###001-Framework" Required="1" Valid="1">
        <Navigation>Frontend::Base::Loader</Navigation>
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 1,
    },
    {
        Name      => 'Loader config for Agent interface - Valid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::Navigation)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="Loader::Module::AgentDashboard###001-Framework" Required="1" Valid="1">
        <Navigation>Frontend::Agent::ModuleRegistration::Loader</Navigation>
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 0,
    },
    {
        Name      => 'Loader config for Agent interface - Invalid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::Navigation)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="Loader::Module::AgentDashboard###001-Framework" Required="1" Valid="1">
        <Navigation>Frontend::Base::Loader</Navigation>
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 1,
    },
    {
        Name      => 'Loader config for Customer interface - Valid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::Navigation)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="Loader::Module::CustomerTicketMessage###002-Ticket" Required="1" Valid="1">
        <Navigation>Frontend::Customer::ModuleRegistration::Loader</Navigation>
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 0,
    },
    {
        Name      => 'Loader config for Customer interface - Invalid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::Navigation)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="Loader::Module::CustomerTicketMessage###002-Ticket" Required="1" Valid="1">
        <Navigation>Frontend::Base::Loader</Navigation>
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 1,
    },
    {
        Name      => 'Loader config for Public interface - Valid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::Navigation)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="Loader::Module::PublicFAQExplorer###002-FAQ" Required="1" Valid="1">
        <Navigation>Frontend::Public::ModuleRegistration</Navigation>
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 0,
    },
    {
        Name      => 'Loader config for Customer interface - Invalid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::Navigation)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="Loader::Module::PublicFAQExplorer###002-FAQ" Required="1" Valid="1">
        <Navigation>Frontend::Base::Loader</Navigation>
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 1,
    },
    {
        Name      => 'Frontend navigation config for Admin interface - Valid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::Navigation)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="Frontend::Navigation###Admin###001-Framework" Required="1" Valid="1">
        <Navigation>Frontend::Admin::ModuleRegistration::MainMenu</Navigation>
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 0,
    },
    {
        Name      => 'Frontend navigation config for Admin interface - Invalid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::Navigation)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="Frontend::Navigation###Admin###001-Framework" Required="1" Valid="1">
        <Navigation>Core::MainMenu</Navigation>
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 1,
    },
    {
        Name      => 'Frontend navigation config for Agent interface - Valid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::Navigation)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="Frontend::Navigation###Agent###001-Framework" Required="1" Valid="1">
        <Navigation>Frontend::Agent::ModuleRegistration::MainMenu</Navigation>
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 0,
    },
    {
        Name      => 'Frontend navigation config for Agent interface - Invalid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::Navigation)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="Frontend::Navigation###Agent###001-Framework" Required="1" Valid="1">
        <Navigation>Core::MainMenu</Navigation>
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 1,
    },
    {
        Name      => 'Frontend navigation config for Customer interface - Valid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::Navigation)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="CustomerFrontend::Navigation###Customer###001-Framework" Required="1" Valid="1">
        <Navigation>Frontend::Customer::ModuleRegistration::MainMenu</Navigation>
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 0,
    },
    {
        Name      => 'Frontend navigation config for Customer interface - Invalid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::Navigation)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="CustomerFrontend::Navigation###Customer###001-Framework" Required="1" Valid="1">
        <Navigation>Core::MainMenu</Navigation>
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 1,
    },
    {
        Name      => 'Frontend navigation config for Public interface - Valid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::Navigation)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="PublicFrontend::Navigation###Public###001-Framework" Required="1" Valid="1">
        <Navigation>Frontend::Public::ModuleRegistration::MainMenu</Navigation>
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 0,
    },
    {
        Name      => 'Frontend navigation config for Public interface - Invalid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::Navigation)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="PublicFrontend::Navigation###Public###001-Framework" Required="1" Valid="1">
        <Navigation>Core::MainMenu</Navigation>
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 1,
    },
    {
        Name      => 'Navigation module config - Valid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::Navigation)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="Frontend::NavigationModule###Admin" Required="1" Valid="1">
        <Navigation>Frontend::Admin::ModuleRegistration::AdminOverview</Navigation>
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 0,
    },
    {
        Name      => 'Navigation module config - Invalid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::Navigation)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="Frontend::NavigationModule###Admin" Required="1" Valid="1">
        <Navigation>Frontend::Admin</Navigation>
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 1,
    },
    {
        Name      => 'Search router config for Admin interface - Valid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::Navigation)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="Frontend::Search###AdminSystemConfiguration" Required="1" Valid="1">
        <Navigation>Frontend::Admin::ModuleRegistration::MainMenu::Search</Navigation>
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 0,
    },
    {
        Name      => 'Search router config for Admin interface - Invalid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::Navigation)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="Frontend::Search###AdminSystemConfiguration" Required="1" Valid="1">
        <Navigation>Frontend::Admin</Navigation>
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 1,
    },
    {
        Name      => 'Search router config for Agent interface - Valid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::Navigation)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="Frontend::Search###AgentCustomerInformationCenter" Required="1" Valid="1">
        <Navigation>Frontend::Agent::ModuleRegistration::MainMenu::Search</Navigation>
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 0,
    },
    {
        Name      => 'Search router config for Agent interface - Invalid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::Navigation)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="Frontend::Search###AgentCustomerInformationCenter" Required="1" Valid="1">
        <Navigation>Frontend::Agent</Navigation>
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 1,
    },
    {
        Name      => 'Output filters - Valid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::Navigation)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="Frontend::Output::FilterText###AAAURL" Required="1" Valid="1">
        <Navigation>Frontend::Base::OutputFilter</Navigation>
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 0,
    },
    {
        Name      => 'Output filters - Invalid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::Navigation)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="Frontend::Output::FilterText###AAAURL" Required="1" Valid="1">
        <Navigation>Frontend::Base</Navigation>
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 1,
    },
    {
        Name      => 'Frontend views - Valid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::Navigation)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="Ticket::Frontend::ZoomRichTextForce" Required="1" Valid="1">
        <Navigation>Frontend::Agent::View::TicketZoom</Navigation>
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 0,
    },
    {
        Name      => 'Frontend views - Invalid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::Navigation)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="Ticket::Frontend::ZoomRichTextForce" Required="1" Valid="1">
        <Navigation>Frontend::Agent::TicketZoom::View::RichText</Navigation>
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 1,
    },
    {
        Name      => 'Frontend views (OTOBO 7+) - Invalid',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::Navigation)],
        Framework => '6.0',
        Source    => <<"EOF",
<otobo_config version="2.0" init="Framework">
    <Setting Name="Ticket::Frontend::CustomerTicketMessage###DynamicField" Required="1" Valid="1">
        <Navigation>Frontend::Customer::Ticket::View::Message</Navigation>
$SettingTemplate
    </Setting>
</otobo_config>
EOF
        Exception => 1,
    },
);

$Self->scripts::test::OTOBOCodePolicyPlugins::Run( Tests => \@Tests );

1;
