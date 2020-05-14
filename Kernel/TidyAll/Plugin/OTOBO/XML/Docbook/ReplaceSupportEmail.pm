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

package TidyAll::Plugin::OTOBO::XML::Docbook::ReplaceSupportEmail;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTOBO::Base);

my $English1RegExp = <<'END_REGEXP';
\n \s* <para> \s*
\s*        If \s+ you \s+ have \s+ questions \s+ regarding \s+ this \s+ package, \s+ please \s+ contact \s+ your \s+ support \s+ team
\s+        \(support\@otobo\.com\) \s+ for \s+ more \s+ information \. \n
\s*    <\/para> \n
END_REGEXP

my $English2RegExp = <<'END_REGEXP';
\n \s* <para> \s*
\s*        If \s+ you \s+ have \s+ questions \s+ regarding \s+ this \s+ document \s+ or \s+ if \s+ you \s+ need \s+ further \s+ information, \s+ please \s+ log \s+ in \s+ to \s+ our \s+ customer \s+ portal \s+ at \s+ portal\.otobo\.com \s+ with \s+ your \s+ OTOBO \s+ ID \s+ and \s+ create \s+ a \s+ ticket\.
\s+        You \s+ do \s+ not \s+ have \s+ an \s+ OTOBO \s+ ID \s+ yet\? \s+ Register
\s*        <ulink \s+ url="https:\/\/portal\.otobo\.com\/otobo\/customer\.pl\#Signup">here \s+ for \s+ free<\/ulink>\.
\s*    <\/para> \n
END_REGEXP

my $German1RegExp = <<'END_REGEXP';
\n \s* <para> \s*
\s*         Bei \s+ Fragen \s+ betreffend \s+ dieses \s+ Dokumentes, \s+ kontaktieren \s+ Sie \s+ Ihren \s+ Support \s+ \(support\@otobo\.com\) \s+ für \s+ weitere \s+ Informationen \. \n
\s*    <\/para> \n
END_REGEXP

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    my $EnglishReplacement = _EnglishReplacement();
    my $GermanReplacement  = _GermanReplacement();

    # replace support para
    $Code =~ s{$English1RegExp}{$EnglishReplacement}xms;
    $Code =~ s{$German1RegExp}{$GermanReplacement}xms;

    # Replace support para with the correct language
    if ( $Code =~ m{^ \s* <book \s+ lang='de'> }smx ) {
        $Code =~ s{$English2RegExp}{$GermanReplacement}xms;
    }

    return $Code;
}

sub _EnglishReplacement {
    return <<'END_REPLACEMENT';

    <para>
        If you have questions regarding this document or if you need further information, please log in to our customer portal at portal.otobo.com with your OTOBO ID and create a ticket.
        You do not have an OTOBO ID yet? Register
        <ulink url="https://portal.otobo.com/otobo/customer.pl#Signup">here for free</ulink>.
    </para>
END_REPLACEMENT
}

sub _GermanReplacement {
    return <<'END_REPLACEMENT';

    <para>
        Sollten Sie Fragen zu diesem Dokument haben oder weitere Informationen benötigen, loggen Sie sich bitte mit Ihrer OTOBO-ID in unser Kundenportal unter portal.otobo.com ein und eröffnen Sie ein Ticket. Sie haben noch keine OTOBO-ID? Registrieren Sie sich
        <ulink url="https://portal.otobo.com/otobo/customer.pl#Signup">hier kostenlos</ulink>.
    </para>
END_REPLACEMENT
}

1;
