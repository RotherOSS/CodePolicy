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

package Perl::Critic::Policy::OTOBO::ProhibitOpen;

use strict;
use warnings;

use Perl::Critic::Utils qw{};
use parent 'Perl::Critic::Policy';

our $VERSION = '0.01';

my $Description = q{Use of "open" is not allowed to read or write files.};
my $Explanation = q{Use MainObject::FileRead() or FileWrite() instead.};

sub supported_parameters { return; }
sub default_severity     { return $Perl::Critic::Utils::SEVERITY_HIGHEST; }
sub default_themes       { return qw( otobo ) }
sub applies_to           { return 'PPI::Token::Word' }

sub violates {
    my ( $Self, $Element ) = @_;

    # Only operate on calls of open()
    return if $Element ne 'open';

    my $NextSibling = $Element->snext_sibling();

    return unless $NextSibling;

    # Find open mode specifier
    my $OpenMode = '';

    # parentheses around open are present: open()
    if ( $NextSibling->isa('PPI::Structure::List') ) {
        my $Quote = $NextSibling->find('PPI::Token::Quote');

        return unless ref $Quote eq 'ARRAY';

        $OpenMode = $Quote->[0]->string();
    }

    # parentheses are not present
    else {
        # Loop until we found the Token after the first comma
        my $Counter;
        COUNTER:
        while ( $Counter++ < 10 ) {
            $NextSibling = $NextSibling->snext_sibling();

            # this happens for
            #   use open IO => ':encoding(UTF-8)';
            last COUNTER unless $NextSibling;

            if (
                $NextSibling->isa('PPI::Token::Operator')
                && $NextSibling->content() eq ','
                )
            {
                my $Quote = $NextSibling->snext_sibling();

                return if ( !$Quote || !$Quote->isa('PPI::Token::Quote') );

                $OpenMode = $Quote->string();

                last COUNTER;
            }
        }
    }

    if ( $OpenMode eq '>' || $OpenMode eq '<' ) {
        return $Self->violation( $Description, $Explanation, $Element );
    }

    return;
}

1;
