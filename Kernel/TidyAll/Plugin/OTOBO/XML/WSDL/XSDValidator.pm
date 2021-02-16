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

package TidyAll::Plugin::OTOBO::XML::WSDL::XSDValidator;

use strict;
use warnings;

use File::Basename;
use parent qw(TidyAll::Plugin::OTOBO::Base);

sub validate_file {
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( Filename => $Filename );

    # read the file as an array
    open( my $FileHandle, '<', $Filename ) || die $!;    ## no critic qw(OTOBO::ProhibitOpen)
    my $String = do { local $/ = undef; <$FileHandle> };
    close $FileHandle;

    my $LiteralStyle;

    # check if WSDL file uses Literal messages
    if ( $String =~ m{<soap:body \s+ use="literal"}msxi ) {
        $LiteralStyle = 1;
    }

    # generate the XMLLint command based on the style of WSDL
    my $XSDDir = dirname(__FILE__) . '/../../StaticFiles/XSD/WSDL/';

    my $XSDFile = 'WSDL.xsd';
    if ($LiteralStyle) {
        $XSDFile = 'Literal.xsd';
    }

    my $CMD = "xmllint --noout --nonet --nowarning --schema $XSDDir$XSDFile";

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
