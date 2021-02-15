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

use vars (qw($Self));
use utf8;

use File::Basename;
use FindBin qw($RealBin);
use lib dirname($RealBin) . '/Kernel/';    # find TidyAll

# Work around a Perl bug that is triggered in Devel::StackTrace
#   (probaly from Exception::Class and this from Perl::Critic).
#
#   See https://github.com/houseabsolute/Devel-StackTrace/issues/11 and
#   http://rt.perl.org/rt3/Public/Bug/Display.html?id=78186
no warnings 'redefine';    ## no critic qw(TestingAndDebugging::ProhibitNoWarnings)
use Devel::StackTrace ();
local *Devel::StackTrace::new = sub { };    # no-op
use warnings 'redefine';

use File::Spec();
use TidyAll::OTOBO;

# Don't use OM so that this also works for OTOBO 3.3 and lower
use Kernel::Config;

my $ConfigObject = Kernel::Config->new();
my $Home         = $ConfigObject->Get('Home');

# Suppress colored output to not clutter log files.
local $ENV{OTOBOCODEPOLICY_NOCOLOR} = 1;

my $TidyAll = TidyAll::OTOBO->new_from_conf_file(
    "$Home/Kernel/TidyAll/tidyallrc",
    check_only => 1,
    mode       => 'tests',
    root_dir   => $Home,
    data_dir   => File::Spec->tmpdir(),
    quiet      => 1,
);
$TidyAll->DetermineFrameworkVersionFromDirectory();
$TidyAll->GetFileListFromDirectory();

#
# Now perform the real file validation.
#

# Don't use TidyAll::process_all() or TidyAll::find_matched_files() as it is too slow on large code bases.
my @Files = $TidyAll->FilterMatchedFiles( Files => \@TidyAll::OTOBO::FileList );
@Files = map { File::Spec->catfile( $Home, $_ ) } @Files;

FILE:
for my $File (@Files) {

    # Ignore Oracle log files.
    next FILE if $File =~ m{oradiag};

    my $Result = $TidyAll->process_file($File);

    next FILE if $Result->state() eq 'no_match';    # no plugins apply, ignore file

    $Self->Is(
        $Result->state(),
        'checked',
        "$File check results " . ( $Result->error() || '' ),
    );
}

1;
