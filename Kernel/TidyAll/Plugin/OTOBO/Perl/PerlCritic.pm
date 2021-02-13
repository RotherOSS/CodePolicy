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
use namespace::autoclean;
use utf8;

use parent qw(TidyAll::Plugin::OTOBO::Perl);

use File::Basename qw(dirname);
use lib dirname(__FILE__) . '/../';    # Find our Perl::Critic policies

# core modules

# CPAN modules
use Perl::Critic;

# OTOBO modules

# This sub will be called by Code::TidyAll
sub validate_file {
    my ( $Self, $Filename ) = @_;

    # Cache Perl::Critic object instance to save time. But cache it
    # for every framework version, because the configuration may differ.
    state $CachedPerlCritic = {};

    return if $Self->IsPluginDisabled( Filename => $Filename );

    my $FrameworkVersion = "$TidyAll::OTOBO::FrameworkVersionMajor.$TidyAll::OTOBO::FrameworkVersionMinor";

    if ( !$CachedPerlCritic->{$FrameworkVersion} ) {

        # STERN, per default only $SEVERITY_HIGHEST = 5 and $SEVERITY_HIGH = 4 are covered.
        # Lower severity policies can be explicitly added with add_policy().
        my $Severity = 4;

        my $Critic = Perl::Critic->new(
            -severity => $Severity,
            -exclude  => [
            ],
            '-program-extensions' => [qw(.pl .t)],
        );

        # The OTOBO specific policies don't have to be added explicity,
        # as they have the default severity $SEVERITY_HIGHEST = 5

        # explicitly add standard policy with defaul severity $SEVERITY_LOW, that is 2
        $Critic->add_policy( -policy => 'ControlStructures::ProhibitUnlessBlocks' );
        $Critic->add_policy( -policy => 'Miscellanea::ProhibitUselessNoCritic' );

        # explicitly add standard policy with default severity $SEVERITY_MEDIUM, that is 3
        $Critic->add_policy( -policy => 'Miscellanea::ProhibitUnrestrictedNoCritic' );

        $CachedPerlCritic->{$FrameworkVersion} = $Critic;
    }

    # Force stringification of $Filename as it is a Path::Tiny object in Code::TidyAll 0.50+.
    my @Violations = $CachedPerlCritic->{$FrameworkVersion}->critique("$Filename");

    # Format the violations, indicating the policy name, brief description and explanation.
    # See https://metacpan.org/pod/Perl::Critic::Violation#OVERLOADS
    # for the  escape characters.
    Perl::Critic::Violation::set_format(

        # useful for batch editing: 'sp +%l %f\\n no critic qw(%p)'
        '%p violated at line %l column %c (Severity: %s)\\n  %m\\n%e\\n'
    );

    if (@Violations) {
        return $Self->DieWithError("@Violations");
    }

    return;
}

1;
