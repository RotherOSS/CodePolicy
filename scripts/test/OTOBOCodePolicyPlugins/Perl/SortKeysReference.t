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
## nofilter(TidyAll::Plugin::OTOBO::Perl::SortKeys)

use vars (qw($Self));
use utf8;

use scripts::test::OTOBOCodePolicyPlugins;

my @Tests = (
    {
        Name      => 'for Sort Keys Reference, forbidden',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::SortKeys)],
        Framework => '5.0',
        Source    => <<'EOF',
for my $Variable ( sort keys $HashRef ) {
EOF
        Exception => 1,
    },
    {
        Name      => 'for Keys Reference, forbidden',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::SortKeys)],
        Framework => '5.0',
        Source    => <<'EOF',
for my $Variable ( keys $HashRef ) {
EOF
        Result => <<'EOF',
for my $Variable ( sort keys $HashRef ) {
EOF
        Exception => 1,
    },
    {
        Name      => 'for Sort Keys Hash as reference, forbidden',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::SortKeys)],
        Framework => '5.0',
        Source    => <<'EOF',
for my $Variable ( sort keys \%Hash ) {
EOF
        Exception => 1,
    },
    {
        Name      => 'for Keys Hash as reference, forbidden',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::SortKeys)],
        Framework => '5.0',
        Source    => <<'EOF',
for my $Variable ( keys \%Hash ) {
EOF
        Result => <<'EOF',
for my $Variable ( sort keys $HashRef ) {
EOF
        Exception => 1,
    },
    {
        Name      => 'for Sort Keys unreferenced Hash, OK',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::SortKeys)],
        Framework => '5.0',
        Source    => <<'EOF',
for my $Variable ( sort keys %{ $HashRef } ) {
EOF
        Exception => 0,
    },
    {
        Name      => 'for Keys unreferenced Hash, forbidden',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::SortKeys)],
        Framework => '5.0',
        Source    => <<'EOF',
for my $Variable ( keys %{ $HashRef } ) {
EOF
        Result => <<'EOF',
for my $Variable ( sort keys %{ $HashRef } ) {
EOF
        Exception => 0,
    },
    {
        Name      => 'for Keys  Hash, OK',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::SortKeys)],
        Framework => '5.0',
        Source    => <<'EOF',
for my $Variable ( keys %Hash ) {
EOF
        Result => <<'EOF',
for my $Variable ( sort keys %Hash ) {
EOF
        Exception => 0,
    },
);

$Self->scripts::test::OTOBOCodePolicyPlugins::Run( Tests => \@Tests );

1;
