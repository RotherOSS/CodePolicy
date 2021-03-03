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

package TidyAll::Plugin::OTOBO::Common::Origin;

use strict;
use warnings;

use File::Basename;

use Moo;

extends qw(TidyAll::Plugin::OTOBO::Base);

=head1 SYNOPSIS

This plugin checks that only valid OTOBO origins are used
in customized/derived files.

=cut

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # Remove former-origin because it's not needed any more
    $Code =~ s{ ^ [ ]* (?: \# | \/\/ ) [ ]+ (?: \$ )* former-origin: .+? $ \n }{}xmsg;

    my $Origin = '$origin:';

    # Transfers the old origin
    #
    # # $origin: https://github.com/OTOBO/ITSMIncidentProblemManagement/blob/74efccbc7821537134b520b508a116afdd489ad4/Kernel/Modules/AgentTicketActionCommon.pm
    #
    # to the new
    #
    # # $origin: ITSMIncidentProblemManagement - 74efccbc7821537134b520b508a116afdd489ad4 - Kernel/Modules/AgentTicketActionCommon.pm
    #
    $Code =~ s{
        ^
        ( [ ]* (?: \# [ ]+  | \/\/ [ ]+ | <Git> ) )
        (?: \$ | ) origin: [ ]+ http (?: s | ) :\/\/ github \. com \/ OTOBO \/
        ( [^\/ \n]+ )
        \/ (?: blob\/ | commit\/ |  )
        ( [a-z0-9]+ )
        \/
        ( .+? )
        $
    }{$1$Origin $2 - $3 - $4}xms;

    # Transfers the old origin
    #
    # # $origin: https://git.otobo.com/otobo/ITSMIncidentProblemManagement/blobs/74efccbc7821537134b520b508a116afdd489ad4/Kernel/Modules/AgentTicketActionCommon.pm
    #
    # to the new
    #
    # # $origin: ITSMIncidentProblemManagement - 74efccbc7821537134b520b508a116afdd489ad4 - Kernel/Modules/AgentTicketActionCommon.pm
    #
    $Code =~ s{
        ^
        ( [ ]* (?: \# | \/\/ ) )
        [ ]+ (?: \$ | ) origin: [ ]+ http (?: s | ) :\/\/ git \. otobo \. com \/ otobo \/
        ( [^\/ \n]+ )
        \/ blobs \/
        ( [a-z0-9]+ )
        \/
        ( .+? )
        $
    }{$1 $Origin $2 - $3 - $4}xms;

    # Transfers an CVS OldId
    #
    # # $OldId: AgentTicketEmail.dtl,v 1.142.2.1 2011/09/07 20:53:50 en Exp $
    #
    # to the new origin
    #
    # # $origin: otobo - 0000000000000000000000000000000000000000 - AgentTicketEmail.dtl
    #

    if ( my ($FileString) = $Code =~ m{ ^ [ ]* (?: \# | \/\/ ) [ ]+ \$OldId: [ ]+ ( [^\n]+? ) ,v [ ]+ [^\n]+ \n }xms ) {

        my $FilePath = $FileString;

        if ( $FileString =~ m{ ^ [^\n]+ \. dtl $ }xms ) {
            $FilePath = 'Kernel/Output/HTML/Standard/' . $FileString;
        }
        elsif ( $FileString =~ m{ ^ [^\n]+ \. js $ }xms ) {
            $FilePath = 'var/httpd/htdocs/js/' . $FileString;
        }
        elsif ( $FileString =~ m{ ^ (?: Layout | NavBar | NotificationAgent | TicketOverview | TicketMenu | ToolBar | Dashboard ) [^\n]+ \. pm $ }xms ) {
            $FilePath = 'Kernel/Output/HTML/' . $FileString;
        }
        elsif ( $FileString =~ m{ ^ (?: Agent | Customer | Public ) [^\n]+ \. pm $ }xms ) {
            $FilePath = 'Kernel/Modules/' . $FileString;
        }
        elsif ( $FileString =~ m{ ^ [^\n]+ \. pm $ }xms ) {
            $FilePath = 'Kernel/System/' . $FileString;
        }

        $Code =~ s{
            ^ ( [ ]* (?: \# | \/\/ ) ) [ ]+ \$OldId: [ ]+ [^\n]+? ,v [ ]+ [^\n]+ \n
        }{$1 $Origin otobo - 0000000000000000000000000000000000000000 - $FilePath\n}xms;
    }


    # Check the origin if customization markers are found
    if ( $Code =~ m{ ^ [ ]* (?: \# | \/\/ ) [ ]+ --- [ ]* $ }xms ) {

        my $FoundOrigin;
        my $LineCounter = 0;
        ORIGINLINE:
        for my $Line ( split /\n/, $Code ) {
            $LineCounter++;

            last ORIGINLINE if $LineCounter > 5;

            next ORIGINLINE if $Line !~ m{ ^ [ ]* (?: \# | \/\/ ) [ ]+ \$origin: [ ]+ [^\n]+ $ }xms;

            $FoundOrigin = 1;
        }

        if ( !$FoundOrigin ) {

            my $PackageCounter = 0;

            PACKAGELINE:
            for my $Line ( split /\n/, $Code ) {

                next PACKAGELINE if $Line !~ m{ ^ package [ ]+ ( [A-Za-z0-9\:]+ ) \; $ }xms;

                # count lines with any 'package..;'
                $PackageCounter++;
            }

            return $Code if $PackageCounter == 0;

            # only one 'package' allowed per file - split first if there are more packages combined.
            if ($PackageCounter > 1) {
                return $Self->DieWithError("$PackageCounter package lines found.\n");
            }

            my ($FilePath) = $Code =~ m{ ^ package [ ]+ ( [A-Za-z0-9\:]+ ) \; $ }xms;

            # just allow Kernel and scripts::tests to be modified automatically
            return $Code if $FilePath !~ m{ ^ ( Kernel | scripts \:\: tests )? \:\: }xms;

            $FilePath =~ s{ \:\: }{/}gsmx;

            my $NewOrigin = $Origin . ' otobo - 0000000000000000000000000000000000000000 - ' . $FilePath . '.pm';

            # place new origin after Copyright
            $Code =~ s{ ( \# [ ]+ Copyright .* \/ \n \# [ ]+ -- \n \# [ ]+ ) }{$1$NewOrigin\n# --\n# }xms;
        }
    }

    return $Code;
}

sub validate_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # Check the origin if customization markers are found
    if ( $Code =~ m{ ^ [ ]* (?: \# | \/\/ ) [ ]+ --- [ ]* $ }xms ) {

        my $FoundOrigin;
        my $Counter = 0;
        LINE:
        for my $Line ( split /\n/, $Code ) {

            $Counter++;

            last LINE if $Counter > 5;

            next LINE if $Line !~ m{ ^ [ ]* (?: \# | \/\/ ) [ ]+ \$origin: [ ]+ [^\n]+ $ }xms;

            $FoundOrigin = 1;
        }

        if (!$FoundOrigin) {
            return $Self->DieWithError("Customization markers found but no origin present.\n");
        }
    }

    return $Code;
}

sub validate_file {
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( Filename => $Filename );

    my $Code = $Self->_GetFileContents($Filename);

    # Check if all files in the Custom directory has an origin
    if ( $Filename =~ m{ \/Custom\/ }xms ) {

        # Check if an origin exist.
        if ( $Code !~ m{ ^ [ ]* (?: \# | \/\/ ) [ ]+ \$origin: [ ]+ [^\n]+ $ }xms ) {
            return $Self->DieWithError("File is in Custom directory but no origin present.\n");
        }
    }

    if ( $Filename =~ m{ .* \.css }xmsi ) {

        # Check if a CSS file is overritten in Custom directory.
        if ( $Filename =~ m{ \/Custom\/var\/ }xms ) {

            return $Self->DieWithError(<<"EOF");
Forbidden to have a CSS file in Custom folder, because it's not allowed to override an existing CSS file.
Use a new one to override existing CSS classes.
EOF
        }

        # Check if an origin exist.
        if ( $Code =~ m{ ^ [ ]* (?: \# | \/\/ | \* ) [ ]+ (?: \$ | \@ ) origin: [ ]+ [^\n]+ $ }xms ) {

            return $Self->DieWithError(<<"EOF");
Forbidden to have an origin in a CSS file, because it's not allowed to override an existing CSS file.
Use a new one to override existing CSS classes.
EOF
        }

        # Check if customization markers exists.
        if ( $Code =~ m{ ^ [ ]* (?: \# | \/\/ | \* | \/\* ) [ ]+ --- [ ]* $ }xms ) {

            return $Self->DieWithError(<<"EOF");
Forbidden to have customization markers in a CSS file, because it's not allowed to override an existing CSS file.
Use a new one to override existing CSS classes.
EOF
        }
    }

    return;
}

1;
