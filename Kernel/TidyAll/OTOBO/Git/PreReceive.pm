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

package TidyAll::OTOBO::Git::PreReceive;

use strict;
use warnings;

=head1 SYNOPSIS

This pre receive hook loads the OTOBO version of Code::TidyAll
with the custom plugins, executes it for any modified files
and returns a corresponding status code.

=cut

use Cwd;
use File::Spec;
use File::Basename;

use Code::TidyAll;
use IPC::System::Simple qw(capturex run);
use Try::Tiny;
use TidyAll::OTOBO;
use Moo;

# Ignore these repositories on the server so that we can always push to them.
my %IgnoreRepositories = (
    'otobocodepolicy.git' => 1,

    # auto-generated documentation
    'otobo-github-io.git' => 1,    # deprecated
    'doc-otobo-com.git'   => 1,

    # documentation toolchain
    'docbuild.git' => 1,

    # Thirdparty code
    'bugs-otobo-org.git' => 1,

    # OTOBO Blog
    'blog-otobo-com.git' => 1,

    # OTOBO Blog
    'www-otobo-com.git' => 1,

    # OTOBOTube
    'clips-otobo-com.git' => 1,

    # Internal UX/UI team repository
    'ux-ui.git' => 1,

    # Streamline icons repository
    'streamline-icons.git' => 1,

    # CKEditor 5 custom build repository
    'ckeditor5-build-inline-otobo.git' => 1,

    # OTOBO Mobile App repository
    'otobo-mobile-app.git' => 1,
);

sub Run {
    my ( $Self, %Param ) = @_;

    my $ErrorMessage;
    try {

        print "OTOBOCodePolicy pre receive hook starting...\n";

        my $Input = $Param{Input};
        if ( !$Input ) {
            $Input = do { local $/ = undef; <> };
        }

        # Debug
        #print "Got data:\n$Input";

        my $RootDirectory = Cwd::realpath();
        local $ENV{GIT_DIR} = $RootDirectory;

        my $RepositoryName = [ split m{/}, $RootDirectory ]->[-1];
        if ( $IgnoreRepositories{$RepositoryName} ) {
            print "Skipping checks for repository $RepositoryName.\n";
            return;
        }

        $ErrorMessage = $Self->HandleInput($Input);
    }
    catch {
        my $Exception = $_;
        print STDERR "*** Error running pre-receive hook (allowing push to proceed):\n$Exception";
    };
    if ($ErrorMessage) {
        print STDERR "$ErrorMessage\n";
        print STDERR "*** Push was rejected. Please fix the errors and try again. ***\n";
        exit 1;
    }
}

sub HandleInput {
    my ( $Self, $Input ) = @_;

    my @Lines = split( m/\n/, $Input );

    my (@Results);

    LINE:
    for my $Line (@Lines) {
        chomp($Line);
        my ( $Base, $Commit, $Ref ) = split( m/\s+/, $Line );

        if ( $Commit =~ m/^0+$/ ) {

            # No target commit (branch / tag delete).
            next LINE;
        }

        if ( substr( $Ref, 0, 9 ) eq 'refs/tags' ) {

            # Only allow "rel-*" as name for new and updated tags.
            if ( $Ref !~ m{ \A refs/tags/rel-\d+_\d+_\d+ (_alpha\d+ | _beta\d+ | _rc\d+)? \z }xms ) {

                my $ErrorMessage
                    = "Error: found invalid tag '$Ref' - please only use rel-A_B_C or rel-A_B_C_(alpha|beta|rc)D.";
                return $ErrorMessage;
            }

            # Valid tag.
            next LINE;
        }

        print "Checking framework version for $Ref... ";

        my @FileList = $Self->GetGitFileList($Commit);

        # Create tidyall for each branch separately
        my $TidyAll = $Self->CreateTidyAll( $Commit, \@FileList );

        my @ChangedFiles = $Self->GetChangedFiles( $Base, $Commit );

        # Always include all SOPM files to verify the file list.
        for my $SOPMFile ( grep { $_ =~ m{\.sopm$} } @FileList ) {
            if ( !grep { $_ eq $SOPMFile } @ChangedFiles ) {
                push @ChangedFiles, $SOPMFile;
            }
        }

        FILE:
        for my $File (@ChangedFiles) {

            # Don't try to validate deleted files.
            if ( !grep { $_ eq $File } @FileList ) {
                print "$File was deleted, ignoring.\n";
                next FILE;
            }

            # Get file from git repository.
            my $Contents = $Self->GetGitFileContents( $File, $Commit );

            # Only validate files which actually have some content.
            if ( $Contents =~ /\S/ && $Contents =~ /\n/ ) {
                push( @Results, $TidyAll->process_source( $Contents, $File ) );
            }
        }
    }

    if ( my @ErrorResults = grep { $_->error() } @Results ) {
        return sprintf( "Error: %d file(s) did not pass validation", scalar(@ErrorResults) );
    }

    return;
}

