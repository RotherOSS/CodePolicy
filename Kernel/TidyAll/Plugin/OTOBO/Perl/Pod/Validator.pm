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

package TidyAll::Plugin::OTOBO::Perl::Pod::Validator;
use strict;
use warnings;

use Capture::Tiny qw(capture_merged);
use Pod::Checker;

use parent 'Code::TidyAll::Plugin';
use parent 'TidyAll::Plugin::OTOBO::Perl';

#
# Validated Pod with Pod::Checker for syntactical correctness.
#

sub validate_file {
    my ( $Self, $File ) = @_;

    return if $Self->IsPluginDisabled( Filename => $File );
    return if $Self->IsFrameworkVersionLessThan( 6, 0 );

    my $Checker = Pod::Checker->new();

    # Force stringification of $File as it is a Path::Tiny object in Code::TidyAll 0.50+.
    my $Output = capture_merged { $Checker->parse_from_file( "$File", \*STDERR ) };

    # Only die if Output is filled with errors. Otherwise it could be
    #   that there just was no POD in the file.
    if ( $Checker->num_errors() && $Output ) {
        return $Self->DieWithError("$Output");
    }
}

1;
