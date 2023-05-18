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
use utf8;

# core modules

# CPAN modules
use Test2::V0;

# OTOBO modules
use scripts::test::OTOBOCodePolicyPlugins;
## nofilter(TidyAll::Plugin::OTOBO::Migrations::OTOBO8::UselessComments)

my @Tests = (
    {
        Name      => 'Normal comments',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Migrations::OTOBO8::UselessComments)],
        Framework => '8.0',
        Source    => <<'EOF',
# Some useful comment.

# A multiline comment explaining
#   some stuff in a detailed way.
EOF
        Exception => 0,
    },
    {
        Name      => 'Stupid comments',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Migrations::OTOBO8::UselessComments)],
        Framework => '8.0',
        Source    => <<'EOF',
some code here

# get needed objects
# Get needed objects.
# get needed variables
# Get needed variables
# get selenium object
# Get Config object.
# get script alias
# get valid list
# allocate new hash for object
# check needed stuff
# check needed data
# check needed params.
# check needed objects.
more code here
EOF
        Result => <<'EOF',
some code here

more code here
EOF
        Exception => 0,
    },
);

scripts::test::OTOBOCodePolicyPlugins::Run( Tests => \@Tests );

done_testing;
