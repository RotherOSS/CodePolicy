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

package TidyAll::Plugin::OTOBO::JavaScript::Vue::EventListeners;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTOBO::Base);

=head1 DESCRIPTION

SPAs are very sensitive about memory leaks caused by improperly cleaned up event handlers.

This filter performs a rudimentary check for this: make sure that event handlers are cleaned up,
and do not contain anonymous functions.

=cut

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 7, 0 );

    my $ErrorMessage;

    my %EventBalance;

    # We need a sub to be able to perform an early return in the regex eval block.
    my $CheckEvents = sub {

        # print "Listener found: $1 $2 $3 $4\n";
        my $TargetObject     = $+{TargetObject};
        my $RegistrationType = $+{RegistrationType};
        my $EventName        = $+{EventName};
        my $EventHandler     = $+{EventHandler};

        # Special handling for DOM event listeners.
        if ( $RegistrationType eq 'addEventListener' || $RegistrationType eq 'removeEventListener' ) {

            # Event white list.
            if ( $EventName eq 'beforeunload' ) {
                return;
            }
            if ( $TargetObject !~ m{(^|[.])(window|document)}smxg ) {
                return;
            }
        }

        # Special handling for Vue event listeners.
        if ( $RegistrationType eq '$on' || $RegistrationType eq '$off' ) {

            # Ignore events of the Vue application itself.
            if ( substr( $TargetObject, 0, 3 ) eq 'vm.' ) {
                return;
            }
        }

        if ( $RegistrationType eq '$off' || $RegistrationType eq 'removeEventListener' ) {
            $EventBalance{$TargetObject}->{$EventName}--;
        }
        else {
            $EventBalance{$TargetObject}->{$EventName}++;
        }

        if ( $EventHandler =~ m{function | =>} ) {
            $ErrorMessage
                .= "The event listener for '$EventName' on '$TargetObject' may not contain an anonymous function (found: '$EventHandler').\n";
        }

        return;
    };

    # Find all event listener registrations in the code.
    $Code =~ s{
        (?:^|\s)
        (?<TargetObject>[a-zA-Z0-9_\$.]+)
        [.]
        (?<RegistrationType>\$on|\$off|addEventListener|removeEventListener)
        [(]
        ['"](?<EventName>[^'"]+)['"]
        \s*,\s*
        (?<EventHandler>.*?)
        $
    }{
        $CheckEvents->();
        '';
    }esmxg;

    for my $TargetObject ( sort keys %EventBalance ) {
        for my $EventName ( sort keys %{ $EventBalance{$TargetObject} // {} } ) {
            if ( $EventBalance{$TargetObject}->{$EventName} > 0 ) {
                $ErrorMessage
                    .= "The event listener for '$EventName' was not as often added as removed from '$TargetObject'.\n";
            }
        }
    }

    if ($ErrorMessage) {
        return $Self->DieWithError("$ErrorMessage");
    }
}

1;
