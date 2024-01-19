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
use utf8;

# core modules

# CPAN modules
use Test2::V0;

# OTOBO modules
use scripts::test::OTOBOCodePolicyPlugins;

skip_all('TidyAll plugin does not exist in CodePolicy');

my @Tests = (
    {
        Name      => 'YAML, no indentation',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::YAMLIndentation)],
        Framework => '8.0',
        Source    => <<"EOF",
    <Setting Name="YAMLTest" Required="0" Valid="1">
        <Value>
            <Item ValueType="YAML"><![CDATA[---
Key: Value
]]></Item>
        </Value>
    </Setting>
EOF
        Exception => 0,
    },
    {
        Name      => 'YAML, empty',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::YAMLIndentation)],
        Framework => '8.0',
        Source    => <<"EOF",
    <Setting Name="YAMLTest" Required="0" Valid="1">
        <Value>
            <Item ValueType="YAML"><![CDATA[---
]]></Item>
        </Value>
    </Setting>
EOF
        Exception => 0,
    },
    {
        Name      => 'YAML, with indentation',
        Filename  => 'Kernel/Config/Files/XML/Test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Configuration::YAMLIndentation)],
        Framework => '8.0',
        Source    => <<"EOF",
    <Setting Name="YAMLTest" Required="0" Valid="1">
        <Value>
            <Item ValueType="YAML"><![CDATA[---
            Key: Value
            SubHash:
              SubKey: SubValue
            ]]></Item>
        </Value>
    </Setting>
EOF
        Result => <<"EOF",
    <Setting Name="YAMLTest" Required="0" Valid="1">
        <Value>
            <Item ValueType="YAML"><![CDATA[---
Key: Value
SubHash:
  SubKey: SubValue
]]></Item>
        </Value>
    </Setting>
EOF
        Exception => 0,
    },
);

scripts::test::OTOBOCodePolicyPlugins::Run( Tests => \@Tests );

done_testing;
