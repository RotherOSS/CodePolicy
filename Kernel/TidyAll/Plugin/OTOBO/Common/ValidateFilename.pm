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

package TidyAll::Plugin::OTOBO::Common::ValidateFilename;

use strict;
use warnings;

use File::Basename;
use File::Copy qw(copy);
use Moo;

extends qw(TidyAll::Plugin::OTOBO::Base);

=head1 SYNOPSIS

This plugin performs basic file name checks.

=cut

sub validate_file {
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( Filename => $Filename );

    my @ForbiddenCharacters = (
        ' ', "\n", "\t", '"', '`', '´', '\'', '$', '!', '?,', '*',
        '(', ')', '{', '}', '[', ']', '#', '<', '>', ':', '\\', '|',
    );

    for my $ForbiddenCharacter (@ForbiddenCharacters) {
        if ( index( $Filename, $ForbiddenCharacter ) > -1 ) {
            my $ForbiddenList = join( ' ', @ForbiddenCharacters );
            return $Self->DieWithError(<<"EOF");
Forbidden character '$ForbiddenCharacter' found in file name.
You should not use these characters in file names: $ForbiddenList.
EOF
        }
    }

    return;
}

1;
