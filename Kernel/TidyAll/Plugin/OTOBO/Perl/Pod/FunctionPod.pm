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

    # temporarily disable
    # TODO CHECK
    #return;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan( 6, 0 );

    my $FunctionNameInPod = '';
    my $FunctionLineInPod = '';
    my $FunctionCallInPod = '';
    my $Counter           = 0;

    my $ErrorMessage;

    my $PackageIsRole;
    $PackageIsRole = 1 if $Code =~ m{^use \s+ Moose::Role}ismx;

    my @CodeLines = split /\n/, $Code;

    for my $Line (@CodeLines) {
        $Counter++;
        if ( $Line =~ m{^=head2 \s+ ([A-Za-z0-9]+) (\(\))? \s* $}smx ) {

            my $FunctionName  = $1;
            my $IsFunctionPod = $2 ? 1 : 0;

            if ($IsFunctionPod) {
                $FunctionNameInPod = $FunctionName;
                $FunctionLineInPod = $Line;
                chomp($FunctionLineInPod);
            }
            elsif ( $Code =~ m{sub $FunctionName} ) {
                $ErrorMessage
                    .= "Item without function (near Line $Counter), the line should look like '=item functionname()'\n";
                $ErrorMessage .= "Line $Counter: $Line\n";
            }
        }
        if ( $FunctionNameInPod && $Line =~ /->(.+?)\(/ && !$FunctionCallInPod ) {
            $FunctionCallInPod = $1;
            $FunctionCallInPod =~ s/ //;

            if ( $Line =~ /\$Self->/ && !$PackageIsRole ) {
                $ErrorMessage .= "Don't use \$Self in perldoc\n";
                $ErrorMessage .= "Line $Counter: $Line\n";
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
                $ErrorMessage .= "Line $Counter: $Line\n";
            }
        }
        if ( $FunctionNameInPod && $Line =~ /sub/ ) {
            if ( $Line =~ /sub (.+) \{/ ) {
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
        return $Self->DieWithError("$ErrorMessage");
    }

    return;
}

1;
