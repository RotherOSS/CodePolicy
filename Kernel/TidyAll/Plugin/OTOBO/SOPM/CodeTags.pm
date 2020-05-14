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

package TidyAll::Plugin::OTOBO::SOPM::CodeTags;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::OTOBO::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan( 4, 0 );

    my ( @SelfUsed, @CDATAMissing );

    $Code =~ s{
        (<Code[a-zA-Z]+.*?>)    # start tag
        (.*?)                   # content
        </Code[a-zA-Z]+.*?>     # end tag
    }{
        my $StartTag = $1;
        my $TagContent = $2;

        if ($TagContent =~ m{\$Self}smx) {
            push @SelfUsed, $StartTag;
        }
        if ($TagContent !~ m{ \A\s*<!\[CDATA\[ }smx) {
            push @CDATAMissing, $StartTag;
        }

    }smxge;

    my $ErrorMessage;

    if (@SelfUsed) {
        $ErrorMessage
            .= "Don't use \$Self in <Code*> tags. Use \$Kernel::OM->Get() instead to access objects.\n";
        $ErrorMessage .= "Wrong tags found: " . join( ', ', @SelfUsed ) . "\n";
    }

    if (@CDATAMissing) {
        $ErrorMessage .= "<Code*> tags should always be wrapped in CDATA sections.\n";
        $ErrorMessage .= "Wrong tags found: " . join( ', ', @SelfUsed ) . "\n";
    }

    ## nofilter(TidyAll::Plugin::OTOBO::Perl::ObjectDependencies)
    my $Example = <<'EOF';
Here is a valid example tag:
    <CodeInstall Type="post"><![CDATA[
        $Kernel::OM->Get('var::packagesetup::MyPackage')->CodeInstall();
    ]]></CodeInstall>
EOF

    if ($ErrorMessage) {
        return $Self->DieWithError("$ErrorMessage\n$Example");
    }
}

1;
