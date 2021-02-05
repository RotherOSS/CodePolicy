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

package TidyAll::Plugin::OTOBO::Perl::PerlCritic;

use strict;
use warnings;
use v5.24;
use utf8;

use File::Basename;
use lib dirname(__FILE__) . '/../';    # Find our Perl::Critic policies

use parent qw(TidyAll::Plugin::OTOBO::Perl);

# core modules

# CPAN modules
use Perl::Critic;

# OTOBO modules
use Perl::Critic::Policy::OTOBO::ProhibitGoto;
use Perl::Critic::Policy::OTOBO::ProhibitLowPrecendeceOps;
use Perl::Critic::Policy::OTOBO::ProhibitSmartMatchOperator;
use Perl::Critic::Policy::OTOBO::ProhibitRandInTests;
use Perl::Critic::Policy::OTOBO::ProhibitOpen;
use Perl::Critic::Policy::OTOBO::RequireCamelCase;
use Perl::Critic::Policy::OTOBO::RequireLabels;
use Perl::Critic::Policy::OTOBO::RequireParensWithMethods;

sub validate_file {
    my ( $Self, $Filename ) = @_;

    # Cache Perl::Critic object instance to save time. But cache it
    # for every framework version, because the configuration may differ.
    state $CachedPerlCritic = {};

    return if $Self->IsPluginDisabled( Filename => $Filename );
    return if $Self->IsFrameworkVersionLessThan( 3, 2 );

    my $FrameworkVersion = "$TidyAll::OTOBO::FrameworkVersionMajor.$TidyAll::OTOBO::FrameworkVersionMinor";

    if ( !$CachedPerlCritic->{$FrameworkVersion} ) {

        my $Severity = 4;    # STERN, only $SEVERITY_HIGHEST = 5 and $SEVERITY_HIGH = 4 are covered

        my $Critic = Perl::Critic->new(
            -severity => $Severity,
            -exclude  => [
            ],
            '-program-extensions' => [qw(.pl .t)],
        );

        # explicitly add the OTOBO policies, run them regardless of severity
        $Critic->add_policy( -policy => 'OTOBO::ProhibitGoto' );
        $Critic->add_policy( -policy => 'OTOBO::ProhibitLowPrecendeceOps' );
        $Critic->add_policy( -policy => 'OTOBO::ProhibitOpen' );
        $Critic->add_policy( -policy => 'OTOBO::ProhibitRandInTests' );
        $Critic->add_policy( -policy => 'OTOBO::ProhibitSmartMatchOperator' );
        $Critic->add_policy( -policy => 'OTOBO::RequireCamelCase' );
        $Critic->add_policy( -policy => 'OTOBO::RequireLabels' );
        $Critic->add_policy( -policy => 'OTOBO::RequireParensWithMethods' );

        # explicitly add standard policy mit severity $SEVERITY_LOW, that is 2
        $Critic->add_policy( -policy => 'ControlStructures::ProhibitUnlessBlocks' );

        $CachedPerlCritic->{$FrameworkVersion} = $Critic;
    }

    # Force stringification of $Filename as it is a Path::Tiny object in Code::TidyAll 0.50+.
    my @Violations = $CachedPerlCritic->{$FrameworkVersion}->critique("$Filename");

    # Format the violations, indicating the policy name, brief description and explanation.
    # See https://metacpan.org/pod/Perl::Critic::Violation#OVERLOADS
    # for the  escape characters.
    Perl::Critic::Violation::set_format(
        '%p violated at line %l column %c (Severity: %s)\\n  %m\\n%e\\n'
    );
    if (@Violations) {
        return $Self->DieWithError("@Violations");
    }

    return;
}

1;
