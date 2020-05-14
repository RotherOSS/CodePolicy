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

package TidyAll::Plugin::OTOBO::XML::ConfigSyntax;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTOBO::Base);

use XML::Parser;

# This plugin does not transform any files. Following method is implemented only because it's executed before
#   validate_source and contains filename of the file. Filename is saved in $Self for later use.
sub transform_file {
    my ( $Self, $Filename ) = @_;

    # Store filename for later use.
    $Self->{Filename} = $Filename;

    return;
}

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 2, 4 );

    my $ErrorMessage;
    my $Counter;

    for my $Line ( split /\n/, $Code ) {
        $Counter++;

        # Check first XML line
        if ( $Counter == 1 ) {
            if (
                $Line    !~ /^<\?xml.+\?>/
                || $Line !~ /version=["'']1.[01]["']/
                || $Line !~ /encoding=["'](?:iso-8859-1|utf-8)["']/i
                )
            {
                $ErrorMessage
                    .= "The first line of the file should have the content <?xml version=\"1.0\" encoding=\"utf-8\" ?>.\n";
                $ErrorMessage .= "Line $Counter: $Line\n";
            }
        }

        # Validate otobo_config tag
        if ( $Line =~ /^<otobo_config/ ) {

            if ( $Self->IsFrameworkVersionLessThan( 6, 0 ) ) {
                if (
                    $Line !~ /init="(Framework|Application|Config|Changes)"/
                    || $Line !~ /version="1.0"/
                    )
                {
                    $ErrorMessage
                        .= "The <otobo_config>-tag has missing or incorrect attributes. ExampleLine: <otobo_config version=\"1.0\" init=\"Application\">\n";
                    $ErrorMessage .= "Line $Counter: $Line\n";
                }
            }
            else {
                my $Version = '2.0';

                if (
                    $Line !~ /init="(Framework|Application|Config|Changes)"/
                    || $Line !~ /version="$Version"/
                    )
                {
                    $ErrorMessage
                        .= "The <otobo_config>-tag has missing or incorrect attributes. ExampleLine: <otobo_config version=\"2.0\" init=\"Application\">\n";
                    $ErrorMessage .= "Line $Counter: $Line\n";
                }
            }
        }
    }

    if ($ErrorMessage) {
        return $Self->DieWithError("$ErrorMessage");
    }
}

1;
