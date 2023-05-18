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

package TidyAll::Plugin::OTOBO::Perl::BinScripts;

use strict;
use warnings;

use File::Basename;

use Moo;

extends qw(TidyAll::Plugin::OTOBO::Perl);

# We only want to allow a handful of scripts in bin. All the rest should be
#   migrated to console commands.

sub validate_file {
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( Filename => $Filename );

    my %AllowedFiles = (
        'otobo.CheckModules.pl'   => 1,
        'otobo.CheckSum.pl'       => 1,
        'otobo.CodePolicy.pl'     => 1,
        'otobo.Console.pl'        => 1,
        'otobo.Daemon.pl'         => 1,
        'otobo.SetPermissions.pl' => 1,
    );

    if ( !$AllowedFiles{ File::Basename::basename($Filename) } ) {
        return $Self->DieWithError(<<"EOF");
Please migrate all bin/ scripts to Kernel::System::Console::Command objects.
EOF
    }
}

1;
