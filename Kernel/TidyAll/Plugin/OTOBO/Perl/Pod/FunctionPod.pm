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

package TidyAll::Plugin::OTOBO::Perl::Pod::FunctionPod;

use strict;
use warnings;

use File::Basename;

use parent qw(TidyAll::Plugin::OTOBO::Perl);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    my $FunctionNameInPod = '';
    my $FunctionLineInPod = '';
    my $FunctionCallInPod = '';
    my $LineNumber        = 0;

    my $ErrorMessage = '';

    my $PackageIsRole;
    $PackageIsRole = 1 if $Code =~ m{^use \s+ Moose::Role}ismx;

    my @CodeLines = split /\n/, $Code;

    for my $Line (@CodeLines) {
        $LineNumber++;

        # Check the formatting of the actual head2 line
        # POD for functions is recognised by the single word after the '=head2'.
        # POD for private functions, which have a leading '_' in their name, is not checked.
        if ( $Line =~ m{^=head2 \s+ ([A-Za-z0-9]+) (\(\))? \s* $}smx ) {

            my $FunctionName  = $1;
            my $IsFunctionPod = $2 ? 1 : 0;

            if ($IsFunctionPod) {
                $FunctionNameInPod = $FunctionName;
                $FunctionLineInPod = $Line;
                chomp $FunctionLineInPod;
            }
            elsif ( $Code =~ m{sub $FunctionName} ) {
                $ErrorMessage .= "Item without function (near Line $LineNumber), the line should look like '=head2 SampleFunction()'\n";
                $ErrorMessage .= "Line $LineNumber: $Line\n";
            }
        }

        # look at the sample code in the POD
        if ( $FunctionNameInPod && $Line =~ m/->(.+?)\(/ && !$FunctionCallInPod ) {
            $FunctionCallInPod = $1;
            $FunctionCallInPod =~ s/ //;

            if ( $Line =~ /\$Self->/ && !$PackageIsRole ) {
                $ErrorMessage .= "Don't use \$Self in perldoc\n";
                $ErrorMessage .= "Line $LineNumber: $Line\n";
            }
            elsif ( $FunctionNameInPod ne $FunctionCallInPod ) {
                if ( $FunctionNameInPod ne 'new' || ( $FunctionCallInPod ne 'Get' && $FunctionCallInPod ne 'Create' ) )
                {
                    my $DescriptionLine = $Line;
                    chomp($DescriptionLine);
                    $ErrorMessage .= "$FunctionLineInPod <-> $DescriptionLine\n";
                }
            }

            if ( $FunctionNameInPod && $Line !~ /\$[A-Za-z0-9:]+->(.+?)\(/ && $FunctionNameInPod ne 'new' ) {
                $ErrorMessage .= "The function syntax is not correct!\n";
                $ErrorMessage .= "Line $LineNumber: $Line\n";
            }
        }

        # look at the sub declaration following the POD
        if ( $FunctionNameInPod && $Line =~ m/sub/ ) {
            if ( $Line =~ m/sub (.+) \{/ ) {
                my $FunctionSub = $1;
                $FunctionSub =~ s/ //;
                my $SubLine = $Line;

                if ( $FunctionSub ne $FunctionNameInPod ) {
                    chomp($SubLine);
                    $ErrorMessage .= "$FunctionLineInPod <-> $SubLine \n";
                }
            }
            $FunctionNameInPod = '';
            $FunctionCallInPod = '';
        }
    }

    if ($ErrorMessage) {
        return $Self->DieWithError($ErrorMessage);
    }

    return;
}

1;
