#!/usr/bin/env perl
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

use strict;
use warnings;

# core modules
use IO::File;

# CPAN modules

# OTOBO modules

=head1 NAME

prepare-commit-msg.pl - a git hook

=head1 DESCRIPTION

This git hook preset the commit message when running I<git commit>.
Two different features are supported.

=head2 reference the Github issue based on a naming convention for the branch

When the current git branch is recognised as an issue branch then
the commit message is prepended with 'Issue #<ISSUE_ID>:'.

Examples for issue branch names are:

    issue-#513-prepare_commit_msg
    issue-rotheross/otobo#513-prepare_commit_msg
    issue-RotherOSS/otobo-docker#1-example
    issue-RotherOSS/otobo-docker#2-x


=head2 include the file .git/OTOBOCommitTemplateFile.msg

This is support for a workflow that generates text for the commit message and writes it to
an agreed upon file. After including it, the transfer file is deleted.

Currently no example of such a workflow is known.

=cut

# git calls this script with the arguments: COMMIT_MSG_FILE, COMMIT_SOURCE, SHA1.
# Here only COMMIT_MSG_FILE and COMMIT_SOURCE are needed.
my ( $GitCommitMsgFile, $GitCommitSource ) = @ARGV;

my @CustomCommitMsg;

# feature 1
# For now we mess only with interactive commits, that is when $GitCommitSource is empty.
if ( !$GitCommitSource ) {

    # find out which branch we are on
    my $BranchName = `git rev-parse --abbrev-ref HEAD`;
    chomp $BranchName;

    # Do nothing unless the issue can be extracted from the git branch name.
    if ( my ($Issue) = $BranchName =~ m/^issue-(.*#[0-9]+)-[^-]+/ ) {

        # Prepend the issue to the commit message.
        push @CustomCommitMsg, "Issue $Issue:";
    }
}

# feature 2
{
    my $OTOBOCommitTemplateFile = '.git/OTOBOCommitTemplate.msg';

    if ( -r $OTOBOCommitTemplateFile ) {

        # Get our content and prepend it
        my $FileHandle = IO::File->new( $OTOBOCommitTemplateFile, 'r' );
        push @CustomCommitMsg, $FileHandle->getlines();

        # Remove custom commit message template
        unlink $OTOBOCommitTemplateFile;
    }
}

# prepend the custom text to the commit message
if (@CustomCommitMsg) {

    my $FileHandleIn = IO::File->new( $GitCommitMsgFile, 'r' );
    my @OldCommitMsg = $FileHandleIn->getlines();

    # Write new commit message
    my $FileHandleOut = IO::File->new( $GitCommitMsgFile, 'w' );
    $FileHandleOut->print( join '', @CustomCommitMsg, @OldCommitMsg );
}
