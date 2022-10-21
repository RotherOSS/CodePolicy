# --
# OTOBO is a web-based ticketing system for service organisations.
# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# Copyright (C) 2019-2022 Rother OSS GmbH, https://otobo.de/
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

package TidyAll::Plugin::OTOBO::Perl::Pod::SpellCheck;

use strict;
use warnings;

# Implementation is based on https://metacpan.org/source/DROLSKY/Code-TidyAll-0.56/lib/Code/TidyAll/Plugin/PodSpell.pm

use Capture::Tiny qw();
use File::Temp();
use Pod::Spell;

use Moo;

extends 'TidyAll::Plugin::OTOBO::Perl';

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

        $HunspellDictionaryPath = __FILE__ =~ s{SpellCheck\.pm$}{../../StaticFiles/Hunspell/Dictionaries}r;
        $HunspellWhitelistPath  = __FILE__ =~ s{\.pm$}{.Whitelist.txt}r;
    }

    # # TODO: MOVE TO SEPARATE Perl::CommentsSpellCheck plugin later
    # my $Code = $Self->_GetFileContents($File);
    #
    # my $Comments = $Self->StripPod( Code => $Code );
    # $Comments    =~ s{^ \# \s stripped \s POD}{}smxg;
    # $Comments    =~ s{^ \s* [^#\s] .*? $}{}smxg;  # Remove non-comment lines
    # $Comments    =~ s{\n\n+}{\n}smxg;             # Remove empty blocks
    # $Comments    =~ s{^ \s* [#] \s* }{}smxg;      # Remove comment signs

    my ( $PodText, $Error ) = Capture::Tiny::capture( sub { Pod::Spell->new()->parse_from_file( $File->stringify() ) } );

    die $Error if $Error;

    my $TempFile = File::Temp->new();
    print $TempFile $PodText;
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
        return $Self->DieWithError(
            sprintf( "\nPerl Pod contains unrecognized words:\n%s\n", join( "\n", sort @Errors ) )
        );
    }

    return;
}

1;
