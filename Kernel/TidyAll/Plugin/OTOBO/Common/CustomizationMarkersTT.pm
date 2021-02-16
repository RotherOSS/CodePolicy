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

package TidyAll::Plugin::OTOBO::Common::CustomizationMarkersTT;

use strict;
use warnings;

use File::Basename;

use parent qw(TidyAll::Plugin::OTOBO::Base);

=head1 SYNOPSIS

This plugin checks that only valid OTOBO customization markers are used
to mark changed lines in customized/derived C<.tt> files.

=cut

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # Find customization markers with // in .tt files and replace them with #.
    #
    #   // ---
    #   // OTOBOXyZ - Here a comment.
    #   // ---
    #
    #   to
    #
    #   # ---
    #   # OTOBOXyZ - Here a comment.
    #   # ---
    #
    $Code =~ s{
        (
            ^ [ ]* \/\/ [ ]+ --- [ ]* $ \n
            ^ [ ]* \/\/ [ ]+ [^ ]+ (?: [ ]+ - [^\n]+ | ) $ \n
            ^ [ ]* \/\/ [ ]+ --- [ ]* $ \n
            (?: ^ [ ]* \/\/ [^\n]* $ \n )*
        )
    }{
        my $String = $1;
        $String =~ s{ ^ [ ]* \/\/ }{#}xmsg;
        $String;
    }xmsge;

    # Find wrong customization markers in .tt files and correct them.
    #
    #   // ---
    #
    #   to
    #
    #   # ---
    #
    $Code =~ s{ ^ [ ]* \/\/ [ ]+ --- [ ]* $ }{# ---}xmsg;

    return $Code;
}

1;
