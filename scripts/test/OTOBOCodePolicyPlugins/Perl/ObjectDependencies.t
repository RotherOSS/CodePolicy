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

use strict;
use warnings;
use v5.24;
use utf8;

# core modules

# CPAN modules

# OTOBO modules
use scripts::test::OTOBOCodePolicyPlugins;
use Kernel::System::UnitTest::RegisterDriver;

our $Self;

my @Tests = (
    {
        Name      => 'ObjectDependencies, no OM used.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::ObjectDependencies)],
        Framework => '4.0',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $FH;
EOF
        Exception => 0,
    },
    {
        Name      => 'ObjectDependencies, undeclared dependency used (former default dependency)',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::ObjectDependencies)],
        Framework => '4.0',
        Source    => <<'EOF',
$Kernel::OM->Get('Kernel::System::Encode');
EOF
        Exception => 1,
    },
    {
        Name      => 'ObjectDependencies, default dependencies used with invalid short form in Get()',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::ObjectDependencies)],
        Framework => '4.0',
        Source    => <<'EOF',
our @ObjectDependencies = ('Kernel::System::Encode');
$Kernel::OM->Get('EncodeObject');
EOF
        Exception => 1,
    },
    {
        Name      => 'ObjectDependencies, undeclared dependency used',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::ObjectDependencies)],
        Framework => '4.0',
        Source    => <<'EOF',
$Kernel::OM->Get('Kernel::System::Ticket');
EOF
        Exception => 1,
    },
    {
        Name      => 'ObjectDependencies, dependency declared',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::ObjectDependencies)],
        Framework => '4.0',
        Source    => <<'EOF',
our @ObjectDependencies = ('Kernel::System::Ticket');
$Kernel::OM->Get('Kernel::System::Ticket');
EOF
        Exception => 0,
    },
    {
        Name      => 'ObjectDependencies, dependency declared in TestObjectDependencies
',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::ObjectDependencies)],
        Framework => '4.0',
        Source    => <<'EOF',
our @SoftObjectDependencies = ('Kernel::System::Ticket');
$Kernel::OM->Get('Kernel::System::Ticket');
EOF
        Exception => 0,
    },
    {
        Name      => 'ObjectDependencies, dependency declared, invalid short form',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::ObjectDependencies)],
        Framework => '4.0',
        Source    => <<'EOF',
our @ObjectDependencies = ('Kernel::System::Ticket');
for my $Needed (qw(TicketObject)) {
    $Self->{$Needed} = $Kernel::OM->Get($Needed);
}
EOF
        Exception => 1,
    },
    {
        Name      => 'ObjectDependencies, undeclared dependency in loop',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::ObjectDependencies)],
        Framework => '4.0',
        Source    => <<'EOF',
for my $Needed (qw(Kernel::System::Ticket)) {
    $Self->{$Needed} = $Kernel::OM->Get($Needed);
}
EOF
        Exception => 1,
    },
    {
        Name      => 'ObjectDependencies, Get called in for loop',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::ObjectDependencies)],
        Framework => '4.0',
        Source    => <<'EOF',
for my $Needed (qw(Kernel::System::CustomObject)) {
    $Self->{$Needed} = $Kernel::OM->Get($Needed);
}
EOF
        Exception => 1,
    },
    {
        Name      => 'ObjectDependencies, complex code, undeclared dependency',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::ObjectDependencies)],
        Framework => '4.0',
        Source    => <<'EOF',
$Self->{ConfigObject} = $Kernel::OM->Get('Kernel::System::Config');
$Kernel::OM->ObjectParamAdd(
    LogObject => {
        LogPrefix => $Self->{ConfigObject}->Get('CGILogPrefix'),
    },
    ParamObject => {
        WebRequest => $Param{WebRequest} || 0,
    },
);

for my $Object (
    qw( LogObject EncodeObject SessionObject MainObject TimeObject ParamObject UserObject GroupObject )
    )
{
    $Self->{$Object} = $Kernel::OM->Get($Object);
}
EOF
        Exception => 1,
    },
    {
        Name      => 'ObjectDependencies, complex code, undeclared dependency',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::ObjectDependencies)],
        Framework => '4.0',
        Source    => <<'EOF',
our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::DB',
    'Kernel::System::Encode',
    'Kernel::System::Log',
    'Kernel::System::Main',
    'Kernel::System::User',
    'Kernel::System::Group',
    'Kernel::System::AuthSession',
    'Kernel::System::Web::Request',
);

$Self->{ConfigObject} = $Kernel::OM->Get('Kernel::Config');
$Kernel::OM->ObjectParamAdd(
    LogObject => {
        LogPrefix => $Self->{ConfigObject}->Get('CGILogPrefix'),
    },
    ParamObject => {
        WebRequest => $Param{WebRequest} || 0,
    },
);

for my $Object (
    qw( Kernel::System::User Kernel::System::Group )
    )
{
    $Self->{$Object} = $Kernel::OM->Get($Object);
}
EOF
        Exception => 0,
    },
    {
        Name      => 'ObjectDependencies, object manager disabled',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::ObjectDependencies)],
        Framework => '4.0',
        Source    => <<'EOF',
our $ObjectManagerDisabled = 1;
$Kernel::OM->Get('Kernel::System::Ticket');
EOF
        Exception => 0,
    },
    {
        Name      => 'ObjectDependencies, deprecated ObjectManagerAware flag',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::ObjectDependencies)],
        Framework => '4.0',
        Source    => <<'EOF',
our @ObjectDependencies = ('Kernel::System::Ticket');
our $ObjectManagerAware = 1;
$Kernel::OM->Get('Kernel::System::Ticket');
EOF
        Exception => 1,
    },
    {
        Name      => 'ObjectDependencies, Moose::Role',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::ObjectDependencies)],
        Framework => '4.0',
        Source    => <<'EOF',
use Moose::Role;
$Kernel::OM->Get('Kernel::System::Ticket');
EOF
        Exception => 0,
    },
    {
        Name      => 'ObjectDependencies, WebApp controller',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::ObjectDependencies)],
        Framework => '4.0',
        Source    => <<'EOF',
package Kernel::WebApp::Controller::Test;
$Kernel::OM->Get('Kernel::System::Ticket');
EOF
        Exception => 0,
    },
    {
        Name      => 'ObjectDependencies, WebApp plugin',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::ObjectDependencies)],
        Framework => '4.0',
        Source    => <<'EOF',
package Kernel::WebApp::Plugin::Test;
$Kernel::OM->Get('Kernel::System::Ticket');
EOF
        Exception => 0,
    },
    {
        Name      => 'ObjectDependencies, WebApp server',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::ObjectDependencies)],
        Framework => '4.0',
        Source    => <<'EOF',
package Kernel::WebApp::Server::Test;
$Kernel::OM->Get('Kernel::System::Ticket');
EOF
        Exception => 0,
    },
);

$Self->scripts::test::OTOBOCodePolicyPlugins::Run( Tests => \@Tests );

$Self->DoneTesting();