sub CreateTidyAll {
    my ( $Self, $Commit, $FileList ) = @_;

    # Find OTOBOCodePolicy configuration
    my $ConfigFile = dirname(__FILE__) . '/../../tidyallrc';

    my $TidyAll = TidyAll::OTOBO->new_from_conf_file(
        $ConfigFile,
        check_only => 1,
        mode       => 'commit',
    );

    # We cannot use these functions here because we have a bare git repository,
    #   so we have to do it on our own.
    #$TidyAll->DetermineFrameworkVersionFromDirectory();
    #$TidyAll->GetFileListFromDirectory();

    # Set the list of files to be checked
    @TidyAll::OTOBO::FileList = @{$FileList};

    # Now we try to determine the OTOBO version from the commit

    # Look for a RELEASE file first to determine the framework version
    if ( grep { $_ eq 'RELEASE' } @{$FileList} ) {
        my @Content = split /\n/, $Self->GetGitFileContents( 'RELEASE', $Commit );

        my ( $VersionMajor, $VersionMinor ) = $Content[1] =~ m{^VERSION\s+=\s+(\d+)\.(\d+)\.}xms;
        $TidyAll::OTOBO::FrameworkVersionMajor = $VersionMajor;
        $TidyAll::OTOBO::FrameworkVersionMinor = $VersionMinor;
    }

    # Look for any SOPM files
    else {
        FILE:
        for my $File ( @{$FileList} ) {
            if ( substr( $File, -5, 5 ) eq '.sopm' ) {
                my @Content = split /\n/, $Self->GetGitFileContents( $File, $Commit );

                for my $Line (@Content) {
                    if ( $Line =~ m{ <Framework (?: [ ]+ [^<>]* )? > }xms ) {
                        my ( $VersionMajor, $VersionMinor )
                            = $Line =~ m{ <Framework (?: [ ]+ [^<>]* )? > (\d+) \. (\d+) \. [^<*]+ <\/Framework> }xms;
                        if (
                            $VersionMajor > $TidyAll::OTOBO::FrameworkVersionMajor
                            || (
                                $VersionMajor == $TidyAll::OTOBO::FrameworkVersionMajor
                                && $VersionMinor > $TidyAll::OTOBO::FrameworkVersionMinor
                            )
                            )
                        {
                            $TidyAll::OTOBO::FrameworkVersionMajor = $VersionMajor;
                            $TidyAll::OTOBO::FrameworkVersionMinor = $VersionMinor;
                        }
                    }
                    elsif ( $Line =~ m{<Vendor>} && $Line !~ m{Rother OSS} ) {
                        $TidyAll::OTOBO::ThirdpartyModule = 1;
                    }
                }

                last FILE;
            }
        }
    }

    if ($TidyAll::OTOBO::FrameworkVersionMajor) {
        print
            "Found OTOBO version $TidyAll::OTOBO::FrameworkVersionMajor.$TidyAll::OTOBO::FrameworkVersionMinor\n";
    }
    else {
        print "Could not determine OTOBO version (assuming latest version)!\n";
    }

    if ($TidyAll::OTOBO::ThirdpartyModule) {
        print
            "This seems to be a module not copyrighted by Rother OSS GmbH. File copyright will not be changed.\n";
    }
    else {
        print
            "This module seems to be copyrighted by Rother OSS GmbH. File copyright will automatically be assigned to Rother OSS GmbH.\n";
        print
            "  If this is not correct, you can change the <Vendor> tag in your SOPM.\n";
    }

    return $TidyAll;
}

sub GetGitFileContents {
    my ( $Self, $File, $Commit ) = @_;
    my $Content = capturex( "git", "show", "$Commit:$File" );
    return $Content;
}

sub GetGitFileList {
    my ( $Self, $Commit ) = @_;
    my $Output = capturex( "git", "ls-tree", "--name-only", "-r", "$Commit" );
    return split /\n/, $Output;
}

sub GetChangedFiles {
    my ( $Self, $Base, $Commit ) = @_;

    # Only use the last commit if we have a new branch.
    #   This is not perfect, but otherwise quite complicated.
    if ( $Base =~ m/^0+$/ ) {
        my $Output = capturex( 'git', 'diff-tree', '--no-commit-id', '--name-only', '-r', $Commit );
        my @Files  = grep {/\S/} split( m/\n/, $Output );
        return @Files;
    }

    my $Output = capturex( 'git', "diff", "--numstat", "--name-only", "$Base..$Commit" );
    my @Files  = grep {/\S/} split( m/\n/, $Output );
    return @Files;
}

1;
