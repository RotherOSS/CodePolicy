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

use parent qw(TidyAll::Plugin::OTOBO::Perl);

# core modules
use File::Basename qw(dirname);
use File::Spec qw();

# CPAN modules
use Perl::Critic;

# OTOBO modules

sub validate_file {
    my ( $Self, $Filename ) = @_;

    # Cache Perl::Critic object instance to save time. But cache it
    # for every framework version, because the configuration may differ.
    state $CachedPerlCritic = {};

    return if $Self->IsPluginDisabled( Filename => $Filename );

    my $FrameworkVersion = "$TidyAll::OTOBO::FrameworkVersionMajor.$TidyAll::OTOBO::FrameworkVersionMinor";

    if ( !$CachedPerlCritic->{$FrameworkVersion} ) {

        # find the perlcritic with the following priorities:
        # i.  setting in the environment $ENV{PERLCRITIC}
        # ii. the file perlcriticrc next to this module
        my $Profile = ( $ENV{PERLCRITIC} && -f $ENV{PERLCRITIC} )
            ?
            $ENV{PERLCRITIC}
            :
            File::Spec->catfile( dirname(__FILE__), 'perlcriticrc' );

        $CachedPerlCritic->{$FrameworkVersion} = Perl::Critic->new(
            -profile => $Profile
        );
    }

    my $PerlCritic = $CachedPerlCritic->{$FrameworkVersion};

    # Force stringification of $Filename as it is a Path::Tiny object in Code::TidyAll 0.50+.
    my @Violations = $PerlCritic->critique("$Filename");

    return unless @Violations;

    # The format, for the stringification, has to be set up seperately.
    my $Format = $PerlCritic->config->verbose // '%p violated at line %l column %c (Severity: %s)\\n  %m\\n%e\\n';
    Perl::Critic::Violation::set_format($Format);

    return $Self->DieWithError("@Violations");
}

1;
