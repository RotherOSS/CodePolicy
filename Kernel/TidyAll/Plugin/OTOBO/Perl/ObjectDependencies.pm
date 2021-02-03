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

package TidyAll::Plugin::OTOBO::Perl::ObjectDependencies;

use strict;
use warnings;

#
# This plugin scans perl packages and compares the objects they request
#   from the ObjectManager with the dependencies they declare and complains
#   about any missing dependencies.
#

use parent qw(TidyAll::Plugin::OTOBO::Perl);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    $Code = $Self->StripPod( Code => $Code );
    $Code = $Self->StripComments( Code => $Code );

    # Skip if the code doesn't use the ObjectManager
    return if $Code !~ m{\$Kernel::OM}smx;

    # Skip if we have a role, as it cannot be instantiated.
    return if $Code =~ m{use\s+Moose::Role}smx;

    # Skip if we have a webapp controller, as these are not managed via OM.
    return if $Code =~ m{package\s+Kernel::WebApp::(Controller|Plugin|Server)::}smx;

    # Skip if the package cannot be loaded via ObjectManager
    return if $Code =~ m{
        ^ \s* our \s* \$ObjectManagerDisabled \s* = \s* 1
    }smx;

    my $ErrorMessage;

    if ( $Code =~ m{^ \s* our \s* \$ObjectManagerAware}smx ) {
        $ErrorMessage .= "Don't use the deprecated flag \$ObjectManagerAware. It can be removed.\n";
    }

    #
    # Ok, first check for the objects that are requested from OM.
    #
    my @UsedObjects;

    # Only math what is absolutely needed to avoid false positives.
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

    #
    # Now check the declared dependencies and compare.
    #
    my @DeclaredObjectDependencies;
    $Code =~ s{
        ^our\s+\@ObjectDependencies\s+=\s+\(($ValidListExpression)\);
    }{
        @DeclaredObjectDependencies = $Self->_CleanupObjectList(
            Code => $1,
        );
        '';
    }esmx;

    my %DeclaredObjectDependencyLookup;
    @DeclaredObjectDependencyLookup{@DeclaredObjectDependencies} = undef;

    my @UndeclaredObjectDependencies;
    my %Seen;
    USED_OBJECT:
    for my $UsedObject (@UsedObjects) {
        next USED_OBJECT if $Seen{$UsedObject}++;
        if ( !exists $DeclaredObjectDependencyLookup{$UsedObject} ) {
            push @UndeclaredObjectDependencies, $UsedObject;
        }
    }

    if (@UndeclaredObjectDependencies) {
        $ErrorMessage
            .= "The following objects are used in the code, but not declared as dependencies:\n";
        $ErrorMessage
            .= join( ",\n", map {"    '$_'"} sort { $a cmp $b } @UndeclaredObjectDependencies )
            . ",\n";
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
        next OBJECT if !$Object;
        push @Result, $Object;
    }

    return @Result;
}

1;
