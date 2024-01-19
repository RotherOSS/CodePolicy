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

use vars (qw($Self));
use utf8;

use scripts::test::OTOBOCodePolicyPlugins;

my @Tests = (
    {
        Name      => 'Minimal valid SOPM.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otobo_package version="1.0">
    <Name>OTOBOCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>Rother OSS GmbH</Vendor>
    <URL>https://otobo.de/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTOBO code quality checks.</Description>
    <PackageIsDownloadable>0</PackageIsDownloadable>
    <PackageIsBuildable>0</PackageIsBuildable>
    <Filelist>
        <File Permission="755" Location="bin/otobo.CodePolicy.pl" />
    </Filelist>
</otobo_package>
EOF
        Exception => 0,
    },
    {
        Name      => 'Missing name.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otobo_package version="1.0">
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>Rother OSS GmbH</Vendor>
    <URL>https://otobo.de/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTOBO code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otobo.CodePolicy.pl" />
    </Filelist>
</otobo_package>
EOF
        Exception => 1,
    },
    {
        Name      => 'Missing description.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otobo_package version="1.0">
    <Name>OTOBOCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>Rother OSS GmbH</Vendor>
    <URL>https://otobo.de/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Filelist>
        <File Permission="755" Location="bin/otobo.CodePolicy.pl" />
    </Filelist>
</otobo_package>
EOF
        Exception => 1,
    },
    {
        Name      => 'Missing version.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otobo_package version="1.0">
    <Name>OTOBOCodePolicy</Name>
    <Framework>7.0.x</Framework>
    <Vendor>Rother OSS GmbH</Vendor>
    <URL>https://otobo.de/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTOBO code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otobo.CodePolicy.pl" />
    </Filelist>
</otobo_package>
EOF
        Exception => 1,
    },
    {
        Name      => 'Missing framework.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otobo_package version="1.0">
    <Name>OTOBOCodePolicy</Name>
    <Version>0.0.0</Version>
    <Vendor>Rother OSS GmbH</Vendor>
    <URL>https://otobo.de/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTOBO code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otobo.CodePolicy.pl" />
    </Filelist>
</otobo_package>
EOF
        Exception => 1,
    },
    {
        Name      => 'Missing vendor.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otobo_package version="1.0">
    <Name>OTOBOCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <URL>https://otobo.de/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTOBO code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otobo.CodePolicy.pl" />
    </Filelist>
</otobo_package>
EOF
        Exception => 1,
    },
    {
        Name      => 'Missing URL.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otobo_package version="1.0">
    <Name>OTOBOCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>Rother OSS GmbH</Vendor>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTOBO code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otobo.CodePolicy.pl" />
    </Filelist>
</otobo_package>
EOF
        Exception => 1,
    },
    {
        Name      => 'Missing license.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otobo_package version="1.0">
    <Name>OTOBOCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>Rother OSS GmbH</Vendor>
    <URL>https://otobo.de/</URL>
    <Description Lang="en">OTOBO code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otobo.CodePolicy.pl" />
    </Filelist>
</otobo_package>
EOF
        Exception => 1,
    },
    {
        Name      => 'Invalid content for PackageIsDownloadable flag.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otobo_package version="1.0">
    <Name>OTOBOCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>Rother OSS GmbH</Vendor>
    <URL>https://otobo.de/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTOBO code quality checks.</Description>
    <PackageIsDownloadable>test</PackageIsDownloadable>
    <PackageIsBuildable>0</PackageIsBuildable>
    <Filelist>
        <File Permission="755" Location="bin/otobo.CodePolicy.pl" />
    </Filelist>
</otobo_package>
EOF
        Exception => 1,
    },
    {
        Name      => 'OTOBOCodePolicy - missing PackageIsDownloadable + PackageIsBuildable.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otobo_package version="1.0">
    <Name>OTOBOCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>Rother OSS GmbH</Vendor>
    <URL>https://otobo.de/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTOBO code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otobo.CodePolicy.pl" />
    </Filelist>
</otobo_package>
EOF
        Exception => 1,
    },
    {
        Name      => 'OTOBOCodePolicy - valid SOPM.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otobo_package version="1.0">
    <Name>OTOBOCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>Rother OSS GmbH</Vendor>
    <URL>https://otobo.de/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTOBO code quality checks.</Description>
    <PackageIsDownloadable>0</PackageIsDownloadable>
    <PackageIsBuildable>0</PackageIsBuildable>
    <Filelist>
        <File Permission="755" Location="bin/otobo.CodePolicy.pl" />
    </Filelist>
</otobo_package>
EOF
        Exception => 0,
    },
    {
        Name      => 'ITSMIncidentProblemManagement - missing PackageIsDownloadable + PackageIsBuildable.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otobo_package version="1.0">
    <Name>ITSMIncidentProblemManagement</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>Rother OSS GmbH</Vendor>
    <URL>https://otobo.de/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTOBO code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otobo.CodePolicy.pl" />
    </Filelist>
</otobo_package>
EOF
        Exception => 1,
    },
    {
        Name      => 'ITSMIncidentProblemManagement - valid SOPM.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otobo_package version="1.0">
    <Name>ITSMIncidentProblemManagement</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>Rother OSS GmbH</Vendor>
    <URL>https://otobo.de/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTOBO code quality checks.</Description>
    <PackageIsDownloadable>0</PackageIsDownloadable>
    <PackageIsBuildable>0</PackageIsBuildable>
    <Filelist>
        <File Permission="755" Location="bin/otobo.CodePolicy.pl" />
    </Filelist>
</otobo_package>
EOF
        Exception => 0,
    },
    {
        Name      => 'TimeAccounting - missing PackageIsDownloadable + PackageIsBuildable.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otobo_package version="1.0">
    <Name>TimeAccounting</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>Rother OSS GmbH</Vendor>
    <URL>https://otobo.de/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTOBO code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otobo.CodePolicy.pl" />
    </Filelist>
</otobo_package>
EOF
        Exception => 1,
    },
    {
        Name      => 'TimeAccounting - valid SOPM.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otobo_package version="1.0">
    <Name>TimeAccounting</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>Rother OSS GmbH</Vendor>
    <URL>https://otobo.de/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTOBO code quality checks.</Description>
    <PackageIsDownloadable>0</PackageIsDownloadable>
    <PackageIsBuildable>0</PackageIsBuildable>
    <Filelist>
        <File Permission="755" Location="bin/otobo.CodePolicy.pl" />
    </Filelist>
</otobo_package>
EOF
        Exception => 0,
    },
    {
        Name      => 'OTOBOSTORM - missing PackageIsDownloadable + PackageIsBuildable.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otobo_package version="1.0">
    <Name>OTOBOSTORM</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>Rother OSS GmbH</Vendor>
    <URL>https://otobo.de/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTOBO code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otobo.CodePolicy.pl" />
    </Filelist>
</otobo_package>
EOF
        Exception => 1,
    },
    {
        Name      => 'OTOBOSTORM - valid SOPM.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otobo_package version="1.0">
    <Name>OTOBOSTORM</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>Rother OSS GmbH</Vendor>
    <URL>https://otobo.de/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTOBO code quality checks.</Description>
    <PackageIsDownloadable>0</PackageIsDownloadable>
    <PackageIsBuildable>0</PackageIsBuildable>
    <Filelist>
        <File Permission="755" Location="bin/otobo.CodePolicy.pl" />
    </Filelist>
</otobo_package>
EOF
        Exception => 0,
    },
    {
        Name      => 'Test123 - valid SOPM (no restricted package).',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otobo_package version="1.0">
    <Name>Test123</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>Rother OSS GmbH</Vendor>
    <URL>https://otobo.de/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTOBO code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otobo.CodePolicy.pl" />
    </Filelist>
</otobo_package>
EOF
        Exception => 0,
    },
);

$Self->scripts::test::OTOBOCodePolicyPlugins::Run( Tests => \@Tests );

1;
