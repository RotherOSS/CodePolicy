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

# Work around a Perl bug that is triggered in Devel::StackTrace
#   (probaly from Exception::Class and this from Perl::Critic).
#
#   See https://github.com/houseabsolute/Devel-StackTrace/issues/11 and
#   http://rt.perl.org/rt3/Public/Bug/Display.html?id=78186
no warnings 'redefine';                     ## no critic qw(TestingAndDebugging::ProhibitNoWarnings)
use Devel::StackTrace ();
local *Devel::StackTrace::new = sub { };    # no-op
use warnings 'redefine';

# core modules

# CPAN modules
use Test2::V0;

# OTOBO modules
use scripts::test::OTOBOCodePolicyPlugins;

my @Tests = (
    {
        Name      => 'PerlCritic ProhibitOpen regular file, old-style read',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::PerlCritic)],
        Framework => '3.3',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $FH;
open($FH, '<filename.txt');
close $FH;
EOF
        Exception => 1,
    },
    {
        Name      => 'PerlCritic ProhibitOpen regular file, read',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::PerlCritic)],
        Framework => '3.3',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $FH;
open($FH, '<', 'filename.txt');
close $FH;
EOF
        Exception => 1,
    },
    {
        Name      => 'PerlCritic ProhibitOpen regular file, read, no parentheses, bareword filehandle',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::PerlCritic)],
        Framework => '3.3',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
open FH, '<', 'filename.txt';
close $FH;
EOF
        Exception => 1,
    },
    {
        Name      => 'PerlCritic ProhibitOpen regular file, write',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::PerlCritic)],
        Framework => '3.3',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $FH;
open($FH, '>', 'filename.txt');
close $FH;
EOF
        Exception => 1,
    },
    {
        Name      => 'PerlCritic ProhibitOpen regular file, write, no parentheses',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::PerlCritic)],
        Framework => '3.3',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $FH;
open $FH, '>', 'filename.txt';
close $FH;
EOF
        Exception => 1,
    },
    {
        Name      => 'PerlCritic ProhibitOpen regular file, bidirectional',
        Todo      => 'it is not obvious whether bidirectional open should be allowed',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::PerlCritic)],
        Framework => '3.3',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $FH;
open($FH, '+>', 'filename.txt');
close $FH;
EOF
        Exception => 0,
        Result    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $FH;
open($FH, '+>', 'filename.txt');
close $FH;
EOF
    },
    {
        Name      => 'PerlCritic ProhibitOpen regular file, external command',
        Todo      => 'it is not obvious whether external command open should be allowed',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::PerlCritic)],
        Framework => '3.3',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $FH;
open($FH, '-|', 'some_command');
close $FH;
EOF
        Exception => 0,
        Result    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $FH;
open($FH, '-|', 'some_command');
close $FH;
EOF
    },
    {
        Name      => 'PerlCritic ProhibitOpen regular file, unclear mode',
        Todo      => 'it is not obvious whether unclear mode open should be allowed',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::PerlCritic)],
        Framework => '3.3',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $FH;
open $FH, $Mode, $Param{Location};
close $FH;
EOF
        Exception => 0,
        Result    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $FH;
open $FH, $Mode, $Param{Location};
close $FH;
EOF
    },
    {
        Name      => 'PerlCritic ProhibitOpen in another context',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::PerlCritic)],
        Framework => '3.3',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $GeoIPObject = Geo::IP->open( $GeoIPDatabaseFile, Geo::IP::GEOIP_STANDARD() );
EOF
        Exception => 0,
        Result    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $GeoIPObject = Geo::IP->open( $GeoIPDatabaseFile, Geo::IP::GEOIP_STANDARD() );
EOF
    },
);

scripts::test::OTOBOCodePolicyPlugins::Run( Tests => \@Tests );

done_testing;
