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

package TidyAll::Plugin::OTOBO::XML::Database::KeyLength;

use strict;
use warnings;

use Moo;

extends qw(TidyAll::Plugin::OTOBO::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    my $Counter;

    # Account for 3-byte UTF8 characters. We currently use the "utf8" charset in MySQL,
    #   which uses three bytes per character. In future we might want to switch to utf8mb4,
    #   which would even further reduce possible key length by using 4 bytes per character.
    my $CharacterSize = 3;

    # Keys with size of more than 1000 bytes will fail on MyISAM storage engine in MySQL.
    my $KeySizeLimit = 1000;

    my $CurrentTableName;
    my %CurrentColumns;
    my $CurrentKey;
    my $CurrentKeySize = 0;
    my $ErrorMessage;

    my %ColumnType2Size = (
        'TINYINT'   => 1,
        'SMALLINT'  => 2,
        'MEDIUMINT' => 3,
        'INT'       => 8,
        'INTEGER'   => 8,
        'BIGINT'    => 8,
        'DATE'      => 8,
        'LONGBLOB'  => 4294967295,
    );

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;

        # Match table create opening tag and reset any found columns.
        if ( $Line =~ m{ <Table(?:Create)? .*? Name="(?<TableName>.*?)" }smx ) {
            $CurrentTableName = $+{TableName};
            %CurrentColumns   = ();
            next LINE;
        }

        # Identify all columns with defined size.
        if ( $Line =~ m{ <Column .*? Name="(?<ColumnName>\w+)" }smx ) {
            my $ColumnName = $+{ColumnName};

            if ( $Line =~ m{ Type="(?<ColumnType>\w+)" }smx ) {
                my $ColumnType = $+{ColumnType};

                # Use internal sizes for some predefined column types.
                if ( $ColumnType2Size{ uc $ColumnType } ) {
                    $CurrentColumns{$ColumnName} = $ColumnType2Size{ uc $ColumnType };
                }

                # Check if there is a defined size tag.
                if ( $Line =~ m{ Size="(?<ColumnSize>[\d,]+)" }smx ) {
                    my $ColumnSize = $+{ColumnSize};

                    # For text columns multiply found size with defined number of bytes per character.
                    if ( uc $ColumnType eq 'VARCHAR' ) {
                        $CurrentColumns{$ColumnName} = $ColumnSize * $CharacterSize;
                    }

                    # For decimal column type use approximate calculation, it should be enough for our purposes.
                    #   More info here: https://dev.mysql.com/doc/refman/5.7/en/precision-math-decimal-characteristics.html
                    elsif ( uc $ColumnType eq 'DECIMAL' ) {
                        my ( $TotalDigits, $FractionalDigits ) = split m/,/, $ColumnSize;
                        $FractionalDigits //= 0;
                        my $IntegerDigits = $TotalDigits - $FractionalDigits;
                        for my $Digits ( $IntegerDigits, $FractionalDigits ) {
                            $CurrentColumns{$ColumnName} += sprintf( '%0.f', $Digits / 9 * 4 );
                        }
                    }

                    # For any use case that has not been covered until this point, just use defined size.
                    elsif ( !$ColumnType2Size{ uc $ColumnType } ) {
                        $CurrentColumns{$ColumnName} += $ColumnSize;
                    }
                }
            }
        }

        # Match key opening tag and remember its name.
        if ( $Line =~ m{ <(?:Unique|Index) \s+ Name="(?<KeyName>\w+)" }smx ) {
            $CurrentKey = $+{KeyName};
            next LINE;
        }

        # Match key closing tag and reset any found keys.
        if ( $Line =~ m{ </(?:Unique|Index)> }smx ) {
            $CurrentKey     = undef;
            $CurrentKeySize = 0;
            next LINE;
        }

        # Proceed only if we are within key definition.
        if ($CurrentKey) {

            # Match key column tag.
            if ( $Line =~ m{ <(?:Unique|Index)Column .*? Name="(?<ColumnName>\w+)" }smx ) {
                my $ColumnName = $+{ColumnName};

                # Skip undefined columns. Should not happen, if the definition is valid.
                next LINE if !$CurrentColumns{$ColumnName};

                # If key size is defined, use it.
                if ( $Line =~ m{ Size="(?<KeySize>\d+)" }smx ) {
                    $CurrentKeySize += $+{KeySize};
                }

                # Otherwise, use size from column definition.
                else {
                    $CurrentKeySize += $CurrentColumns{$ColumnName};
                }
            }

            # Check if current size of the key exceeds configured limit.
            if ($CurrentKeySize) {
                next LINE if $CurrentKeySize <= $KeySizeLimit;

                $ErrorMessage .= "Table: $CurrentTableName, Key: $CurrentKey\n";

                # Skip processing current key.
                $CurrentKey     = undef;
                $CurrentKeySize = 0;
            }
        }
    }

    if ($ErrorMessage) {
        return $Self->DieWithError(<<"EOF");
Problem found in XML database schema: keys with more than 1000 bytes will fail on MyISAM storage engine in MySQL!
$ErrorMessage
EOF
    }

    return;
}

1;
