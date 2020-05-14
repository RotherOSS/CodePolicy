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

package TidyAll::Plugin::OTOBO::Migrations::OTOBO7::TranslatableStringsPlaceholders;

use strict;
use warnings;

use parent 'TidyAll::Plugin::OTOBO::Base';

sub validate_file {
    my ( $Self, $File ) = @_;

    return if $Self->IsPluginDisabled( Filename => $File );
    return if $Self->IsFrameworkVersionLessThan( 7, 0 );
    return if !$Self->IsFrameworkVersionLessThan( 8, 0 );

    my $Text = $Self->_ExtractTranslatableStrings($File);
    return if !$Text;

    my $ErrorMessage;

    # Prohibit %d as a placeholder.
    while ( $Text =~ /^ (?<Line> [^\n]* % \bd\b [^\n]* ) $/gismx ) {
        $ErrorMessage .= $+{Line} . "\n";
    }

    if ($ErrorMessage) {
        return $Self->DieWithError(<<"EOF");
Translatable strings contain prohibited placeholders (\%d):\n
$ErrorMessage
EOF
    }

    return;
}

sub _ExtractTranslatableStrings {
    my ( $Self, $Filename ) = @_;

    my $Code = $Self->_GetFileContents($Filename);

    my $Result;

    if ( $Filename =~ m{.tt$}ismx ) {
        $Code =~ s{
            Translate\(
                \s*
                (["'])(.*?)(?<!\\)\1
        }
        {
            my $Word = $2 // '';

            # unescape any \" or \' signs
            $Word =~ s{\\"}{"}smxg;
            $Word =~ s{\\'}{'}smxg;

            $Result .= "$Word\n";

            '';
        }egx;
    }
    elsif ( $Filename =~ m{\.(pm|pl)}ismx ) {
        $Code =~ s{
            (?:
                ->Translate | Translatable
            )
            \(
                \s*
                (["'])(.*?)(?<!\\)\1
        }
        {
            my $Word = $2 // '';

            # unescape any \" or \' signs
            $Word =~ s{\\"}{"}smxg;
            $Word =~ s{\\'}{'}smxg;

            # Ignore strings containing variables
            my $SkipWord;
            $SkipWord = 1 if $Word =~ m{\$}xms;

            if ($Word && !$SkipWord ) {
                $Result .= "$Word\n";
            }
            '';
        }egx;
    }
    elsif ( $Filename =~ m{\.xml$}ismx ) {
        $Code =~ s{
            [^>]+Translatable="1"[^>]*>(.*?)</
        }
        {
            my $Word = $1 // '';
            if ($Word) {
                $Result .= "$Word\n";
            }
            '';
        }egx;
    }
    elsif ( $Filename =~ m{\.js$}ismx ) {
        $Code =~ s{
            (?:
                Core.Language.Translate
            )
            \(
                \s*
                (["'])(.*?)(?<!\\)\1
        }
        {
            my $Word = $2 // '';

            # unescape any \" or \' signs
            $Word =~ s{\\"}{"}smxg;
            $Word =~ s{\\'}{'}smxg;

            if ( $Word ) {
                $Result .= "$Word\n";
            }

            '';
        }egx;
    }
    elsif ( $Filename =~ m{\.html\.tmpl$}ismx ) {
        $Code =~ s{
            \{\{
            \s*
            (["'])(.*?)(?<!\\)\1
            \s*
            \|
            \s*
            Translate
        }
        {
            my $Word = $2 // '';

            # Unescape any \" or \' signs.
            $Word =~ s{\\"}{"}smxg;
            $Word =~ s{\\'}{'}smxg;

            if ( $Word ) {
                $Result .= "$Word\n";
            }

            '';
        }egx;
    }

    return $Result;
}

1;
