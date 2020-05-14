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

package TidyAll::Plugin::OTOBO::Migrations::OTOBO5::HeaderlineFilename;

use strict;
use warnings;

use File::Basename;

use parent qw(TidyAll::Plugin::OTOBO::Base);

=head1 SYNOPSIS

OTOBO used to have the filename in the second line of every file;
drop this with OTOBO 5.

=cut

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan( 5, 0 );
    return $Code if !$Self->IsFrameworkVersionLessThan( 6, 0 );

    # Catch Perl and JS coments
    my $CommentStart = "(?:\\#|//)";

    $Code =~ s{
        (
            \A
            (?: $CommentStart![^\n]+\n )?                   # shebang line
            $CommentStart[ ]--\n                            # separator
        )
            (?: $CommentStart \s+ (?!Copyright)[^\n]+\n )+  # Old documentation header lines to be removed
        (
            (?: $CommentStart \s+ Copyright[^\n]+\n )+      # copyright
            $CommentStart[ ]--\n          # separator
        )
    }
    {$1$2}ismx;

    return $Code;
}

1;
