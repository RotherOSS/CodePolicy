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
        Name      => 'CacheNew, forbidden',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::CacheNew)],
        Framework => '4.0',
        Source    => <<'EOF',
Kernel::System::Cache->new(%{$Self});
EOF
        Exception => 1,
    },
    {
        Name      => 'CacheNew, ok',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::CacheNew)],
        Framework => '4.0',
        Source    => <<'EOF',
$Kernel::OM->Get('Kernel::System::Cache');
EOF
        Exception => 0,
    },
);

$Self->scripts::test::OTOBOCodePolicyPlugins::Run( Tests => \@Tests );

1;
