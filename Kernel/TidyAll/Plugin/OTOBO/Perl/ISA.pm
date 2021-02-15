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

package TidyAll::Plugin::OTOBO::Perl::ISA;
## nofilter(TidyAll::Plugin::OTOBO::Perl::ISA)

use strict;
use warnings;

use File::Basename;

use parent qw(TidyAll::Plugin::OTOBO::Perl);

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan( 3, 3 );

    # remove useless use vars qw(@ISA); (where ISA is not used)
    if ( $Code !~ m{\@ISA.*\@ISA}smx ) {
        $Code =~ s{^use \s+ vars \s+ qw\(\@ISA\);\n+}{}smx;
    }

    return $Code;
}

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 3, 3 );

    # Don't allow push @ISA.
    if ( $Code =~ m{push\(?\s*\@ISA }xms ) {
        return $Self->DieWithError(<<"EOF");
Don't push to \@ISA, this can cause problems in persistent environments.
Use Main::RequireBaseClass() instead.
EOF
    }

    return;
}

1;
