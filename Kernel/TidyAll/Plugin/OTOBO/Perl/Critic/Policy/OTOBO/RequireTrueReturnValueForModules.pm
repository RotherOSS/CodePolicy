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

package Perl::Critic::Policy::OTOBO::RequireTrueReturnValueForModules;

use strict;
use warnings;

# SYNOPSIS: Check if modules have a "true" return value

use Perl::Critic::Utils qw{};
use parent 'Perl::Critic::Policy';

our $VERSION = '0.02';

my $Description = q{Modules and tests have to return a true value ("1;")};
my $Explanation = q{Use "1;" as the last statement of the file};

sub supported_parameters { return; }
sub default_severity     { return $Perl::Critic::Utils::SEVERITY_HIGHEST; }
sub default_themes       { return qw( otobo ) }
sub applies_to           { return 'PPI::Document' }

# Only apply to Perl modules and test files, not to scripts.
sub prepare_to_scan_document {
    my ( $Self, $Document ) = @_;

    return $Document->logical_filename() =~ m{ (\.pm|\.t) \z }xms;
}

sub violates {
    my ( $Self, $Element ) = @_;

    my $LastStatement = $Element->schild(-1);
    return if $LastStatement && $LastStatement eq '1;';

    return $Self->violation( $Description, $Explanation, $Element );
}

1;
