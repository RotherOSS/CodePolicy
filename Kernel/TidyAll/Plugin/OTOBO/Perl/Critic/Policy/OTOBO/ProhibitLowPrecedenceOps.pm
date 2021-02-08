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

package Perl::Critic::Policy::OTOBO::ProhibitLowPrecedenceOps;

use strict;
use warnings;
use v5.24;
use utf8;

use parent 'Perl::Critic::Policy';

# core modules

# CPAN modules
use Perl::Critic::Utils qw{};

# OTOBO modules

our $VERSION = '0.01';

my $Description = q{Using low precedence operators is not allowed};
my $Explanation =
    q{Replace low precedence operators with the high precedence substitutes};

my %LowPrecendeceOperators = (
    not => '!',
    and => '&&',
    or  => '||',
);

sub supported_parameters { return; }
sub default_severity     { return $Perl::Critic::Utils::SEVERITY_HIGHEST; }
sub default_themes       { return qw( otobo ) }
sub applies_to           { return 'PPI::Token::Operator' }

sub violates {
    my ( $Self, $Element ) = @_;

    return if !grep { $Element eq $_ } keys %LowPrecendeceOperators;
    return $Self->violation( $Description, $Explanation, $Element );
}

1;
