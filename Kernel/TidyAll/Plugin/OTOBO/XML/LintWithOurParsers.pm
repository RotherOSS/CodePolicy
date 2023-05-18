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

package TidyAll::Plugin::OTOBO::XML::LintWithOurParsers;

use strict;
use warnings;

use Moo;

extends qw(TidyAll::Plugin::OTOBO::Base);

use XML::Parser;

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my $Parser = XML::Parser->new();
    if ( !eval { $Parser->parse($Code) } ) {
        return $Self->DieWithError("XML::Parser produced errors: $@\n");
    }

    # XML::Parser::Lite may not be installed, only check if present.
    if ( eval 'require XML::Parser::Lite' ) {    ## no critic qw(BuiltinFunctions::ProhibitStringyEval)
        my $ParserLite = XML::Parser::Lite->new();
        eval { $ParserLite->parse($Code) };
        if ($@) {
            return $Self->DieWithError("XML::Parser::Lite produced errors: $@\n");
        }
    }
}

1;
