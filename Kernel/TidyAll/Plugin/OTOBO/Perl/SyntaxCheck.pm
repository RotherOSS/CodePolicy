# --
# OTOBO is a web-based ticketing system for service organisations.
# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# Copyright (C) 2019-2025 Rother OSS GmbH, https://otobo.io/
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

use v5.24;
use strict;
use warnings;
use namespace::autoclean;
use utf8;

use Moo;

extends qw(TidyAll::Plugin::OTOBO::Perl);

# core modules
use File::Temp;

# CPAN modules

# OTOBO modules

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    # Simple compile checks very often fail because required modules are not available.
    # But installed modules are not the scope of this test, therefore we remove many
    # of the 'use' statement. But keep some modules and pragmata because removing them
    # would have an adverse effect.
    my ( $CleanedSource, $DeletableStatement );

    # Allow important modules that come with the Perl core or are external
    #   dependencies of OTOBO and can thus be assumed as being installed.
    #   Some common modules that are used during development are also not stripped.
    #
    # Note that this is not fool proof. Modules like DateTime::TimeZone::ICal would
    # also not be stripped as the that module name contains the substring 'DateTime'.
    #
    # The 'use v5.xx' lines are also kept in the file. This is fine as there is a Perl::Critic
    # policy that enforces that no version of Perl higher than the minimal supported version
    # is required.
    my @AllowedExternalModules = qw(
        vars
        constant
        strict
        warnings
        threads
        lib

        v5.\d\d

        Archive::Tar
        Archive::Zip
        Carp
        Config
        Const::Fast
        Cpanel::JSON::XS
        Cwd
        DBI
        Data::Dumper
        Data::Dx
        DateTime
        Encode
        Encode::Locale
        Fcntl
        File::Basename
        FindBin
        IO::Socket
        List::AllUtils
        List::Util
        Moo
        Moose
        POSIX
        Perl::Critic::Utils
        Readonly
        Template
        Test2::V0
        Test2::Tools::Spec
        Time::HiRes
        Types::Serialiser
    );

    my $AllowedExternalModulesRegex = '\A \s* use \s+ (?: ' . join( '|', @AllowedExternalModules ) . ' ) ';

    LINE:
    for my $Line ( split /\n/, $Code ) {

        # Check for 'use VERSION' declarations like 'use v5.42'. Avoid requiring a version higher
        # than the minimal supported version.
        my $MinimalSupportedVersion = '5.26';
        if ( my ($RequiredVersion) = $Line =~ m{ \A \s* use \s+ v(5.\d\d) }xms ) {
            if ( $RequiredVersion gt $MinimalSupportedVersion ) {
                return $Self->DieWithError("Perl $RequiredVersion is required but $MinimalSupportedVersion is the minimal supported version\n");
            }
        }

        # We'll skip all use *; statements exept for excempted modules
        if ( $Line =~ m{ \A \s* use \s+ }xms && $Line !~ m{$AllowedExternalModulesRegex}xms ) {
            $DeletableStatement = 1;
        }

        if ($DeletableStatement) {
            $Line = "#$Line";
        }

        # Look for the end of the the 'use' statement.
        # The statement terminator may be followed by an end of line comment.
        # All assuming that the ';' is not part of an item in the import list.
        if ( $Line =~ m{ ; \s* (?: \# .*)? \z }xms ) {
            $DeletableStatement = 0;
        }

        $CleanedSource .= $Line . "\n";
    }

    my $TempFile = File::Temp->new;
    print $TempFile $CleanedSource;
    $TempFile->flush;

    # syntax check
    my $ErrorMessage;
    {
        if ( open my $FileHandle, '-|', "perl -cw " . $TempFile->filename() . " 2>&1" ) {    ## no critic qw(OTOBO::ProhibitOpen)
            while ( my $Line = <$FileHandle> ) {
                if ( $Line !~ /(syntax OK|used only once: possible typo)/ ) {
                    $ErrorMessage .= $Line;
                }
            }
            close $FileHandle;
        }
        else {
            return $Self->DieWithError("FILTER: Can't open tempfile: $!\n");
        }
    }

    if ($ErrorMessage) {
        return $Self->DieWithError("$ErrorMessage");
    }
}

1;
