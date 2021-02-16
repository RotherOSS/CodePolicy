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

my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');

my $RandomID = $Helper->GetRandomID();

my @Tests = (
    {
        Name      => 'There is overridden unit test',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::UnitTestBlacklist)],
        Framework => '6.0',
        Source    => <<"EOF",
    <Setting Name="UnitTest::Blacklist###100-OTOBOCodePolicy" Required="0" Valid="1">
        <Description Translatable="1">Blacklist overridden framework unit tests when this package is installed.</Description>
        <Navigation>Core::UnitTest</Navigation>
        <Value>
            <Array>
                <Item ValueType="String">SomeUnitTestBlacklist${RandomID}.t</Item>
                <Item ValueType="String">SomeDirectory/SomeUnitTestBlacklist${RandomID}.t</Item>
            </Array>
        </Value>
    </Setting>
EOF
        FileList => [
            "scripts/test/OTOBOCodePolicySomeUnitTestBlacklist${RandomID}.t",
            "scripts/test/SomeDirectory/OTOBOCodePolicySomeUnitTestBlacklist${RandomID}.t",
        ],
        Exception => 0,
    },
    {
        Name      => 'There is not overridden unit test',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::UnitTestBlacklist)],
        Framework => '6.0',
        Source    => <<'EOF',
    <Setting Name="UnitTest::Blacklist###100-OTOBOCodePolicy" Required="0" Valid="1">
        <Description Translatable="1">Blacklist overridden framework unit tests when this package is installed.</Description>
        <Navigation>Core::UnitTest</Navigation>
        <Value>
            <Array>
                <Item ValueType="String">SomeUnitTestBlacklistNonExistent.t</Item>
                <Item ValueType="String">SomeDirectory/SomeUnitTestBlacklistNonExistent.t</Item>
            </Array>
        </Value>
    </Setting>
EOF
        FileList  => [],
        Exception => 1,
    },
);

$Self->scripts::test::OTOBOCodePolicyPlugins::Run( Tests => \@Tests );

1;
