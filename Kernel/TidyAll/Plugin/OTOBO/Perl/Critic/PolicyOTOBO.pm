# --
# OTOBO is a web-based ticketing system for service organisations.
# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# Copyright (C) 2019-2024 Rother OSS GmbH, https://otobo.de/
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

package Perl::Critic::PolicyOTOBO;

#
# Base class for custome Perl::Critic policies.
#

use strict;
use warnings;
use v5.24;
use utf8;

# Base class for OTOBO perl critic policies

sub IsFrameworkVersionLessThan {
    my ( $Self, $FrameworkVersionMajor, $FrameworkVersionMinor ) = @_;

    if ($TidyAll::OTOBO::FrameworkVersionMajor) {
        return 1 if $TidyAll::OTOBO::FrameworkVersionMajor < $FrameworkVersionMajor;
        return 0 if $TidyAll::OTOBO::FrameworkVersionMajor > $FrameworkVersionMajor;
        return 1 if $TidyAll::OTOBO::FrameworkVersionMinor < $FrameworkVersionMinor;
        return 0;
    }

    # Default: if framework is unknown, return false (strict checks).
    return 0;
}

1;
