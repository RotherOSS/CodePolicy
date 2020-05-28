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

package TidyAll::Plugin::OTOBO::Migrations::OTOBO10::DateTime;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTOBO::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 10, 0 );
    return if !$Self->IsFrameworkVersionLessThan( 11, 0 );

    my ( $Counter, $ErrorMessage );

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;

        next LINE if $Line =~ m/^\s*\#/smx;

        # Look for code that uses not allowed date/time modules and functions
        if ( $Line =~ m{(use\s+(Date::Pcalc|Time::Local|Time::Piece)|\b(timelocal|gmtime|timegm)\s*\()}sm ) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
    }

    if ($ErrorMessage) {
        return $Self->DieWithError(<<"EOF");
Use of Date::Pcalc, Time::Local, Time::Piece, timelocal, gmtime and timegm is not allowed anymore. Use Kernel::System::DateTime instead.
    Please see http://doc.otobo.com/doc/manual/developer/6.0/en/html/package-porting.html#package-porting-5-to-6 for porting guidelines.
$ErrorMessage
EOF
    }

    return;
}

1;
