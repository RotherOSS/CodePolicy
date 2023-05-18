# --
# OTOBO is a web-based ticketing system for service organisations.
# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# Copyright (C) 2019-2023 Rother OSS GmbH, https://otobo.de/
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

package TidyAll::Plugin::OTOBO::Migrations::OTOBO10::SysConfig;

use strict;
use warnings;

use Moo;

extends qw(TidyAll::Plugin::OTOBO::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    # active only for OTOBO 10
    return unless $Self->IsFrameworkVersionLessThan( 11, 0 );

    my ( $Counter, $ErrorMessage );

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;

        next LINE if $Line =~ m/^\s*\#/smx;

        # Look for code that uses not not existing functions.
        if (
            $Line =~ m{
            ->(CreateConfig|ConfigItemUpdate|ConfigItemGet|ConfigItemReset
            |ConfigItemValidityUpdate|ConfigGroupList|ConfigSubGroupList
            |ConfigSubGroupConfigItemList|ConfigItemSearch|ConfigItemTranslatableStrings
            |ConfigItemValidate|ConfigItemCheckAll)\(}smx
            )
        {
            # Skip ITSM functions, which have same name.
            next LINE if $Line =~ m{ConfigItemObject};
            next LINE if $Line =~ m{ITSM};

            $ErrorMessage .= "Line $Counter: $Line\n";
        }
    }

    if ($ErrorMessage) {
        return $Self->DieWithError(<<"EOF");
Use of unexisting methods in Kernel::System::SysConfig is not allowed (CreateConfig, ConfigItemUpdate,
ConfigItemGet, ConfigItemReset, ConfigItemValidityUpdate,ConfigGroupList, ConfigSubGroupList,
ConfigSubGroupConfigItemList, ConfigItemSearch, ConfigItemTranslatableStrings, ConfigItemValidate
and ConfigItemCheckAll).

    Please see http://doc.otobo.com/doc/manual/developer/6.0/en/html/package-porting.html#package-porting-5-to-6 for porting guidelines.
$ErrorMessage
EOF
    }

    return;
}

1;
