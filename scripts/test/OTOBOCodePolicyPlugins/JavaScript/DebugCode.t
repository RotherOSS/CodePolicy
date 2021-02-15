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
        Name      => 'DebugCode - console logging (valid)',
        Filename  => 'Test.js',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::JavaScript::DebugCode)],
        Framework => '7.0',
        Source    => <<'EOF',
this.$log.debug('varName', varName);
EOF
        Exception => 0,
    },
    {
        Name      => 'DebugCode - console logging (invalid)',
        Filename  => 'Test.js',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::JavaScript::DebugCode)],
        Framework => '8.0',
        Source    => <<'EOF',
// TODO: Remove the code below.
this.$nextTick(() => {
    console.log('varName', varName);
});
EOF
        Exception => 1,
    },
    {
        Name      => 'DebugCode - skipped test (invalid)',
        Filename  => 'Test.js',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::JavaScript::DebugCode)],
        Framework => '8.0',
        Source    => <<'EOF',
    // TODO: Skip this test for now.
    xit('supports hiding of the description next to the label', () => {
        expect.assertions(2);

        wrapper.setProps({
            hideDescription: true,
        });

        wrapper.vm.$nextTick(() => {
            expect(wrapper.contains('label a.float-right i.CommonIcon__Bold--InformationCircle')).toBe(true);
            expect(wrapper.contains('small.sr-only')).toBe(true);
        });
    });
EOF
        Exception => 1,
    },
    {
        Name      => 'DebugCode - function similar in name to skipped test (valid)',
        Filename  => 'Test.js',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::JavaScript::DebugCode)],
        Framework => '8.0',
        Source    => <<'EOF',
function exit () {
    // Do something.
}
exit();
EOF
        Exception => 0,
    },
);

$Self->scripts::test::OTOBOCodePolicyPlugins::Run( Tests => \@Tests );

1;
