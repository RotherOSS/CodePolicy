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

# core modules

# CPAN modules
use Test2::V0;

# OTOBO modules
use scripts::test::OTOBOCodePolicyPlugins;

my @Tests = (
    {
        Name      => 'ESLint (valid)',
        Filename  => 'Test.js',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::JavaScript::ESLint)],
        Framework => '8.0',
        Source    => <<'EOF',
"use strict;"
EOF
        Exception => 0,
    },
    {
        Name      => 'ESLint (syntax error)',
        Filename  => 'Test.js',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::JavaScript::ESLint)],
        Framework => '8.0',
        Source    => <<'EOF',
some syntax error
EOF
        Exception => 1,
    },

);

scripts::test::OTOBOCodePolicyPlugins::Run( Tests => \@Tests );

done_testing;
