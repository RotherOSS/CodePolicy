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

package TidyAll::OTOBO;

use strict;
use warnings;
use v5.24;
use utf8;

use File::Basename qw(dirname);
use lib dirname(__FILE__) . '/Plugin/OTOBO';    # Find our Perl::Critic policies

use Moo;

extends qw(Code::TidyAll);

# core modules
use File::Basename;
use File::Temp ();
use IO::File;
use POSIX ":sys_wait_h";
use Term::ANSIColor();
use Time::HiRes qw(sleep);

# CPAN modules, Require some needed modules here for clarity / better error messages.
use Code::TidyAll 0.56;
use Perl::Critic 1.140;
use Perl::Tidy;

our $FrameworkVersionMajor = 0;
our $FrameworkVersionMinor = 0;
our $ThirdpartyModule      = 0;
our @FileList              = ();    # all files in current repository

sub new_from_conf_file {
    my ( $Class, $ConfigFile, %Param ) = @_;

    my $Self = $Class->SUPER::new_from_conf_file(
        $ConfigFile,
        %Param,
        no_cache   => 1,
        no_backups => 1,
    );

    # Reset when a new object is created
    $FrameworkVersionMajor = 0;
    $FrameworkVersionMinor = 0;
    $ThirdpartyModule      = 0;
    @FileList              = ();

    return $Self;
}

sub DetermineFrameworkVersionFromDirectory {
    my ( $Self, %Param ) = @_;

    # First check if we have an OTOBO directory, use RELEASE info then.
    if ( -r $Self->{root_dir} . '/RELEASE' ) {
        my $FileHandle = IO::File->new( $Self->{root_dir} . '/RELEASE', 'r' );
        my @Content    = $FileHandle->getlines();

        my ( $VersionMajor, $VersionMinor ) = $Content[1] =~ m{^VERSION\s+=\s+(\d+)\.(\d+)\.}xms;
        $FrameworkVersionMajor = $VersionMajor;
        $FrameworkVersionMinor = $VersionMinor;
    }
    else {
        # Now check if we have a module directory with an SOPM file in it.
        my @SOPMFiles = glob $Self->{root_dir} . "/*.sopm";
        if (@SOPMFiles) {

            # Use the highest framework version from the first SOPM file.
            my $FileHandle = IO::File->new( $SOPMFiles[0], 'r' );
            my @Content    = $FileHandle->getlines();
            for my $Line (@Content) {
                if ( $Line =~ m{ <Framework (?: [ ]+ [^<>]* )? > }xms ) {
                    my ( $VersionMajor, $VersionMinor ) = $Line =~ m{ <Framework (?: [ ]+ [^<>]* )? > (\d+) \. (\d+) \. [^<*]+ <\/Framework> }xms;
                    if (
                        $VersionMajor > $FrameworkVersionMajor
                        || (
                            $VersionMajor == $FrameworkVersionMajor
                            && $VersionMinor > $FrameworkVersionMinor
                        )
                        )
                    {
                        $FrameworkVersionMajor = $VersionMajor;
                        $FrameworkVersionMinor = $VersionMinor;
                    }
                }
                elsif ( $Line =~ m{<Vendor>} && $Line !~ m{Rother OSS} ) {
                    $ThirdpartyModule = 1;
                }
            }
        }
    }

    if ($FrameworkVersionMajor) {
        print "Found OTOBO version $FrameworkVersionMajor.$FrameworkVersionMinor.\n";
    }
    else {
        print "Could not determine OTOBO version (assuming latest version)!\n";
    }

    if ($ThirdpartyModule) {
        print
            "This seems to be a module not copyrighted by Rother OSS GmbH. File copyright will not be changed.\n";
    }
    else {
        print
            "This module seems to be copyrighted by Rother OSS GmbH. File copyright will automatically be assigned to Rother OSS GmbH.\n";
        print
            "  If this is not correct, you can change the <Vendor> tag in your SOPM.\n";
    }

    return;
}

