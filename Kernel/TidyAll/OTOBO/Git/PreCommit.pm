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

package TidyAll::OTOBO::Git::PreCommit;

use strict;
use warnings;

=head1 SYNOPSIS

This commit hook loads the OTOBO version of Code::TidyAll
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

sub Run {
    my $Self = @_;

    print "OTOBOCodePolicy commit hook starting...\n";

    my $ErrorMessage;

    try {
        # Find conf file at git root
        my $RootDir = capturex( 'git', "rev-parse", "--show-toplevel" );
        chomp($RootDir);

        # Gather file paths to be committed
        my $Output = capturex( 'git', "status", "--porcelain" );

        # Fetch only staged files that will be committed.
        my @ChangedFiles = grep { -f && !-l } ( $Output =~ /^[MA]+\s+(.*)/gm );
        push @ChangedFiles, grep { -f && !-l } ( $Output =~ /^\s*RM?+\s+(.*?)\s+->\s+(.*)/gm );
        return if !@ChangedFiles;

        # Always include all SOPM files to verify the file list.
        for my $SOPMFile ( map { File::Spec->abs2rel( $_, $RootDir ) } glob("$RootDir/*.sopm") ) {
            if ( !grep { $_ eq $SOPMFile } @ChangedFiles ) {
                push @ChangedFiles, $SOPMFile;
            }
        }

        # Find OTOBOCodePolicy configuration
        my $ScriptDirectory;
        if ( -l $0 ) {
            $ScriptDirectory = dirname( readlink($0) );
        }
        else {
            $ScriptDirectory = dirname($0);
        }
        my $ConfigFile = $ScriptDirectory . '/../tidyallrc';

        my $TidyAll = TidyAll::OTOBO->new_from_conf_file(
            $ConfigFile,
            check_only => 1,
            mode       => 'commit',
            root_dir   => $RootDir,
            data_dir   => File::Spec->tmpdir(),
        );
        $TidyAll->DetermineFrameworkVersionFromDirectory();
        $TidyAll->GetFileListFromDirectory();

        my @CheckResults = $TidyAll->ProcessPathsParallel(
            FilePaths => [ map {"$RootDir/$_"} @ChangedFiles ],
        );

        $TidyAll->HandleResults(
            Results => \@CheckResults,
        );
    }
    catch {
        my $Exception = $_;
        die "Error during pre-commit hook (use --no-verify to skip hook):\n$Exception";
    };
    if ($ErrorMessage) {
        die "$ErrorMessage\nYou can use --no-verify to skip the hook\n";
    }
}

1;
