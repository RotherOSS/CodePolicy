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

package TidyAll::Plugin::OTOBO::Common::NoFilter;
## nofilter(TidyAll::Plugin::OTOBO::Perl::Pod::SpellCheck)

use strict;
use warnings;

use File::Basename;

use Moo;

extends qw(TidyAll::Plugin::OTOBO::Base);

=head1 SYNOPSIS

This plugin fixes nofilter lines.

=cut

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # Replace nofilter lines in pm like files.
    #
    # Original:
    #     # nofilter(TidyAll::Plugin::OTOBO::Legal::LicenseValidator)
    #     # nofilter (TidyAll::Plugin::OTOBO::Legal::LicenseValidator)
    #     ## nofilter (TidyAll::Plugin::OTOBO::Legal::LicenseValidator)
    #     ## nofilter(TidyAll::Plugin::OTOBO::Legal::LicenseValidator);
    #     my $Dump = Data::Dumper::Dumper($HashRef);    #nofilter(TidyAll::Plugin::OTOBO::Perl::Dumper)
    #
    # Replacement:
    #     ## nofilter (TidyAll::Plugin::OTOBO::Legal::LicenseValidator)
    #     my $Dump = Data::Dumper::Dumper($HashRef);    ## nofilter(TidyAll::Plugin::OTOBO::Perl::Dumper)
    #
    $Code =~ s{ ^ ( [^\#\n]* ) \#+ \s* no \s* filter \s* \( ( .+? ) \) .*? \n }{$1## nofilter($2)\n}xmsg;

    # Replace nofilter lines in js like files.
    #
    # Original:
    #     // nofilter(TidyAll::Plugin::OTOBO::Legal::LicenseValidator)
    #     // nofilter(TidyAll::Plugin::OTOBO::Legal::LicenseValidator)
    #     // nofilter(TidyAll::Plugin::OTOBO::JavaScript::FileName)
    #     // nofilter(TidyAll::Plugin::OTOBO::Legal::LicenseValidator)
    #     my $Dump = Data::Dumper::Dumper($HashRef);    // nofilter(TidyAll::Plugin::OTOBO::Perl::Dumper)
    #
    # Replacement:
    #     // nofilter(TidyAll::Plugin::OTOBO::Legal::LicenseValidator)
    #     my $Dump = Data::Dumper::Dumper($HashRef);    // nofilter(TidyAll::Plugin::OTOBO::Perl::Dumper)
    #
    $Code =~ s{ ^ ( [^\/\n]* ) \/+ \s* no \s* filter \s* \( ( .+? ) \) .*? \n }{$1// nofilter($2)\n}xmsg;

    # Replace nofilter lines in css like files.
    #
    # Original:
    #     /* nofilter(TidyAll::Plugin::OTOBO::Legal::LicenseValidator) */
    #     /**  no filter (TidyAll::Plugin::OTOBO::Legal::LicenseValidator) */
    #     /*  nofilter (TidyAll::Plugin::OTOBO::Legal::LicenseValidator); */
    #
    # Replacement:
    #     /* nofilter(TidyAll::Plugin::OTOBO::Legal::LicenseValidator) */
    #
    $Code
        =~ s{ ^ ( \s* ) \\ \*+ [^\n]* no \s* filter \s* \( ( .+? ) \) .*? \*+ \\ [^\n]* \n }{$1/* nofilter($2) */\n}xmsg;

    # Replace nofilter lines in xml like files.
    #
    # Original:
    #     <!-- nofilter(TidyAll::Plugin::OTOBO::Legal::LicenseValidator) -->
    #     <!--  no filter (TidyAll::Plugin::OTOBO::Legal::LicenseValidator) -->
    #     <!--  nofilter (TidyAll::Plugin::OTOBO::Legal::LicenseValidator); -->
    #
    # Replacement:
    #     <!-- nofilter(TidyAll::Plugin::OTOBO::Legal::LicenseValidator) -->
    #
    $Code
        =~ s{ ^ ( \s* ) <!-- [^\n]* no \s* filter \s* \( ( .+? ) \) .*? --> [^\n]* \n }{$1<!-- nofilter($2) -->\n}xmsg;

    return $Code;
}

sub validate_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    return $Code if $Code !~ m{ nofilter \( .+? \) }xms;

    if ( $Code =~ m{ <!-- \s* nofilter \s* \( }xms ) {

        if ( $Code !~ m{ <!-- \s nofilter \( .+? \) \s --> }xms ) {
            return $Self->DieWithError("Found invalid nofilter() XML line!");
        }
    }
    else {

        if ( $Code !~ m{ (?: \#\# | \/\/ | \/\* ) \s nofilter \( .+? \) }xms ) {
            return $Self->DieWithError("Found invalid nofilter() line!");
        }
    }

    return $Code;
}

1;
