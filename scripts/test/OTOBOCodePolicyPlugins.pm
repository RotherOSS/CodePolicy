# --
# OTOBO is a web-based ticketing system for service organisations.
# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# Copyright (C) 2019-2023 Rother OSS GmbH, https://otobo.de/
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
package scripts::test::OTOBOCodePolicyPlugins;

## nofilter(TidyAll::Plugin::OTOBO::Perl::Require)

use strict;
use warnings;
use utf8;

# core modules

# CPAN modules
use Test2::V0;

# OTOBO modules
use TidyAll::OTOBO;

sub Run {
    my (%Param) = @_;

    # Suppress colored output to not clutter log files.
    local $ENV{OTOBOCODEPOLICY_NOCOLOR} = 1;

    my $TidyAll = TidyAll::OTOBO->new_from_conf_file(
        "./Kernel/TidyAll/tidyallrc",
        no_cache   => 1,
        check_only => 1,
        mode       => 'tests',
        root_dir   => '.',
        data_dir   => File::Spec->tmpdir(),

        #verbose    => 1,
    );

    TEST:
    for my $Test ( $Param{Tests}->@* ) {

        # Set framework version in TidyAll so that plugins can use it.
        my ( $FrameworkVersionMajor, $FrameworkVersionMinor ) = $Test->{Framework} =~ m/(\d+)[.](\d+)/xms;
        $TidyAll::OTOBO::FrameworkVersionMajor = $FrameworkVersionMajor;
        $TidyAll::OTOBO::FrameworkVersionMinor = $FrameworkVersionMinor;

        # Set the list of files to the same one defined in the test case.
        @TidyAll::OTOBO::FileList = @{ $Test->{FileList} // [] };

        my $Source = $Test->{Source};

        eval {
            for my $PluginModule ( @{ $Test->{Plugins} } ) {
                my $FileName = "$PluginModule.pm" =~ s{::}{/}smxgr;

                require $FileName;

                my $Plugin = $PluginModule->new(
                    name    => $PluginModule,
                    tidyall => $TidyAll,
                );

                for my $Method (qw(preprocess_source process_source_or_file postprocess_source)) {
                    ($Source) = $Plugin->$Method( $Source, $Test->{Filename} );
                }
            }
        };

        my $Exception = $@;

        is(
            $Exception ? 1 : 0,
            $Test->{Exception},
            "$Test->{Name} - " . ( $Exception ? "exception found:\n$Exception" : 'no exception' ),
        );

        next TEST if $Exception;

        is(
            $Source,
            $Test->{Result} // $Test->{Source},
            "$Test->{Name} - result",
        );
    }

    return;
}

1;
