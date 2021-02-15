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
use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::OTOBOCodePolicyPlugins;

my @Tests = (
    {
        Name      => 'PO::DocbookLint, valid docbook',
        Filename  => 'doc-admin-test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::PO::DocbookLint)],
        Framework => '4.0',
        Source    => <<'EOF',
msgid "Yes <link linkend=\"123\">this</link> works"
msgstr "Ja <link linkend=\"123\">das</link> funktioniert"
EOF
        Exception => 0,
    },
    {
        Name      => 'PO::DocbookLint, valid docbook (ignored tag missing)',
        Filename  => 'doc-admin-test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::PO::DocbookLint)],
        Framework => '4.0',
        Source    => <<'EOF',
msgid "Yes <emphasis>this</emphasis> works"
msgstr "Ja das funktioniert"
EOF
        Exception => 0,
    },
    {
        Name      => 'PO::DocbookLint, invalid docbook (invalid xml)',
        Filename  => 'doc-admin-test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::PO::DocbookLint)],
        Framework => '4.0',
        Source    => <<'EOF',
msgid "Yes <link linkend=\"123\">this</link> works"
msgstr "Ja <link linkend=\"123\">das</link> funktioniert <extratag unclosed>"
EOF
        Exception => 1,
    },
    {
        Name      => 'PO::DocbookLint, invalid docbook (missing tags)',
        Filename  => 'doc-admin-test.xml',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::PO::DocbookLint)],
        Framework => '4.0',
        Source    => <<'EOF',
msgid "<placeholder type=\"screeninfo\" id=\"0\"/> <graphic srccredit=\"process-"
"management - screenshot\" scale='40' fileref=\"screenshots/pm-accordion-new-"
"transition.png\"></graphic>"
msgstr "Falsch übersetzt"
EOF
        Exception => 1,
    },
);

$Self->scripts::test::OTOBOCodePolicyPlugins::Run( Tests => \@Tests );

1;
