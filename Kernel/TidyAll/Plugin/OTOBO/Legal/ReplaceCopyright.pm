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

package TidyAll::Plugin::OTOBO::Legal::ReplaceCopyright;
## nofilter(TidyAll::Plugin::OTOBO::Perl::Time)

use strict;
use warnings;

use File::Basename;
use File::Copy qw(copy);
use parent qw(TidyAll::Plugin::OTOBO::Base);

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # Don't replace copyright in thirdparty code.
    return $Code if $Self->IsThirdpartyModule();

    # Replace <URL>http://otobo.org/</URL> with <URL>https://otobo.de/</URL>
    $Code =~ s{ ^ ( \s* ) \< URL \> .+? \< \/ URL \> }{$1<URL>https://otobo.de/</URL>}xmsg;

    my $Copy = 'Rother OSS GmbH, https://otobo.de/';

    my ( $Sec, $Min, $Hour, $Day, $Month, $Year ) = localtime( time() );    ## no critic
    $Year += 1900;

    my $YearString = "2019-$Year";

    my $Output = '';

    my @Lines = split( /\n/, $Code );
    my $i = 0;

    # header start    
    LINE:
    for my $Line ( @Lines ) {
        last LINE if $Line =~ /Copyright/;

        $Output .= $Line . "\n";
        $i++;
    }

    my $CopySet = 0;

    # copyright block
    while ( $Lines[ $i ] && $Lines[ $i ] =~ /Copyright/ ) {
        my $Line = $Lines[ $i ];

        # POD copyright statements.
        if ( $Line =~ /^# Copyright .*Rother OSS/ ) {
            $Line = "# Copyright (C) $YearString $Copy";
            $CopySet = 1;
        }

        # Check string in documentation.yml files
        elsif ( $Line =~ /^Copyright: .*Rother OSS/ ) {
            $Line = "Copyright: $YearString $Copy";
            $CopySet = 1;
        }

        # Any other generic copyright statements, e.g :
        #   print "Copyright (c) 2003-2008 Rother OSS GmbH, http://www.otobo.com/\n";
        elsif ( $Line =~ /^([^\n]*)Copyright.*Rother OSS/i ) {
            $Line = "$1Copyright (C) $YearString $Copy";
            $CopySet = 1;
        }

        $Output .= $Line . "\n";
        $i++;
    }
    
    # if we are not yet listed add Rother OSS GmbH
    if ( !$CopySet && $Lines[ $i-1 ] =~ /^(.*)Copyright/ ) {
        $Output .= "$1Copyright (C) $YearString $Copy\n";
    }

    # add the rest of the file
    for ( $i .. $#Lines ) {
        $Output .= $Lines[ $_ ] . "\n";
    }

    return $Output;
}

1;
