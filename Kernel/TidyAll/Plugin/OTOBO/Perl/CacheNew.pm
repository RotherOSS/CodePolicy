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

package TidyAll::Plugin::OTOBO::Perl::CacheNew;

use strict;
use warnings;

use Moo;

extends qw(TidyAll::Plugin::OTOBO::Perl);

## nofilter(TidyAll::Plugin::OTOBO::Perl::CacheNew)
## nofilter(TidyAll::Plugin::OTOBO::Perl::ObjectDependencies)

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    $Code = $Self->StripPod( Code => $Code );

    my ( $ErrorMessage, $Counter );

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;

        if ( $Line =~ m/Kernel::System::Cache->new/smx ) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
    }

    if ($ErrorMessage) {
        return $Self->DieWithError(<<"EOF");
Don't create your own instance of Kernel::System::Cache.pm, but use $Kernel::OM->Get('Kernel::System::Cache') instead.
$ErrorMessage
EOF
    }

    return;
}

1;
