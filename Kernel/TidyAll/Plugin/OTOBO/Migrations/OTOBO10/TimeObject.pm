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

package TidyAll::Plugin::OTOBO::Migrations::OTOBO10::TimeObject;

use strict;
use warnings;
use v5.24;
use namespace::autoclean;

use Moo;

extends qw(TidyAll::Plugin::OTOBO::Base);

## nofilter(TidyAll::Plugin::OTOBO::Migrations::OTOBO10::TimeObject)

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    # active only for OTOBO 10
    return unless $Self->IsFrameworkVersionLessThan( 11, 0 );

    my ( $Counter, $ErrorMessage );

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;

        next LINE if $Line =~ m/^\s*\#/smx;

        if ( $Line =~ m{Kernel::System::Time[^a-zA-Z]}sm ) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
    }

    if ($ErrorMessage) {
        return $Self->DieWithError(<<"EOF");
Use of deprecated Kernel::System::Time is not allowed anymore except for legacy API interfaces. Please use Kernel::System::DateTime instead.
    Please see https://doc.otobo.org/manual/developer/stable/en/content/how-it-works/date-time.html.
$ErrorMessage
EOF
    }

    return;
}

1;
