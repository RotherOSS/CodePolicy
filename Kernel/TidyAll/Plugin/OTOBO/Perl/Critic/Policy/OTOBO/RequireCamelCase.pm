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

package Perl::Critic::Policy::OTOBO::RequireCamelCase;

use strict;
use warnings;

use Perl::Critic::Utils qw{};
use parent 'Perl::Critic::Policy';
use parent 'Perl::Critic::PolicyOTOBO';

our $VERSION = '0.01';

my $Description = q{Variable, subroutine, and package names have to be in CamelCase};
my $Explanation = q{};

sub supported_parameters { return; }
sub default_severity     { return $Perl::Critic::Utils::SEVERITY_HIGHEST; }
sub default_themes       { return qw( otobo ) }

my %Dispatcher = (
    'PPI::Statement::Sub'     => \&IsCamelCase,
    'PPI::Statement::Package' => \&IsCamelCase,
    'PPI::Token::Symbol'      => \&VariableIsCamelCase,
);

sub applies_to {
    return keys %Dispatcher;
}

sub prepare_to_scan_document {
    my ( $Self, $Document ) = @_;

    # Cleanup, one instance can scan multiple files.
    delete $Self->{_IsDerivedModule};

    return if $Self->IsFrameworkVersionLessThan( 3, 3 );

    if ( $Document->logical_filename() !~ m{ (\.pm) \z }xms ) {
        return 1;
    }

    # Find all use parent/base statements
    my $FindPerlInheritance = sub {
        return $Document->find_any(
            sub {
                return $_[1]->isa('PPI::Statement::Include') && $_[1] =~ m{\A use \s+ (parent|base) \s+}smx;
            }
        );
    };

    # Find any Moose or Moose::Role objects that extend another class or role (extends/with).
    my $FindMooseInheritance = sub {
        my $MooseFound = $Document->find_any(
            sub { return $_[1]->isa('PPI::Statement::Include') && $_[1] =~ m{\A use \s+ Moose(::Role)?}smx }
        );

        return 0 if !$MooseFound;

        return $Document->find_any(
            sub { return $_[1]->isa('PPI::Token::Word') && $_[1] =~ m{\A extends|with \Z}smx }
        );
    };

    # Find any Mojo::Base inheritance.
    my $FindMojoInheritance = sub {
        return $Document->find_any(
            sub { return $_[1]->isa('PPI::Statement::Include') && $_[1] =~ m{\A use \s+ Mojo::Base}smx }
        );
    };

    # Find all K::S::Main->RequireBaseClass() statements.
    my $FindRequireBaseClass = sub {
        return $Document->find_any(
            sub {
                return $_[1]->isa('PPI::Token::Word') && $_[1] eq 'RequireBaseClass';
            }
        );
    };

    if (
        $FindPerlInheritance->()
        || $FindMooseInheritance->()
        || $FindMojoInheritance->()
        || $FindRequireBaseClass->()
        )
    {
        $Self->{_IsDerivedModule} = 1;
    }

    return 1;
}

sub violates {
    my ( $Self, $Element ) = @_;

    $Self->{Errors} = ();

    my $Function = $Dispatcher{ ref $Element };
    return if !$Function;
    return if $Self->$Function($Element);

    return $Self->violation( "$Description: " . join( ", ", @{ $Self->{Errors} } ), $Explanation, $Element );
}

sub IsCamelCase {
    my ( $Self, $Element ) = @_;

    my $Name = $Element->find('PPI::Token::Word')->[1];

    return 1 if !$Name;

    my %AllowedFunctions = (
        new => 1,
    );

    if ( $Element->isa('PPI::Statement::Sub') ) {
        return 1 if $AllowedFunctions{$Name};
        return 1 if $Self->{_IsDerivedModule};
    }
    elsif ( $Element->isa('PPI::Statement::Package') ) {
        if (
            $Name =~ m{ Kernel::Language :: [a-z]{2,3}_ }xms
            || $Name eq 'main'
            || $Name =~ m{ ^scripts:: }xms
            || $Name =~ m{ ^var::packagesetup:: }xms
            )
        {
            return 1;
        }
    }

    my $IsCamelCase = !( $Name !~ m{ \A _* [A-Z][a-z]* }xms || $Name =~ m{ [^_]_ }xms );

    if ( !$IsCamelCase ) {
        push @{ $Self->{Errors} }, $Name;
    }

    return $IsCamelCase;
}

sub VariableIsCamelCase {
    my ( $Self, $Element ) = @_;

    my $Name = "$Element";
    return 1 if !$Name;

    # Allow variables from other packages.
    return 1 if index( $Name, '::' ) > -1;

    # Allow Perl builtins.
    return 1 if $Name eq '$a';
    return 1 if $Name eq '$b';

    # Ignore function calls
    return 1 if substr( $Name, 0, 1 ) eq '&';

    # Allow short variable names with lowercase characters like $s.
    return 1 if length $Name == 2;

    my $IsCamelCase = !( $Name !~ m{ \A [\*\@\$\%]_*[A-Z][a-z]* }xms || $Name =~ m{ [^_]_ }xms );

    if ( !$IsCamelCase ) {
        push @{ $Self->{Errors} }, $Name;
    }

    return $IsCamelCase;
}

1;
