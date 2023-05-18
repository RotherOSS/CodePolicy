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

package Perl::Critic::Policy::OTOBO::ProhibitRandInTests;

use strict;
use warnings;

# SYNOPSIS: Check if modules have a "true" return value

use Perl::Critic::Utils qw{};
use parent 'Perl::Critic::Policy';
use parent 'Perl::Critic::PolicyOTOBO';

our $VERSION = '0.02';

my $Description = q{Use of "rand()" or "srand()" is not allowed in tests.};
my $Explanation = q{Use Kernel::System::UnitTest::Helper::GetRandomNumber() or GetRandomID() instead.};

sub supported_parameters { return; }
sub default_severity     { return $Perl::Critic::Utils::SEVERITY_HIGHEST; }
sub default_themes       { return qw( otobo ) }
sub applies_to           { return 'PPI::Token::Word' }

# Only apply to test (.t) files.
sub prepare_to_scan_document {
    my ( $Self, $Document ) = @_;

    return $Document->logical_filename() =~ m{ \.t \z }xms;
}

sub violates {
    my ( $Self, $Element ) = @_;

    if ( $Element eq 'rand' || $Element eq 'srand' ) {
        return $Self->violation( $Description, $Explanation, $Element );
    }

    return;
}

1;
