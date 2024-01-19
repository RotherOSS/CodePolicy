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

package TidyAll::Plugin::OTOBO::XML::Configuration::UnitTestBlacklist;

use strict;
use warnings;

use Moo;

extends qw(TidyAll::Plugin::OTOBO::Base);

=head1 SYNOPSIS

This plugin checks is a blacklisted unit test via C<UnitTest::Blacklist> feature is present in the filesystem.

=cut

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my $ErrorMessage;
    my $PackageName = '';

    LINE:
    for my $Line ( split /\n/, $Code ) {

        if ( !$PackageName && $Line =~ m{<Setting.*?Name="UnitTest::Blacklist###\d+-(.*?)"}sm ) {
            $PackageName = $1;
            next LINE;
        }

        if ( $PackageName && $Line =~ /<Item.*?>(.*)<\/Item>/ ) {

            my @TestNames = split /\//, $1;
            $TestNames[-1] = $PackageName . $TestNames[-1];

            my $PackageUnitTest = 'scripts/test/' . join( '/', @TestNames );
            if ( !grep { $_ eq $PackageUnitTest } @TidyAll::OTOBO::FileList ) {
                $ErrorMessage .= $PackageUnitTest . "\n";
            }
        }

        if ( $Line =~ /<\/Setting>/ ) {
            $PackageName = '';
            next LINE;
        }
    }

    if ($ErrorMessage) {
        return $Self->DieWithError(<<"EOF");


In order to blacklist unit test file(s), you need to first provide a suitable replacement under these path(s):
$ErrorMessage
EOF
    }

    return;
}

1;
