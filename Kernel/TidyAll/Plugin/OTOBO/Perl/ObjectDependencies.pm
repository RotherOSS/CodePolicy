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

package TidyAll::Plugin::OTOBO::Perl::ObjectDependencies;

use strict;
use warnings;
use v5.24;
use utf8;

#
# This plugin scans perl packages and compares the objects they request
# from the ObjectManager with the dependencies they declare and complains
# about any missing dependencies.
# Dependencies are declared with @ObjectDependencies and @SoftObjectDependencies.
#

# core modules
use List::Util qw(uniq);

# CPAN modules
use Moo;

# OTOBO modules

extends qw(TidyAll::Plugin::OTOBO::Perl);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    $Code = $Self->StripPod( Code => $Code );
    $Code = $Self->StripComments( Code => $Code );

    # Skip if the code doesn't use the ObjectManager
    return unless $Code =~ m{\$Kernel::OM}smx;

    # Skip if we have a role, as it cannot be instantiated.
    return if $Code =~ m{use\s+Moose::Role}smx;

    # Skip if the package cannot be loaded via ObjectManager
    return if $Code =~ m{
        ^ \s* our \s* \$ObjectManagerDisabled \s* = \s* 1
    }smx;

    my $ErrorMessage = '';

    if ( $Code =~ m{^ \s* our \s* \$ObjectManagerAware}smx ) {
        $ErrorMessage .= "Don't use the deprecated flag \$ObjectManagerAware. It can be removed.\n";
    }

    # Ok, first check for the objects that are requested from OM.
    my @UsedObjects;

    # Only match what is absolutely needed to avoid false positives.
    my $ValidListExpression = "[\@a-zA-Z0-9_[:space:]:'\",()]+?";

    # Real Get() calls.
    $Code =~ s{
        \$Kernel::OM->Get\( \s* ([^\$]$ValidListExpression) \s* \)
    }{
        push @UsedObjects, $Self->_CleanupObjectList(
            Code => $1,
        );
        '';
    }esmxg;

    # For loops with Get().
    $Code =~ s{
        for \s+ (?: my \s+ \$[a-zA-z0-9_]+ \s+)? \(($ValidListExpression)\)\s*\{\n
            \s+ \$Self->\{\$.*?\} \s* (?://|\|\|)?= \s* \$Kernel::OM->Get\(\s*\$[a-zA-Z0-9_]+?\s*\); \s+
        \}
    }{
        push @UsedObjects, $Self->_CleanupObjectList(
            Code => $1,
        );
        '';
    }esmxg;

    # Now check the declared dependencies and compare.
    # Dependencies can be declared in the array ObjectDependencies and SoftObjectDependencies.
    # The substitution is done for the side effects.
    my %ObjectIsDeclared;
    my $ObjectDeclarationWithQuotedWords;
    {
        my @DeclaredObjectDependencies;
        for my $Array (qw(ObjectDependencies SoftObjectDependencies)) {
            $Code =~ s{
                ^our\s+\@\Q$Array\E\s+=\s+(qw)?\(($ValidListExpression)\);
            }{
                push @DeclaredObjectDependencies, $Self->_CleanupObjectList(
                    Code => $2,
                );
                $ObjectDeclarationWithQuotedWords = $1 ? 1 : 0;
                '';
            }esmx;
        }

        %ObjectIsDeclared = map { $_ => 1 } @DeclaredObjectDependencies;
    }

    # report undeclared object dependencies
    my @UndeclaredObjectDependencies = sort grep { !$ObjectIsDeclared{$_} } uniq @UsedObjects;
    if (@UndeclaredObjectDependencies) {

        # The formating of the messing depends on whether qw() was used
        my $Separator = $ObjectDeclarationWithQuotedWords ? qq{\n} : qq{,\n};
        my $Delimiter = $ObjectDeclarationWithQuotedWords ? q{}    : q{'};
        my $List      = join $Separator,
            map  {"    $Delimiter$_$Delimiter"}
            sort { $a cmp $b }
            @UndeclaredObjectDependencies;
        $ErrorMessage .=
            "The following objects are used in the code, but not declared as dependencies:\n"
            . $List
            . $Separator
            . 'Please add the missing dependencies to the array @ObjectDependencies.';
    }

    if ($ErrorMessage) {
        return $Self->DieWithError(<<"EOF");
$ErrorMessage
EOF
    }

    return;
}

# Small helper function to cleanup object lists in Perl code for OM.
sub _CleanupObjectList {
    my ( $Self, %Param ) = @_;

    my @Result;

    OBJECT:
    for my $Object ( split( m{\s+}, $Param{Code} ) ) {
        $Object =~ s/qw\(//;        # remove qw() marker start
        $Object =~ s/^[("']+//;     # remove leading quotes and parentheses
        $Object =~ s/[)"',]+$//;    # remove trailing comma, quotes and parentheses

        next OBJECT unless $Object;

        push @Result, $Object;
    }

    return @Result;
}

1;
