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

package TidyAll::Plugin::OTOBO::PO::DocbookLint;

#
# Perform some quality checks on po files.
#

use strict;
use warnings;

use Moo;

extends qw(TidyAll::Plugin::OTOBO::Base);

use Locale::PO  ();
use XML::Parser ();

sub validate_file {
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( Filename => $Filename );

    my $IsDocbookTranslation = $Filename =~ m{/doc-}smx;
    my $Strings              = Locale::PO->load_file_asarray($Filename);

    my $ErrorMessage;

    STRING:
    for my $String ( @{ $Strings // [] } ) {

        next STRING if $String->fuzzy();

        my $Source = $String->dequote( $String->msgid() );
        next STRING if !$Source;
        my $Translation = $String->dequote( $String->msgstr() );
        next STRING if !$Translation;

        if ($IsDocbookTranslation) {

            # # Don't validate contents of <screen> tags, they should have CDATA
            #next STRING if $String->automatic() && $String->automatic =~ m{<screen>$}smx;
            next STRING if $String->automatic() && $String->automatic() =~ m{CDATA$}smx;

            # Obsolete strings might loose CDATA comments
            next STRING if $String->obsolete();

            my $Parser = XML::Parser->new();
            if ( !eval { $Parser->parse("<book>$Translation</book>") } ) {
                $ErrorMessage .= "Invalid XML translation found in Line: "
                    . $String->loaded_line_number() . "\n";
                $ErrorMessage .= "  Source: $Source\n";
                $ErrorMessage .= "  Translation: $Translation\n";
                $ErrorMessage .= "  XML::Parser produced errors: $@\n";
                next STRING;
            }

            my $StrippedSource = $Source;
            $StrippedSource =~ s{<!--.*-->}{}smxg;

            my @SourceTags = $StrippedSource =~ m{<[^>]*>}smg;
            next STRING if !@SourceTags;
            my %SourceTagCount;
            @SourceTags = map { $_ =~ s{^<([/a-zA-Z_0-9]+).*}{$1}esmxg; $_ } @SourceTags;    ## no critic qw(ControlStructures::ProhibitMutatingListFunctions)

            # Some tags which do not have to be validated as long as the xml structure is still valid.
            my %IgnoreTags = (
                'emphasis'   => 1,
                '/emphasis'  => 1,
                'citetitle'  => 1,
                '/citetitle' => 1,
                'ulink'      => 1,
                '/ulink'     => 1,
                'link'       => 1,
                '/link'      => 1,
                'filename'   => 1,
                '/filename'  => 1,
            );

            SOURCE_TAG:
            for my $SourceTag (@SourceTags) {
                next SOURCE_TAG if $IgnoreTags{$SourceTag};
                $SourceTagCount{$SourceTag}++;

            }

            for my $SourceTag ( sort keys %SourceTagCount ) {
                my @TranslatedTags     = $Translation =~ m{<$SourceTag[>| ]}smg;
                my $TranslatedTagCount = scalar @TranslatedTags;
                if ( $TranslatedTagCount != $SourceTagCount{$SourceTag} ) {
                    $ErrorMessage .= "Invalid XML translation found in Line: "
                        . $String->loaded_line_number() . "\n";
                    $ErrorMessage .= "  Source: $Source\n";
                    $ErrorMessage .= "  Translation: $Translation\n";
                    $ErrorMessage
                        .= "  Tag <$SourceTag> was expected $SourceTagCount{$SourceTag} but found $TranslatedTagCount times.\n";
                }
            }

            # Source and translation should have the same linkend definitions.
            my @SourceLinkEnds = $Source      =~ m{<link[^>]+linkend=["']([^'"]+)['"]}smxg;
            my @TargetLinkEnds = $Translation =~ m{<link[^>]+linkend=["']([^'"]+)['"]}smxg;

            my $LinkEndsAreDifferent = $Self->_DataDiff(
                Data1 => [ sort { $a cmp $b } @SourceLinkEnds ],
                Data2 => [ sort { $a cmp $b } @TargetLinkEnds ],
            );

            if ($LinkEndsAreDifferent) {
                $ErrorMessage .= "Linkend definitions are different.\nSource:\n$Source\nTranslation:\n$Translation\n\n";
            }
        }
    }

    if ($ErrorMessage) {
        return $Self->DieWithError("$ErrorMessage");
    }
}

sub _DataDiff {
    my ( $Self, %Param ) = @_;

    for (qw(Data1 Data2)) {
        if ( !defined $Param{$_} ) {
            print STDERR "Need $_!\n";
            return;
        }
    }

    # ''
    if ( ref $Param{Data1} eq '' && ref $Param{Data2} eq '' ) {

        # do nothing, it's ok
        return if !defined $Param{Data1} && !defined $Param{Data2};

        # return diff, because its different
        return 1 if !defined $Param{Data1} || !defined $Param{Data2};

        # return diff, because its different
        return 1 if $Param{Data1} ne $Param{Data2};

        # return, because its not different
        return;
    }

    # SCALAR
    if ( ref $Param{Data1} eq 'SCALAR' && ref $Param{Data2} eq 'SCALAR' ) {

        # do nothing, it's ok
        return if !defined ${ $Param{Data1} } && !defined ${ $Param{Data2} };

        # return diff, because its different
        return 1 if !defined ${ $Param{Data1} } || !defined ${ $Param{Data2} };

        # return diff, because its different
        return 1 if ${ $Param{Data1} } ne ${ $Param{Data2} };

        # return, because its not different
        return;
    }

    # ARRAY
    if ( ref $Param{Data1} eq 'ARRAY' && ref $Param{Data2} eq 'ARRAY' ) {
        my @A = @{ $Param{Data1} };
        my @B = @{ $Param{Data2} };

        # check if the count is different
        return 1 if $#A ne $#B;

        # compare array
        COUNT:
        for my $Count ( 0 .. $#A ) {

            # do nothing, it's ok
            next COUNT if !defined $A[$Count] && !defined $B[$Count];

            # return diff, because its different
            return 1 if !defined $A[$Count] || !defined $B[$Count];

            if ( $A[$Count] ne $B[$Count] ) {
                if ( ref $A[$Count] eq 'ARRAY' || ref $A[$Count] eq 'HASH' ) {
                    return 1 if $Self->_DataDiff(
                        Data1 => $A[$Count],
                        Data2 => $B[$Count]
                    );
                    next COUNT;
                }
                return 1;
            }
        }
        return;
    }

    # HASH
    if ( ref $Param{Data1} eq 'HASH' && ref $Param{Data2} eq 'HASH' ) {
        my %A = %{ $Param{Data1} };
        my %B = %{ $Param{Data2} };

        # compare %A with %B and remove it if checked
        KEY:
        for my $Key ( sort keys %A ) {

            # Check if both are undefined
            if ( !defined $A{$Key} && !defined $B{$Key} ) {
                delete $A{$Key};
                delete $B{$Key};
                next KEY;
            }

            # return diff, because its different
            return 1 if !defined $A{$Key} || !defined $B{$Key};

            if ( $A{$Key} eq $B{$Key} ) {
                delete $A{$Key};
                delete $B{$Key};
                next KEY;
            }

            # return if values are different
            if ( ref $A{$Key} eq 'ARRAY' || ref $A{$Key} eq 'HASH' ) {
                return 1 if $Self->_DataDiff(
                    Data1 => $A{$Key},
                    Data2 => $B{$Key}
                );
                delete $A{$Key};
                delete $B{$Key};
                next KEY;
            }
            return 1;
        }

        # check rest
        return 1 if %B;
        return;
    }

    if ( ref $Param{Data1} eq 'REF' && ref $Param{Data2} eq 'REF' ) {
        return 1 if $Self->_DataDiff(
            Data1 => ${ $Param{Data1} },
            Data2 => ${ $Param{Data2} }
        );
        return;
    }

    return 1;
}

1;
