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

package TidyAll::Plugin::OTOBO::Common::CustomizationMarkers;
## nofilter(TidyAll::Plugin::OTOBO::Common::CustomizationMarkers)
## nofilter(TidyAll::Plugin::OTOBO::Common::Origin)

use strict;
use warnings;

use File::Basename;

use Moo;

extends qw(TidyAll::Plugin::OTOBO::Base);

=head1 SYNOPSIS

This plugin checks that only valid OTOBO customization markers are used
to mark changed lines in customized/derived files.

=cut

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # Find wrong customization markers without space or with 4 hyphens and correct them
    #
    #   #---
    #
    #   to
    #
    #   # ---
    #
    $Code =~ s{ ^ [ ]* ( (?: \# | \/\/ ) ) [ ]* -{3,4} [ ]* $ }{$1 ---}xmsg;

    # Find wrong customization markers in JS files an correct them
    #
    #   /***/
    #
    #   to
    #
    #   // ---
    #
    $Code =~ s{ ^ [ ]* \/ [ ]* \*{2,3} [ ]* \/ [ ]* $ }{// ---}xmsg;

    # Find wrong comments and correct them
    #
    #   # --------------------
    #
    #   or
    #
    #   #-----------------------------------
    #
    #   to
    #
    #   #
    #
    $Code =~ s{ ^ \n ^ [ ]* (?: \# | \/\/ ) [ ]* -{5,50} [ ]* $ \n ^ \n }{\n}xmsg;
    $Code =~ s{ ^ ( [ ]* (?: \# | \/\/ ) ) [ ]* -{5,50} [ ]* $ }{$1}xmsg;

    # Find somesthing like that and remove the leading spaces
    #
    #   # ---
    #   # OTOBOXyZ - Here a comment.
    #   # ---
    #
    #   or
    #
    #   # ---
    #   # OTOBOXyZ
    #   # ---
    #   # my $Subject = $Kernel::OM->Get('Kernel::System::Ticket')->TicketSubjectClean();
    #
    $Code =~ s{
        (
            ^ [ ]+ (?: \# | \/\/ ) [ ]+ --- [ ]* $ \n
            ^ [ ]+ (?: \# | \/\/ ) [ ]+ [^ ]+ (?: [ ]+ - [^\n]+ | ) $ \n
            ^ [ ]+ (?: \# | \/\/ ) [ ]+ --- [ ]* $ \n
            (?: ^ [ ]+ (?: \# | \/\/ ) [^\n]* $ \n )*
        )
    }{
        my $String = $1;
        $String =~ s{ ^ [ ]+ }{}xmsg;
        $String;
    }xmsge;

    # Find wrong customization markers in JS files an correct them
    #
    #   /**
    #   * OTOBOXyZ - Here a comment.
    #   **/
    #
    #   or
    #
    #   /***
    #   * OTOBOXyZ
    #   ***/
    #
    #   to
    #
    #   // ---
    #   // OTOBOXyZ
    #   // ---
    #
    $Code =~ s{
        ^ [ ]* \/ [ ]* \*{2,3} [ ]* $ \n
        ^ [ ]* \*{1,3} [ ]+ ( [^ ]+ (?: [ ]+ - [^\n]+ | ) ) $ \n
        ^ [ ]* \*{2,3} [ ]* \/ [ ]* $ \n
    }{$Self->_CustomizationMarker($1)}xmsge;

    # Find somesthing like that and remove the leading spaces
    #
    #   # ---
    #
    $Code =~ s{ ^ [ ]+ ( (?: \# | \/\/ ) ) [ ]+ --- [ ]* $ }{$1 ---}xmsg;

    return $Code;
}

sub validate_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    my ( $Counter, $Flag, $ErrorMessage );

    LINE:
    for my $Line ( split /\n/, $Code ) {

        $Counter++;

        # Allow ## no critic and ## use critic
        next LINE if $Line =~ m{^ \s* \#\# \s+ (?:no|use) \s+ critic}xms;

        # Allow ## nofilter
        next LINE if $Line =~ m{^ \s* \#\# \s+ nofilter }xms;

        if ( $Line =~ /^[^#]/ && $Counter < 24 ) {
            $Flag = 1;
        }
        if ( $Line =~ /^ *# --$/ && ( $Counter > 23 || ( $Counter > 10 && $Flag ) ) ) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
        elsif ( $Line =~ m{ ^ [ ]* (?: \# | \/\/ )+ [ ]* - [ ]* $ }xms ) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
        elsif ( $Line =~ m{ ^ [ ]* (?: \# | \/\/ )+ -{1,} [ ]* $ }xms ) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
        elsif ( $Line =~ m{ ^ [ ]* (?: \# | \/\/ )+ [ ]* -{4,40} [ ]* $ }xms ) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
        elsif ( $Line =~ /^ *#+ *[\*\+]+$/ ) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
        elsif ( $Line =~ m{ ^ [ ]* (?: \# | \/\/ ){3,} }xms ) {
            $ErrorMessage .= "Line $Counter: $Line\n";
        }
    }

    if ($ErrorMessage) {
        return $Self->DieWithError(<<"EOF");
Please remove or replace wrong Separators like '# --', valid only: # --- (for customizing otobo files).
$ErrorMessage
EOF
    }

    return $Code;
}

sub _CustomizationMarker {
    my ( $Self, $Module ) = @_;

    return <<"END_CUSTOMMARKER";
// ---
// $Module
// ---
END_CUSTOMMARKER
}

1;
