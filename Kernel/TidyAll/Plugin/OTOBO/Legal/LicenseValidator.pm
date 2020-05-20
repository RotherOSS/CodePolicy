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

package TidyAll::Plugin::OTOBO::Legal::LicenseValidator;
## nofilter(TidyAll::Plugin::OTOBO::Common::CustomizationMarkers)
## nofilter(TidyAll::Plugin::OTOBO::Legal::LicenseValidator)

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTOBO::Base);

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # insert license header transformations

    return $Code;
}

sub validate_file {
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( Filename => $Filename );

    my $Code = $Self->_GetFileContents($Filename);

    my ($Filetype) = $Filename =~ m{ .* \. ( .+ ) }xmsi;
    $Filetype ||= '';

    if ( $Filetype eq 'skel' ) {
        ($Filetype) = $Filename =~ m{ .* \. ( .+ ) \.skel }xmsi;
    }

    # Check a javascript license header.
    if ( lc $Filetype eq 'js' ) {

        my $Description = _DescJS();
        my $GPLJavaScript = _GPLJavaScript();

        if ( $Code !~ m{\Q$GPLJavaScript\E} ) {
            return $Self->DieWithError("Found no valid javascript license header!");
        }
        if ( $Code !~ m{\Q$Description\E} ) {
            return $Self->DieWithError("Found no valid description in javascript license header!");
        }
    }

    # Check a perl script license header.
    elsif ( lc $Filetype eq 'pl' || lc $Filetype eq 'psgi' || lc $Filetype eq 'sh' || lc $Filetype eq 't' ) {

        my $Description = _DescPerl();
        my $GPLPerlScript = _GPLPerlScript();

        if ( $Code !~ m{\Q$GPLPerlScript\E} ) {
            return $Self->DieWithError("Found no valid perl script license header!");
        }
        if ( $Code !~ m{\Q$Description\E} ) {
            return $Self->DieWithError("Found no valid description in perl license header!");
        }
    }

    # Check css license header.
    elsif ( lc $Filetype eq 'css' || lc $Filetype eq 'scss' ) {

        my $Description = _DescCss();
        my $GPLCss = _GPLCss();

        if ( $Code !~ m{\Q$GPLCss\E} ) {
            return $Self->DieWithError("Found no valid css license header!");
        }
        if ( $Code !~ m{\Q$Description\E} ) {
            return $Self->DieWithError("Found no valid description in css license header!");
        }
    }

    # Check vue license header.
    elsif ( lc $Filetype eq 'vue' ) {

        my $GPLVue = _GPLVue();

        if ( $Code !~ m{\Q$GPLVue\E} ) {
            return $Self->DieWithError("Found no valid vue license header!");
        }
    }

    # Check xml license tag.
    elsif ( lc $Filetype eq 'xml' ) {

        # Do not validate XML files, because there a so many different content (config XML, documentation XML, ...)
    }

    # Check opm and sopm license tag.
    elsif ( lc $Filetype eq 'sopm' || lc $Filetype eq 'opm' ) {

        my $GPLOPM = _GPLOPM();

        if ( $Code !~ m{\Q$GPLOPM\E} ) {
            return $Self->DieWithError("Found no valid OPM license header!");
        }
    }

    # Check generic license header.
    else {

        my $GPLGeneric = _GPLGeneric();

        if ( $Code !~ m{\Q$GPLGeneric\E} ) {
            return $Self->DieWithError("Found no valid license header!");
        }
    }

    # Check perldoc license header.
    if ( lc $Filetype eq 'pl' || lc $Filetype eq 'pm' ) {

        if ( $Code =~ m{ =head1 \s+ TERMS \s+ AND \s+ CONDITIONS \n+ This \s+ software \s+ is \s+ part }smx ) {

            my $GPLPerldoc = _GPLPerldoc();

            if ( $Code !~ m{\Q$GPLPerldoc\E} ) {
                return $Self->DieWithError("Found no valid perldoc license header!");
            }
        }
    }

}

sub _GPLPerlScript {
    return <<'END_GPLPERLSCRIPT';
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
END_GPLPERLSCRIPT
}

sub _GPLJavaScript {
    return <<'END_GPLJAVASCRIPT';
// --
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.
// --
END_GPLJAVASCRIPT
}

sub _GPLCss {
    return <<'END_GPLCSS';

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later version.
This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.
*/
END_GPLCSS
}

sub _GPLVue {
    return <<'END_GPLVUE';

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later version.
This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.
-->
END_GPLVUE
}

sub _GPLOPM {
    return '<License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>';
}

sub _GPLGeneric {
    return <<'END_GPLGENERIC';
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
END_GPLGENERIC
}

sub _GPLPerldoc {
    return <<'END_GPLPERLDOC';
=head1 TERMS AND CONDITIONS

This software is part of the OTOBO project (L<https://otobo.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (GPL). If you
did not receive this file, see L<https://www.gnu.org/licenses/gpl-3.0.txt>.
END_GPLPERLDOC
}


sub _DescPerl {
    return <<'END_DESCPERLSCRIPT';
# --
# OTOBO is a web-based ticketing system for service organisations.
# --
END_DESCPERLSCRIPT
}

sub _DescJS {
    return <<'END_DESCJS';
// --
// OTOBO is a web-based ticketing system for service organisations.
// --
END_DESCJS
}

sub _DescCss {
    return <<'END_DESCCSS';
/* OTOBO is a web-based ticketing system for service organisations.

END_DESCCSS
}

1;
