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

use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::OTOBOCodePolicyPlugins;

my @Tests = (
    {
        Name      => 'Unique with name OTOBO 8',
        Filename  => 'otobo-schema.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Database::XSDValidator)],
        Framework => '8.0',
        Source    => <<"EOF",
<Table Name="dynamic_field_obj_id_name">
    <Unique Name="dynamic_field_object_name">
        <UniqueColumn Name="object_name"/>
        <UniqueColumn Name="object_type"/>
    </Unique>
</Table>
EOF
        Exception => 0,
    },
    {
        Name      => 'Unique without name OTOBO 8',
        Filename  => 'otobo-schema.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Database::XSDValidator)],
        Framework => '8.0',
        Source    => <<"EOF",
<Table Name="dynamic_field_obj_id_name">
    <Unique>
        <UniqueColumn Name="object_name"/>
        <UniqueColumn Name="object_type"/>
    </Unique>
</Table>
EOF
        Exception => 0,
    },
    {
        Name      => 'Index with name OTOBO 8',
        Filename  => 'otobo-schema.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Database::XSDValidator)],
        Framework => '8.0',
        Source    => <<"EOF",
<Table Name="dynamic_field_obj_id_name">
    <Index Name="dynamic_field_object_name">
        <IndexColumn Name="object_name"/>
        <IndexColumn Name="object_type"/>
    </Index>
</Table>
EOF
        Exception => 0,
    },
    {
        Name      => 'Index without name OTOBO 8',
        Filename  => 'otobo-schema.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Database::XSDValidator)],
        Framework => '8.0',
        Source    => <<"EOF",
<Table Name="dynamic_field_obj_id_name">
    <Index>
        <IndexColumn Name="object_name"/>
        <IndexColumn Name="object_type"/>
    </Index>
</Table>
EOF
        Exception => 0,
    },
    {
        Name      => 'Unique with name OTOBO 9',
        Filename  => 'otobo-schema.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Database::XSDValidator)],
        Framework => '9.0',
        Source    => <<"EOF",
<Table Name="dynamic_field_obj_id_name">
    <Unique Name="dynamic_field_object_name">
        <UniqueColumn Name="object_name"/>
        <UniqueColumn Name="object_type"/>
    </Unique>
</Table>
EOF
        Exception => 0,
    },
    {
        Name      => 'Unique without name OTOBO 9',
        Filename  => 'otobo-schema.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Database::XSDValidator)],
        Framework => '9.0',
        Source    => <<"EOF",
<Table Name="dynamic_field_obj_id_name">
    <Unique>
        <UniqueColumn Name="object_name"/>
        <UniqueColumn Name="object_type"/>
    </Unique>
</Table>
EOF
        Exception => 1,
    },
    {
        Name      => 'Index with name OTOBO 9',
        Filename  => 'otobo-schema.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Database::XSDValidator)],
        Framework => '9.0',
        Source    => <<"EOF",
<Table Name="dynamic_field_obj_id_name">
    <Index Name="dynamic_field_object_name">
        <IndexColumn Name="object_name"/>
        <IndexColumn Name="object_type"/>
    </Index>
</Table>
EOF
        Exception => 0,
    },
    {
        Name      => 'Index without name OTOBO 9',
        Filename  => 'otobo-schema.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::XML::Database::XSDValidator)],
        Framework => '9.0',
        Source    => <<"EOF",
<Table Name="dynamic_field_obj_id_name">
    <Index>
        <IndexColumn Name="object_name"/>
        <IndexColumn Name="object_type"/>
    </Index>
</Table>
EOF
        Exception => 1,
    },
);

$Self->scripts::test::OTOBOCodePolicyPlugins::Run( Tests => \@Tests );

1;
