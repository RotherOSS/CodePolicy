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

package TidyAll::Plugin::OTOBO::XML::Docbook::ImageOutput;

use strict;
use warnings;

use File::Basename;

use Moo;

extends qw(TidyAll::Plugin::OTOBO::Base);

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # Make sure images are correctly embedded, showing in original size and capped at
    #   available with. Forbid manual scaling.

    # See http://www.sagehill.net/docbookxsl/ImageSizing.html:
    # "To keep a graphic for printed output at its natural size unless it is too large to fit
    #   the available width, in which case shrink it to fit, use scalefit="1", width="100%",
    #   and contentdepth="100%" attributes."

    $Code
        =~ s{<graphic [^>]+ (fileref="[^">]+")[^>/]*(/?)>}{<graphic $1 scalefit="1" width="100%" contentdepth="100%"$2>}msxg;

    return $Code;
}

1;
