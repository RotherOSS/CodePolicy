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

# Work around a Perl bug that is triggered in Devel::StackTrace
#   (probaly from Exception::Class and this from Perl::Critic).
#
#   See https://github.com/houseabsolute/Devel-StackTrace/issues/11 and
#   http://rt.perl.org/rt3/Public/Bug/Display.html?id=78186
no warnings 'redefine';    ## no critic
use Devel::StackTrace ();
local *Devel::StackTrace::new = sub { };    # no-op
use warnings 'redefine';

use scripts::test::OTOBOCodePolicyPlugins;

my @Tests = (
    {
        Name      => 'PerlCritic ProhibitStringySplit with string, allowed for OTOBO 8',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::PerlCritic)],
        Framework => '8.0',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my @Strings = split ':', 'some::code';
EOF
        Exception => 0,
    },
    {
        Name      => 'PerlCritic ProhibitStringySplit with string',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::PerlCritic)],
        Framework => '9.0',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my @Strings = split ':', 'some::code';
EOF
        Exception => 1,
    },
    {
        Name      => 'PerlCritic ProhibitStringySplit with regexes',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::PerlCritic)],
        Framework => '9.0',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my @Strings = split /:/, 'some::code';
@Strings = split m/:/, 'some::code';
@Strings = split(m/:/, 'some::code');
@Strings = split((m/:/, 'some::code'));
@Strings = split qr{:}, 'some::code';
EOF
        Exception => 0,
    },
    {
        Name      => 'PerlCritic ProhibitStringySplit with regex variable',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::PerlCritic)],
        Framework => '9.0',
        Source    => <<'EOF',
#!/usr/bin/bash
use strict;
use warnings;
my $Regex = qr{:};
my @Strings = split $Regex, 'some::code';
@Strings = split($Regex, 'some::code');
EOF
        Exception => 0,
    },
);

$Self->scripts::test::OTOBOCodePolicyPlugins::Run( Tests => \@Tests );

1;
