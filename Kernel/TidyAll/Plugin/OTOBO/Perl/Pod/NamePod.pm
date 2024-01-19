# --
# OTOBO is a web-based ticketing system for service organisations.
# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# Copyright (C) 2019-2024 Rother OSS GmbH, https://otobo.de/
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

package TidyAll::Plugin::OTOBO::Perl::Pod::NamePod;

use strict;
use warnings;

use File::Basename;

use Moo;

extends qw(TidyAll::Plugin::OTOBO::Perl);

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # Don't modify files which are derived files (have change markers).
    return $Code if $Code =~ m{ \$OldId: | ^ \s* \# \s* \$origin: }xms;

    my $PackageName = '';
    my $InsideNamePod;
    my $PackageNamePod;
    my $Updated = 0;

    my @CodeLines = split /\n/, $Code;

    LINE:
    for my $Line (@CodeLines) {
        if ( $Line =~ m{^package \s+? ([A-Za-z0-9:]+?);}smx ) {
            $PackageName = $1;
            next LINE;
        }

        if ( $Line =~ m{^=head1 \s+ NAME \s* $}smx ) {
            $InsideNamePod = 1;
            next LINE;
        }

        next LINE if !$InsideNamePod;
        next LINE if !$Line;
        last LINE if $Line =~ m{^=cut \s* $}smx;
        last LINE if $Line =~ m{^=head1}smx;

        if ( $Line =~ m{^\s* ([A-Za-z0-9:/\.]+)}smx ) {
            $PackageNamePod = $1;
            if ( $PackageName ne $PackageNamePod ) {
                $Line =~ s{^\s* ([A-Za-z0-9:/\.]+)}{$PackageName}smx;
                $Updated = 1;
            }
            last LINE;
        }
    }

    if ($Updated) {
        $Code = join "\n", @CodeLines;
        $Code .= "\n";
    }

    return $Code;
}

sub validate_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # Don't check files which are derived files (have change markers).
    return $Code if $Code =~ m{ \$OldId: | ^ \s* \# \s* \$origin: }xms;

    my $PackageName = '';
    my $InsideNamePod;
    my $PackageNamePod;
    my $Counter = 0;
    my $ErrorMessage;

    my @CodeLines = split /\n/, $Code;

    LINE:
    for my $Line (@CodeLines) {
        $Counter++;

        if ( $Line =~ m{^package \s+? ([A-Za-z0-9:]+?);}smx ) {
            $PackageName = $1;
            next LINE;
        }

        if ( $Line =~ m{^=head1 \s+ NAME \s* $}smx ) {
            $InsideNamePod = 1;
            next LINE;
        }

        next LINE if !$InsideNamePod;
        next LINE if !$Line;
        last LINE if $Line =~ m{^=cut \s* $}smx;
        last LINE if $Line =~ m{^=head1}smx;

        if ( $Line =~ m{^\s* ([A-Za-z0-9:/\.]+)}smx ) {
            $PackageNamePod = $1;
            if ( $PackageName ne $PackageNamePod ) {
                $ErrorMessage = "PackageName $PackageNamePod does not match package $PackageName\n";
                $ErrorMessage .= "Line $Counter: $Line\n";
            }
            last LINE;
        }
    }

    if ($ErrorMessage) {
        return $Self->DieWithError("$ErrorMessage");
    }

    return;
}

1;
