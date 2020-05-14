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

package TidyAll::Plugin::OTOBO::Perl::SyntaxCheck;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTOBO::Perl);

use File::Temp;

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 2, 4 );

    my ( $CleanedSource, $DeletableStatement );

    # Allow important modules that come with the Perl core or are external
    #   dependencies of OTOBO and can thus be assumed as being installed.
    my @AllowedExternalModules = qw(
        vars
        constant
        strict
        warnings
        threads
        lib

        Archive::Zip
        Archive::Tar
        Cwd
        Carp
        Data::Dumper
        DateTime
        DBI
        Fcntl
        File::Basename
        FindBin
        IO::Socket
        List::Util
        Moo
        Moose
        Perl::Critic::Utils
        POSIX
        Readonly
        Template
        Time::HiRes
    );

    my $AllowedExternalModulesRegex = '\A \s* use \s+ (?: ' . join( '|', @AllowedExternalModules ) . ' ) ';

    LINE:
    for my $Line ( split( /\n/, $Code ) ) {

        # We'll skip all use *; statements exept for core modules because the modules cannot be found at runtime.
        if ( $Line =~ m{ \A \s* use \s+ }xms && $Line !~ m{$AllowedExternalModulesRegex}xms ) {
            $DeletableStatement = 1;
        }

        if ($DeletableStatement) {
            $Line = "#$Line";
        }

        if ( $Line =~ m{ ; \s* \z }xms ) {
            $DeletableStatement = 0;
        }

        $CleanedSource .= $Line . "\n";
    }

    #print STDERR $CleanedSource;

    my $TempFile = File::Temp->new();
    print $TempFile $CleanedSource;
    $TempFile->flush();

    # syntax check
    my $ErrorMessage;
    my $FileHandle;
    if ( !open $FileHandle, '-|', "perl -cw " . $TempFile->filename() . " 2>&1" ) {    ## no critic
        return $Self->DieWithError("FILTER: Can't open tempfile: $!\n");
    }

    while ( my $Line = <$FileHandle> ) {
        if ( $Line !~ /(syntax OK|used only once: possible typo)/ ) {
            $ErrorMessage .= $Line;
        }
    }
    close $FileHandle;

    if ($ErrorMessage) {
        return $Self->DieWithError("$ErrorMessage");
    }
}

1;
