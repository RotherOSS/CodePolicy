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

my @Tests = (
    {
        Name      => 'Minimal valid SOPM.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::SOPM::XSDValidator)],
        Framework => '4.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otobo_package version="1.0">
    <Name>OTOBOCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>4.0.x</Framework>
    <Vendor>Rother OSS GmbH</Vendor>
    <URL>https://otobo.de/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTOBO code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otobo.CodePolicy.pl"/>
    </Filelist>
</otobo_package>
EOF
        Exception => 0,
    },
    {
        Name      => 'Simple PackageMerge',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::SOPM::XSDValidator)],
        Framework => '4.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otobo_package version="1.0">
    <Name>OTOBOCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>4.0.x</Framework>
    <Vendor>Rother OSS GmbH</Vendor>
    <URL>https://otobo.de/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTOBO code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otobo.CodePolicy.pl"/>
    </Filelist>
    <PackageMerge Name="MergeOne" TargetVersion="2.0.0"></PackageMerge>
</otobo_package>
EOF
        Exception => 0,
    },
    {
        Name      => 'PackageMerge without TargetVersion',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::SOPM::XSDValidator)],
        Framework => '4.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otobo_package version="1.0">
    <Name>OTOBOCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>4.0.x</Framework>
    <Vendor>Rother OSS GmbH</Vendor>
    <URL>https://otobo.de/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTOBO code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otobo.CodePolicy.pl"/>
    </Filelist>
    <PackageMerge Name="MergeOne"></PackageMerge>
</otobo_package>
EOF
        Exception => 1,
    },
    {
        Name      => 'PackageMerge without Name',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::SOPM::XSDValidator)],
        Framework => '4.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otobo_package version="1.0">
    <Name>OTOBOCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>4.0.x</Framework>
    <Vendor>Rother OSS GmbH</Vendor>
    <URL>https://otobo.de/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTOBO code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otobo.CodePolicy.pl"/>
    </Filelist>
    <PackageMerge TargetVersion="2.0.0"></PackageMerge>
</otobo_package>
EOF
        Exception => 1,
    },
    {
        Name      => 'Simple PackageMerge',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::SOPM::XSDValidator)],
        Framework => '4.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otobo_package version="1.0">
    <Name>OTOBOCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>4.0.x</Framework>
    <Vendor>Rother OSS GmbH</Vendor>
    <URL>https://otobo.de/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTOBO code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otobo.CodePolicy.pl"/>
    </Filelist>
    <DatabaseUpgrade Type="post">
        <TableCreate Name="merge_package">
            <Column Name="id" Required="true" PrimaryKey="true" AutoIncrement="true" Type="INTEGER"/>
            <Column Name="description" Required="true" Size="200" Type="VARCHAR"/>
        </TableCreate>
    </DatabaseUpgrade>
    <PackageMerge Name="MergeOne" TargetVersion="2.0.0">
      <DatabaseUpgrade Type="merge" IfPackage="OtherPackage" IfNotPackage="OtherPackage2">
          <TableCreate Name="merge_package">
              <Column Name="id" Required="true" PrimaryKey="true" AutoIncrement="true" Type="INTEGER"/>
              <Column Name="description" Required="true" Size="200" Type="VARCHAR"/>
          </TableCreate>
      </DatabaseUpgrade>
    </PackageMerge>
</otobo_package>
EOF
        Exception => 0,
    },
    {
        Name      => 'PackageMerge with invalid CodeInstall',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::SOPM::XSDValidator)],
        Framework => '4.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otobo_package version="1.0">
    <Name>OTOBOCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>4.0.x</Framework>
    <Vendor>Rother OSS GmbH</Vendor>
    <URL>https://otobo.de/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTOBO code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otobo.CodePolicy.pl"/>
    </Filelist>
    <PackageMerge Name="MergeOne" TargetVersion="2.0.0">
      <DatabaseInstall Type="merge">
          <TableCreate Name="merge_package">
              <Column Name="id" Required="true" PrimaryKey="true" AutoIncrement="true" Type="INTEGER"/>
              <Column Name="description" Required="true" Size="200" Type="VARCHAR"/>
          </TableCreate>
      </DatabaseInstall>
    </PackageMerge>
</otobo_package>
EOF
        Exception => 1,
    },
);

scripts::test::OTOBOCodePolicyPlugins::Run( Tests => \@Tests );

done_testing;
