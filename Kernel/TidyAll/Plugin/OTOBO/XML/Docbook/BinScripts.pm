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

package TidyAll::Plugin::OTOBO::XML::Docbook::BinScripts;

use strict;
use warnings;

use File::Basename;

use parent qw(TidyAll::Plugin::OTOBO::Base);

=head1 SYNOPSIS

This plugin checks that bin scripts point to new paths.

=cut

sub validate_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan( 5, 0 );

    my %AllowedFiles = (
        'otobo.CheckModules.pl'   => 1,
        'otobo.CheckSum.pl'       => 1,
        'otobo.CodePolicy.pl'     => 1,
        'otobo.Console.pl'        => 1,
        'otobo.Daemon.pl'         => 1,
        'otobo.SetPermissions.pl' => 1,
    );

    my ( $Counter, $ErrorMessage );

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;
        if ( $Line =~ /bin\/(otobo\.\w+\.pl)/ismx ) {

            next LINE if $AllowedFiles{$1};

            $ErrorMessage .= "Line $Counter: $Line\n";
        }
    }

    if ($ErrorMessage) {
        return $Self->DieWithError(<<"EOF");
Don't use old bin scripts in documentation.
$ErrorMessage
EOF
    }

    return;
}

1;
