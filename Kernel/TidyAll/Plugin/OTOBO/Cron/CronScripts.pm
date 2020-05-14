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

package TidyAll::Plugin::OTOBO::Cron::CronScripts;

use strict;
use warnings;

use File::Basename;

use parent qw(TidyAll::Plugin::OTOBO::Base);

# We only want to allow two cron files from OTOBO 5 on as the rest is managed
# via the cron daemon.

sub validate_file {
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( Filename => $Filename );
    return if $Self->IsFrameworkVersionLessThan( 5, 0 );

    my %AllowedFiles = (
        'aaa_base.dist'       => 1,
        'otobo_daemon.dist'    => 1,
        'otobo_webserver.dist' => 1,
    );

    if ( !$AllowedFiles{ File::Basename::basename($Filename) } ) {
        return $Self->DieWithError(<<"EOF");
Please migrate all scron scripts to be handled via the OTOBO Daemon (see SysConfig setting Daemon::SchedulerCronTaskManager::Task).
EOF
    }
}

1;
