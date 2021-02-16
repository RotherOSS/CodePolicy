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
        Name      => 'PO::HTMLTags, valid bold tag',
        Filename  => 'otobo.de.po',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::PO::HTMLTags)],
        Framework => '6.0',
        Source    => <<'EOF',
msgid "String with <b>tag</b>"
msgstr "Zeichenkette mit <b>Tag</b>"
EOF
        Exception => 0,
    },
    {
        Name      => 'PO::HTMLTags, forbidden script tag',
        Filename  => 'otobo.de.po',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::PO::HTMLTags)],
        Framework => '6.0',
        Source    => <<'EOF',
msgid "String with <sCrIpT>evil tag</script>"
msgstr "Zeichenkette mit <script>bösem Tag</script>"
EOF
        Exception => 1,
    },
    {
        Name      => 'PO::HTMLTags, valid paragraph tag',
        Filename  => 'otobo.pot',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::PO::HTMLTags)],
        Framework => '6.0',
        Source    => <<'EOF',
msgid "<p>Paragraph string</p>"
msgstr ""
EOF
        Exception => 0,
    },
    {
        Name      => 'PO::HTMLTags, forbidden meta tag',
        Filename  => 'otobo.pot',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::PO::HTMLTags)],
        Framework => '6.0',
        Source    => <<'EOF',
msgid "Redirecting now... <META http-equiv=\"refresh\" content=\"0; url=http://example.com/\">"
msgstr ""
EOF
        Exception => 1,
    },
    {
        Name      => 'PO::HTMLTags, paragraph tag with forbidden attribute',
        Filename  => 'otobo.pot',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::PO::HTMLTags)],
        Framework => '6.0',
        Source    => <<'EOF',
msgid "<p onmouseover=\"alert(1);\">Paragraph string</p>"
msgstr ""
EOF
        Exception => 1,
    },
    {
        Name      => 'PO::HTMLTags, anchor tag with forbidden attributes',
        Filename  => 'otobo.pot',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::PO::HTMLTags)],
        Framework => '6.0',
        Source    => <<'EOF',
msgid "<a href=\"https://evil.com/danger.php\" style=\"color:red\">No more space on device! OTOBO will stop. Click here for details.</a>"
msgstr ""
EOF
        Exception => 1,
    },
    {
        Name      => 'PO::HTMLTags, link tag with forbidden attributes',
        Filename  => 'otobo.pot',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::PO::HTMLTags)],
        Framework => '6.0',
        Source    => <<'EOF',
msgid "foo<link href=\"https://evil.com/danger.php\" rel=\"stylesheet\">bar"
msgstr ""
EOF
        Exception => 1,
    },
);

$Self->scripts::test::OTOBOCodePolicyPlugins::Run( Tests => \@Tests );

1;