#
# Process a list of file paths in parallel with forking (if needed).
#
sub ProcessPathsParallel {
    my ( $Self, %Param ) = @_;

    my $Processes = $Param{Processes} // $ENV{OTOBOCODEPOLICY_PROCESSES} // 6;
    my @Files     = @{ $Param{FilePaths} // [] };

    # No parallel processing needed: execute directly.
    if ( $Processes <= 1 ) {
        return $Self->process_paths(@Files);
    }

    # Parallel processing. We chunk the data and execute the chunks in parallel.
    #
    # TidyAll's built-in --jobs flag is not used, it seems to be way too slow,
    #   perhaps because of forking for each single job.

    my %ActiveChildPID;

    my $Stop = sub {

        # Propagate kill signal to all forks
        for my $PID ( sort keys %ActiveChildPID ) {
            kill 9, $PID;
        }

        print "Stopped by user!\n";
        return 1;
    };

    local $SIG{INT}  = sub { $Stop->() };
    local $SIG{TERM} = sub { $Stop->() };

    my @GlobalResults;

    print "OTOBOCodePolicy will use up to $Processes parallel processes.\n";

    # To store results from child processes.
    my $TempDirectory = File::Temp->newdir() || die "Could not create temporary directory: $!";

    # split chunks of files for every process
    my @Chunks;
    my $ItemCount = 0;

    for my $File (@Files) {
        push @{ $Chunks[ $ItemCount++ % $Processes ] }, $File;
    }

    CHUNK:
    for my $Chunk (@Chunks) {

        # Create a child process.
        my $PID = fork;

        # Child process could not be created.
        if ( $PID < 0 ) {
            die "Unable to fork a child process for tiding!";
        }

        # Child process.
        if ( !$PID ) {

            my @Results = $Self->process_paths( @{$Chunk} );

            my $ChildPID = $$;
            Storable::store( \@Results, "$TempDirectory/$ChildPID.tmp" );

            # Close child process at the end.
            exit 0;
        }

        # Parent process.
        $ActiveChildPID{$PID} = {
            PID => $PID,
        };
    }

    # Check the status of all child processes every 0.1 seconds.
    # Wait for all child processes to be finished.
    WAIT:
    while (1) {

        last WAIT if !%ActiveChildPID;
        sleep 0.1;

        PID:
        for my $PID ( sort keys %ActiveChildPID ) {

            my $WaitResult = waitpid( $PID, WNOHANG );

            die "Child process '$PID' exited with errors: $?" if $WaitResult == -1;

            if ($WaitResult) {

                my $TempFile = "$TempDirectory/$PID.tmp";
                my $Results;

                if ( !-e $TempFile ) {
                    die "Could not read results of process $PID.\n";
                }

                $Results = Storable::retrieve($TempFile);
                unlink $TempFile;

                # Join the child results.
                @GlobalResults = ( @GlobalResults, @{ $Results || [] } );

                delete $ActiveChildPID{$PID};
            }
        }
    }

    return @GlobalResults;
}

#
# Print a useful summary and die in case of errors.
#
sub HandleResults {
    my ( $Self, %Param ) = @_;

    my @GlobalResults = @{ $Param{Results} // [] };

    my @ErrorResults = grep { $_->error() } @GlobalResults;
    if (@ErrorResults) {
        my $ErrorCount   = scalar(@ErrorResults);
        my $ErrorMessage = sprintf(
            _ReplaceColorTags("\n<red>Error: %d file(s) did not pass validation.</red>\n"),
            $ErrorCount,
        );
        if ( $ErrorCount < 10 ) {
            for my $Error (@ErrorResults) {
                $ErrorMessage .= " - " . $Error->path() . "\n";
            }
        }
        die "$ErrorMessage\n";
    }

    my @TidiedResults = grep { $_->state() eq 'tidied' } @GlobalResults;
    if (@TidiedResults) {
        printf(
            _ReplaceColorTags("\n<green>Validation finished,</green> <yellow>%d file(s) were tidied.</yellow>\n"),
            scalar(@TidiedResults),
        );

    }
    else {
        print _ReplaceColorTags("\n<green>Validation finished, no problems found.</green>\n");
    }

    return 1;
}

#
# Get a list (almost) all relative file paths from the root directory. This list is used in some plugins to make validation decisions,
#   not for the actual decision which files are to be validated.
#
sub GetFileListFromDirectory {
    my ( $Self, %Param ) = @_;

    # Only run once.
    return if @FileList;

    @FileList = $Self->FindFilesInDirectory( Directory => $Self->{root_dir} );

    return;
}

#
# Get a list of all relative file paths in a directory with some global ignores for speed's sake.
#
sub FindFilesInDirectory {
    my ( $Self, %Param ) = @_;

    my $Directory = $Param{Directory};

    my @Files;

    my $Wanted = sub {

        # Skip non-regular files and directories.
        return if ( !-f $File::Find::name );

        # Also skip symbolic links, TidyAll does not like them.
        return if ( -l $File::Find::name );

        # Some global hard ignores that are meant to speed up the loading process,
        #   as applying the TidyAll ignore/select rules can be quite slow.
        return if $File::Find::name =~ m{/\.git/};
        return if $File::Find::name =~ m{/\.tidyall.d/};
        return if $File::Find::name =~ m{/\.vscode/};
        return if $File::Find::name =~ m{/node_modules/};
        return if $File::Find::name =~ m{/js-cache/};
        return if $File::Find::name =~ m{/css-cache/};
        return if $File::Find::name =~ m{/var/tmp/} && $File::Find::name !~ m{.*\.sample$};
        return if $File::Find::name =~ m{/var/public/dist/};

        push @Files, File::Spec->abs2rel( $File::Find::name, $Self->{root_dir} );
    };

    File::Find::find(
        $Wanted,
        $Directory,
    );

    return @Files;
}

#
# Filter relative file paths for only the files that are matched by at least one plugin.
#
sub FilterMatchedFiles {
    my ( $Self, %Param ) = @_;

    return grep { $Self->plugins_for_path($_) } @{ $Param{Files} };
}

sub _ReplaceColorTags {
    my ($Text) = @_;

    $Text //= '';

    $Text =~ s{<(green|yellow|red)>(.*?)</\1>}{_Color($1, $2)}gsmxe;

    return $Text;
}

=head2 _Color()

This will color the given text (see Term::ANSIColor::color()) if ANSI output is available and active, otherwise the text
stays unchanged.

    my $PossiblyColoredText = _Color('green', $Text);

=cut

sub _Color {
    my ( $Color, $Text ) = @_;

    return $Text if $ENV{OTOBOCODEPOLICY_NOCOLOR};

    return Term::ANSIColor::color($Color) . $Text . Term::ANSIColor::color('reset');
}

1;
