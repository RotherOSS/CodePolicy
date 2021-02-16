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

package TidyAll::Plugin::OTOBO::PO::HTMLTags;

#
# Filter forbidden HTML tags in Framework/Package translation files.
#

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTOBO::Base);

use Locale::PO ();

sub validate_file {
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( Filename => $Filename );

    my $IsDocbookTranslation = $Filename =~ m{/doc-}smx;
    return if $IsDocbookTranslation;

    my @ForbiddenTags = (

        # Dangerous tags that could be used without attributes.
        qr(^<script)ixms,
        qr(^<style)ixms,
        qr(^<applet)ixms,
        qr(^<object)ixms,
        qr(^<svg)ixms,
        qr(^<embed)ixms,
        qr(^<meta)ixms,
        qr(^<img)ixms,
        qr(^<video)ixms,

        # Any HTML tag with additional attributes.
        qr(^<[^> ]+[ ]+[^>]+=)ixms,
    );

    my $Strings = Locale::PO->load_file_asarray($Filename);

    my $ErrorMessage;

    STRING:
    for my $String ( @{ $Strings // [] } ) {
        next STRING if $String->fuzzy();

        my $Source = $String->dequote( $String->msgid() ) // '';
        next STRING if !$Source;

        my $Translation = $String->dequote( $String->msgstr() ) // '';

        my @InvalidTags;

        for my $Part ( $Source, $Translation ) {
            my @Tags = $Part =~ m{<[^>]*>}smg;

            TAG:
            for my $Tag (@Tags) {
                for my $ForbiddenTag (@ForbiddenTags) {
                    push @InvalidTags, $Tag if $Tag =~ $ForbiddenTag;
                }
            }
        }

        next STRING if !@InvalidTags;

        $ErrorMessage .= "Invalid HTML tags found in line: " . $String->loaded_line_number() . "\n";
        $ErrorMessage .= "  Source: $Source\n";
        $ErrorMessage .= "  Translation: $Translation\n";
        $ErrorMessage .= "  Invalid tags: @InvalidTags";
    }

    if ($ErrorMessage) {
        return $Self->DieWithError("$ErrorMessage");
    }
}

1;
