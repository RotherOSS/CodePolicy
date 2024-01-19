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

package TidyAll::Plugin::OTOBO::XML::ConfigDescription;

use strict;
use warnings;

use Moo;

extends qw(TidyAll::Plugin::OTOBO::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my ( $ErrorMessage, $Counter, $NavBar );

    for my $Line ( split /\n/, $Code ) {
        $Counter++;
        if ( $Line =~ /<NavBar/ ) {
            $NavBar = 1;
        }
        if ( $Line =~ /<\/NavBar/ ) {
            $NavBar = 0;
        }

        if ( !$NavBar && $Line =~ /<Description.+?>(.).*?(.)\)?<\/Description>/ ) {
            if ( $2 ne '.' && $2 ne '?' && $2 ne '!' ) {
                $ErrorMessage .= "Line $Counter: $Line\n";
            }
            elsif ( $1 !~ /[A-ZËÜÖ"]/ ) {
                $ErrorMessage .= "Line $Counter: $Line\n";
            }
        }
    }

    if ($ErrorMessage) {
        return $Self->DieWithError(<<"EOF");
Please make complete sentences in <Description> tags: start with a capital letter and finish with a dot.
$ErrorMessage
EOF
    }
}

1;
