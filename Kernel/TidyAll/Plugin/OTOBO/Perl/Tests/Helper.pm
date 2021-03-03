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

package TidyAll::Plugin::OTOBO::Perl::Tests::Helper;

use strict;
use warnings;

use Moo;

extends qw(TidyAll::Plugin::OTOBO::Perl);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my %MatchRegexes = (
        HelperObjectParams               => qr{->ObjectParamAdd\(\s*'Kernel::System::UnitTest::Helper'}xms,
        HelperObjectFlagRestoreDatabase  => qr{RestoreDatabase\s*=>\s*1}xms,
        HelperObjectFlagPGPEnvironment   => qr{ProvideTestPGPEnvironment\s*=>\s*1}xms,
        HelperObjectFlagSMIMEEnvironment => qr{ProvideTestSMIMEEnvironment\s*=>\s*1}xms,
        HelperInstantiation              => qr{->Get\('Kernel::System::UnitTest::Helper'}xms,
        SeleniumInstantiation            => qr{->Get\('Kernel::System::UnitTest::Selenium'}xms,
        PGPInstantiation                 => qr{->Get\('Kernel::System::Crypt::PGP'}xms,
        SMIMEInstantiation               => qr{->Get\('Kernel::System::Crypt::SMIME'}xms,
    );

    my %MatchPositions;

    for my $Key ( sort keys %MatchRegexes ) {
        if ( $Code =~ $MatchRegexes{$Key} ) {

            # Store the position of the first match.
            $MatchPositions{$Key} = $-[0];
        }
    }

    return if !$MatchPositions{HelperInstantiation};

    if ( $MatchPositions{SeleniumInstantiation} && $MatchPositions{HelperObjectParams} ) {
        if ( $MatchPositions{SeleniumInstantiation} < $MatchPositions{HelperObjectParams} ) {
            return $Self->DieWithError(<<"EOF");
Please always set the Helper object params before creating the Selenium object to make sure any constructor flags are properly set and processed. This needs to be done because Selenium::new() already may create the Helper.
EOF
        }
    }

    if ( $MatchPositions{SeleniumInstantiation} && $MatchPositions{HelperObjectFlagRestoreDatabase} ) {
        return $Self->DieWithError(<<"EOF");
Don't use the Helper flag 'RestoreDatabase' in  Selenium tests, as the web server cannot access the test transaction.
EOF
    }

    return;
}

1;
