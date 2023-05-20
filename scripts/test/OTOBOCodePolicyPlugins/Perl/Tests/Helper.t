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

## nofilter(TidyAll::Plugin::OTOBO::Perl::Tests::Helper)

# core modules

# CPAN modules
use Test2::V0;

# OTOBO modules
use scripts::test::OTOBOCodePolicyPlugins;

my @Tests = (
    {
        Name      => 'Helper not used',
        Filename  => 'test.t',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::Tests::Helper)],
        Framework => '8.0',
        Source    => <<'EOF',
1;
EOF
        Exception => 0,
    },
    {
        Name      => 'Helper used',
        Filename  => 'test.t',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::Tests::Helper)],
        Framework => '8.0',
        Source    => <<'EOF',
my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
EOF
        Exception => 0,
    },
    {
        Name      => 'Helper created before Selenium object',
        Filename  => 'test.t',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::Tests::Helper)],
        Framework => '8.0',
        Source    => <<'EOF',
$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        ProvideTestDocumentSearchIndices => 1,
    },
);
my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
my $Selenium = $Kernel::OM->Get('Kernel::System::UnitTest::Selenium');
EOF
        Exception => 0,
    },
    {
        Name      => 'Helper created after Selenium object',
        Filename  => 'test.t',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::Tests::Helper)],
        Framework => '8.0',
        Source    => <<'EOF',
my $Selenium = $Kernel::OM->Get('Kernel::System::UnitTest::Selenium');
$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        ProvideTestDocumentSearchIndices => 1,
    },
);
my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
EOF
        Exception => 1,
    },
    {
        Name      => 'RestoreDatabase in a Selenium test',
        Filename  => 'test.t',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::Tests::Helper)],
        Framework => '8.0',
        Source    => <<'EOF',
$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        RestoreDatabase => 1,
    },
);
my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
my $Selenium = $Kernel::OM->Get('Kernel::System::UnitTest::Selenium');
EOF
        Exception => 1,
    },
    {
        Name      => 'Set ProvideTestPGPEnvironment in a Selenium test',
        Filename  => 'test.t',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::Tests::Helper)],
        Framework => '8.0',
        Source    => <<'EOF',
$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        ProvideTestPGPEnvironment => 1,
    },
);
my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
my $PGPObject = $Kernel::OM->Get('Kernel::System::Crypt::PGP');
EOF
        Exception => 0,
    },
    {
        Name      => 'Missing ProvideTestPGPEnvironment in a Selenium test',
        Todo      => 'ProvideTestPGPEnvironment not supported in OTOBO',
        Filename  => 'test.t',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::Tests::Helper)],
        Framework => '8.0',
        Source    => <<'EOF',
my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
my $PGPObject = $Kernel::OM->Get('Kernel::System::Crypt::PGP');
EOF
        Exception => 1,
    },
    {
        Name      => 'Set ProvideTestSMIMEEnvironment in a Selenium test',
        Filename  => 'test.t',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::Tests::Helper)],
        Framework => '8.0',
        Source    => <<'EOF',
$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        ProvideTestSMIMEEnvironment => 1,
    },
);
my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
my $SMIMEObject = $Kernel::OM->Get('Kernel::System::Crypt::SMIME');
EOF
        Exception => 0,
    },
    {
        Name      => 'Missing ProvideTestSMIMEEnvironment in a Selenium test',
        Todo      => 'ProvideTestPGPEnvironment not supported in OTOBO',
        Filename  => 'test.t',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::Tests::Helper)],
        Framework => '8.0',
        Source    => <<'EOF',
my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
my $SMIMEObject = $Kernel::OM->Get('Kernel::System::Crypt::SMIME');
EOF
        Exception => 1,
    },
);

scripts::test::OTOBOCodePolicyPlugins::Run( Tests => \@Tests );

done_testing;
