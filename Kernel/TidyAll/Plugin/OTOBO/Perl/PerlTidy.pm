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

package TidyAll::Plugin::OTOBO::Perl::PerlTidy;

use strict;
use warnings;
use v5.24;
use utf8;

use Moo;

extends qw(TidyAll::Plugin::OTOBO::Perl);

# core modules

# CPAN modules
use Capture::Tiny qw(capture_merged);

# Require a recent version of Perl::Tidy for consistent formatting on all systems.
use Perl::Tidy v20210111;

# OTOBO modules

# Force a certain version for uniformity
if ( Perl::Tidy->VERSION() ne '20210111' ) {
    my $Error = 'Newer versions of Perl::Tidy than v20210111 are currently not supported.';
    $Error   .= ' Please use exactly that version (sudo cpanm Perl::Tidy@v20210111).';
    $Error   .= ' Your installed version is: ' . Perl::Tidy->VERSION() . ".\n";
    die $Error;
}

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled(Code => $Code);

    # Don't modify files which are derived files (have change markers).
    if ( $Code =~ m{ \$OldId: | ^ \s* \# \s* \$origin: | ^ \s* \#UX3\# }xms ) {
        return $Code;
    }

    # There was some custom code in place here to replace ',;' with ';', but that proved to
    # be much too slow on large files (> 40s on AgentTicketProcess.pm).
    # Therefore, this logic was removed.

    # This bit of insanity is needed because if some other code calls
    # Getopt::Long::Configure() to change some options, then everything can go
    # to hell. Internally perltidy() tries to use Getopt::Long without
    # resetting the configuration defaults, leading to very confusing
    # errors. See https://rt.cpan.org/Ticket/Display.html?id=118558
    Getopt::Long::ConfigDefaults();

    # perltidy reports errors in two different ways.
    # Argument/profile errors are output and an error_flag is returned.
    # Syntax errors are sent to errorfile.
    my ( $Output, $ErrorFlag, $ErrorFile, $Destination );
    $Output = capture_merged {
        $ErrorFlag = Perl::Tidy::perltidy(
            argv        => $Self->argv(),
            source      => \$Code,
            destination => \$Destination,
            errorfile   => \$ErrorFile
        );
    };
    if ($ErrorFile) {
        return $Self->DieWithError("$ErrorFile");
    }
    if ($ErrorFlag) {
        return $Self->DieWithError("$Output");
    }
    if ( defined $Output ) {
        print STDERR $Output;
    }

    return $Destination;
}

1;
