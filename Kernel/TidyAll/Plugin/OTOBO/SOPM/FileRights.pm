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

package TidyAll::Plugin::OTOBO::SOPM::FileRights;

use strict;
use warnings;

use Moo;

extends qw(TidyAll::Plugin::OTOBO::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    # strict permission checks starting with OTOBO 10
    my $ExecutablePermissionCheck = qr{Permission="770"};
    my $StaticPermissionCheck     = qr{Permission="660"};
    my $Explanation               = 'A <File>-Tag has wrong permissions. Script files normally need 770 rights, the others 660.';

    ## A lot more lenient before OTOBO 10 (world permissions)
    #if ( $Self->IsFrameworkVersionLessThan( 6, 0 ) ) {
    #    $ExecutablePermissionCheck = qr{Permission="755"};
    #    $StaticPermissionCheck     = qr{Permission="644"};
    #    $Explanation = 'A <File>-Tag has wrong permissions. Script files normally need 755 rights, the others 644.';
    #}

    my ( $ErrorMessage, $Counter );

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;
        next LINE if $Line !~ m/<File.*\/>/;
        if ( $Line =~ m/<File.*Location="([^"]+)".*\/>/ ) {
            if ( $1 && $1 =~ /\.(pl|sh|fpl|psgi|sh)$/ ) {
                if ( $Line !~ $ExecutablePermissionCheck ) {
                    $ErrorMessage .= "Line $Counter: $Line\n";
                }
            }

            else {
                if ( $Line !~ $StaticPermissionCheck ) {
                    $ErrorMessage .= "Line $Counter: $Line\n";
                }
            }
        }
    }

    if ($ErrorMessage) {
        return $Self->DieWithError(<<"EOF");
$Explanation
$ErrorMessage
EOF
    }

    return;
}

1;
