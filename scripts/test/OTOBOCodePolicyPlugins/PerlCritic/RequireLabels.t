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
        Name      => 'next without label',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::PerlCritic)],
        Framework => '4.0',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
for my $Key ( 1..3 ) {
    next;
}
EOF
        Exception => 1,
    },
    {
        Name      => 'next with label',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::PerlCritic)],
        Framework => '4.0',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
KEY:
for my $Key ( 1..3 ) {
    next KEY;
}
EOF
        Exception => 0,
        Result    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
KEY:
for my $Key ( 1..3 ) {
    next KEY;
}
EOF
    },
    {
        Name      => 'last without label',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::PerlCritic)],
        Framework => '4.0',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
for my $Key ( 1..3 ) {
    last;
}
EOF
        Exception => 1,
    },
    {
        Name      => 'last with label',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::PerlCritic)],
        Framework => '4.0',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
KEY:
for my $Key ( 1..3 ) {
    last KEY;
}
EOF
        Exception => 0,
        Result    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
KEY:
for my $Key ( 1..3 ) {
    last KEY;
}
EOF
    },
    {
        Name      => 'next without label',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::PerlCritic)],
        Framework => '4.0',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
for my $Key ( 1..3 ) {
    next if (1);
}
EOF
        Exception => 1,
    },
    {
        Name      => 'next with label',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::PerlCritic)],
        Framework => '4.0',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
KEY:
for my $Key ( 1..3 ) {
    next KEY if (1);
}
EOF
        Exception => 0,
        Result    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
KEY:
for my $Key ( 1..3 ) {
    next KEY if (1);
}
EOF
    },
);

scripts::test::OTOBOCodePolicyPlugins::Run( Tests => \@Tests );

done_testing;
