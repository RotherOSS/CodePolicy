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

package TidyAll::Plugin::OTOBO::Migrations::OTOBO7::WebAppNoLegacyCode;

use strict;
use warnings;

use parent 'TidyAll::Plugin::OTOBO::Base';

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 7, 0 );
    return if !$Self->IsFrameworkVersionLessThan( 8, 0 );

    my @ForbiddenPaths = qw(
        Kernel::Output::HTML
        Kernel::Modules
    );

    my @ErrorPaths;

    for my $ForbiddenPath (@ForbiddenPaths) {
        if ( $Code =~ m{$ForbiddenPath} ) {
            push @ErrorPaths, $ForbiddenPath;
        }
    }

    if (@ErrorPaths) {
        my $ErrorPathJoin = join( ' or ', @ErrorPaths );
        return $Self->DieWithError(<<"EOF");
Don't use legacy code from $ErrorPathJoin in Kernel::WebApp.
EOF
    }

    return;
}

1;
