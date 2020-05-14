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

package TidyAll::Plugin::OTOBO::Perl::WebApp::HeadGetWithoutBody;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTOBO::Perl);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan( 7, 0 );

    if ( $Code =~ m/^sub\s+RequestMethods[^}]+(get|head)[^}]+\}/xms && $Code =~ m{^sub\s+ValidationJSONBodyFields}xms )
    {
        return $Self->DieWithError(<<"EOF");
Endpoints using the HEAD or GET request methods may not use a body payload. Use query params instead.
EOF
    }

    return;
}

1;
