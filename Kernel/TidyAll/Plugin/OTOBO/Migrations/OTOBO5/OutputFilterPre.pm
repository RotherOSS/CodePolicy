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

package TidyAll::Plugin::OTOBO::Migrations::OTOBO5::OutputFilterPre;

use strict;
use warnings;

use File::Basename;
use parent qw(TidyAll::Plugin::OTOBO::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 5, 0 );
    return if !$Self->IsFrameworkVersionLessThan( 6, 0 );

    my @InvalidSettings;

    $Code =~ s{
        (<ConfigItem\s*Name="Frontend::Output::FilterElementPre.*?>)
    }{
        push @InvalidSettings, $1;
    }smxge;

    my $ErrorMessage;

    if (@InvalidSettings) {
        $ErrorMessage .= "Pre output filters are not supported in OTOBO 5+.\n";
        $ErrorMessage .= "Wrong settings found: " . join( ', ', @InvalidSettings ) . "\n";
    }

    if ($ErrorMessage) {
        return $Self->DieWithError("$ErrorMessage");
    }
}

1;
