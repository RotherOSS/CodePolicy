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

package TidyAll::Plugin::OTOBO::XML::Docbook::XSDValidator;

use strict;
use warnings;

use File::Basename;
use parent qw(TidyAll::Plugin::OTOBO::Base);

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # convert format attribute content in imagedata tag to upper case
    #    e.g. from format="png" to format="PNG"
    $Code =~ s{(<imagedata [^>]+ format=")(.+?)(" [^>]+ >)}
        {
            my $Start  = $1;
            my $Format = $2;
            my $End    = $3;
            if ($Format ne 'linespecific') {
                $Format = uc $Format;
            }
            my $Result = $Start . $Format . $End;
        }msxge;

    return $Code;
}

sub validate_file {
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( Filename => $Filename );
    return if $Self->IsFrameworkVersionLessThan( 3, 1 );

    # read the file as an array
    open( my $FileHandle, '<', $Filename ) || die $!;    ## no critic qw(OTOBO::ProhibitOpen)
    my @FileLines = <$FileHandle>;
    close $FileHandle;

    my $Version;

    # get the DocBook version from the DocType e.g. 4.4
    if ( $FileLines[1] =~ m{DTD [ ] DocBook [ ] XML [ ] V(\d\.\d)//}msxi ) {
        $Version = $1;
    }
    return if !$Version;

    # check if we have an XSD available for the detected version:
    my %AvailableVersions = (
        '4.2' => 1,
        '4.3' => 1,
        '4.4' => 1,
        '4.5' => 1,
    );
    if ( !$AvailableVersions{$Version} ) {
        print STDERR "No DocBook XSD available for version $Version\n";
        return;
    }

    # convert the version to a directory safe string e.g. 4_4
    $Version =~ s{\.}{_};

    # generate the XMLLint command based on the version of the DocBook file
    my $XSDFile = dirname(__FILE__) . '/../../StaticFiles/XSD/Docbook/' . $Version . '/docbook.xsd';
    my $CMD     = "xmllint --noout --nonet --nowarning --schema $XSDFile";

    my $Command = sprintf( "%s %s %s 2>&1", $CMD, $Self->argv(), $Filename );
    my $Output  = `$Command`;

    # If execution failed, warn about installing package.
    if ( ${^CHILD_ERROR_NATIVE} == -1 ) {
        return $Self->DieWithError("'xmllint' was not found, please install it.\n");
    }

    if ( ${^CHILD_ERROR_NATIVE} ) {
        return $Self->DieWithError("$Output\n");    # non-zero exit code
    }
}

1;
