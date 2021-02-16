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

package TidyAll::Plugin::OTOBO::Common::TranslatableStringsSpellCheck;
use strict;
use warnings;

# Implementation is based on https://metacpan.org/source/DROLSKY/Code-TidyAll-0.56/lib/Code/TidyAll/Plugin/PodSpell.pm

use File::Temp();

use parent 'TidyAll::Plugin::OTOBO::Base';

our $HunspellPath;
our $HunspellDictionaryPath;
our $HunspellWhitelistPath;

sub validate_file {
    my ( $Self, $File ) = @_;

    return if $Self->IsPluginDisabled( Filename => $File );

    if ( !$HunspellPath ) {
        $HunspellPath = `which hunspell`;
        chomp $HunspellPath;
        if ( !$HunspellPath ) {
            print STDERR __PACKAGE__ . "\nCould not find 'hunspell', skipping spell checker tests.\n";
            return;
        }

        $HunspellDictionaryPath = __FILE__;
        $HunspellDictionaryPath =~ s{TranslatableStringsSpellCheck\.pm$}{../StaticFiles/Hunspell/Dictionaries};

        $HunspellWhitelistPath = __FILE__;
        $HunspellWhitelistPath =~ s{\.pm$}{.Whitelist.txt};
    }

    my $Text = $Self->_ExtractTranslatableStrings($File);

    return if !$Text;

    my $TempFile = File::Temp->new();
    print $TempFile $Text;
    $TempFile->close();

    my $CMD    = "$HunspellPath -d ${HunspellDictionaryPath}/en_US -p $HunspellWhitelistPath -a $TempFile";
    my $Output = `$CMD`;

    if ( ${^CHILD_ERROR_NATIVE} ) {
        return $Self->DieWithError("Error running '$CMD': $Output");
    }

    my ( @Errors, %Seen );
    LINE:
    for my $Line ( split( m/\n/, $Output ) ) {
        if ( my ( $Original, $Remaining ) = ( $Line =~ /^[\&\?\#] (\S+)\s+(.*)/ ) ) {

            if ( $Original =~ m{^ _? [A-Z]+ [a-z0-9]+ [A-Za-z0-9]* }smx ) {
                next LINE;
            }

            if ( !$Seen{$Original}++ ) {
                my ($Suggestions) = ( $Remaining =~ /: (.*)/ );
                if ($Suggestions) {
                    push( @Errors, sprintf( "%s (suggestions: %s)", $Original, $Suggestions ) );
                }
                else {
                    push( @Errors, $Original );
                }
            }
        }
    }

    if (@Errors) {
        my $Error = sprintf( "\nTranslatable strings contains unrecognized words:\n%s\n", join( "\n", sort @Errors ) );
        return $Self->DieWithError($Error);
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
            <Data[^>]+Translatable="1"[^>]*>(.*?)</Data>
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

    return $Result;
}

1;
