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

package TidyAll::Plugin::OTOBO::Perl::SubDeclaration;

use strict;
use warnings;

use File::Basename;

use Moo;

extends qw(TidyAll::Plugin::OTOBO::Perl);

=head1 SYNOPSIS

This module checks for sub declarations with the brace in the following
line and corrects them.

    sub abc
    {
        ...
    }

will become:

    sub abc {
        ...
    }

=cut

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    if ( $Code =~ m|^sub \s+ \w+ \s* \r?\n \{ |smx ) {
        $Code =~ s|^(sub \s+ \w+) \s* \r?\n \{ |$1 {|smxg;
    }

    return $Code;
}

1;
