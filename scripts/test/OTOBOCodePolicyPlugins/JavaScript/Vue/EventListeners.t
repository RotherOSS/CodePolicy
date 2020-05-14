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
use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::OTOBOCodePolicyPlugins;

my @Tests = (
    {
        Name      => 'Event Listeners (valid)',
        Filename  => 'Test.js',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::JavaScript::Vue::EventListeners)],
        Framework => '8.0',
        Source    => <<'EOF',
    mounted() {
        this.$bus.$on('myEvent', this.my_handler);
    }
    destroyed() {
        this.$bus.$off('myEvent', this.my_handler);
    }
EOF
        Exception => 0,
    },
    {
        Name      => 'Event Listeners (multiple removes)',
        Filename  => 'Test.js',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::JavaScript::Vue::EventListeners)],
        Framework => '8.0',
        Source    => <<'EOF',
    mounted() {
        this.$bus.$on('myEvent', this.my_handler);
    }
    destroyed() {
        this.$bus.$off('myEvent', this.my_handler);
    }
    other_method() {
        this.$bus.$off('myEvent', this.my_handler);
    }
EOF
        Exception => 0,
    },
    {
        Name      => 'Event Listeners (missing deregister)',
        Filename  => 'Test.js',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::JavaScript::Vue::EventListeners)],
        Framework => '8.0',
        Source    => <<'EOF',
    mounted() {
        this.$bus.$on('myEvent', this.my_handler);
    }
    destroyed() {
        this.$bus.$off('myEvent_withTypo', this.my_handler);
    }
EOF
        Exception => 1,
    },
    {
        Name      => 'Event Listeners (anonymous function)',
        Filename  => 'Test.js',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::JavaScript::Vue::EventListeners)],
        Framework => '8.0',
        Source    => <<'EOF',
    mounted() {
        this.$bus.$on('myEvent', (event) => { ... } ));
    }
    destroyed() {
        this.$bus.$off('myEvent', (event) => { ... } ));
    }
EOF
        Exception => 1,
    },
    {
        Name      => 'Event Listeners (application event)',
        Filename  => 'Test.js',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::JavaScript::Vue::EventListeners)],
        Framework => '8.0',
        Source    => <<'EOF',
    vm.$bus.$on('myEvent', (event) => { ... } ));
EOF
        Exception => 0,
    },
    {
        Name      => 'Event Listeners (DOM event listeners)',
        Filename  => 'Test.js',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::JavaScript::Vue::EventListeners)],
        Framework => '8.0',
        Source    => <<'EOF',
// Start listening on 'Esc' key presses.
if (this.isModal) document.addEventListener('keyup', this.onEscape);

// Stop listening on 'Esc' key presses.
if (this.isModal) document.removeEventListener('keyup', this.onEscape);
EOF
        Exception => 0,
    },
    {
        Name      => 'Event Listeners (DOM event listeners, improper cleanup)',
        Filename  => 'Test.js',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::JavaScript::Vue::EventListeners)],
        Framework => '8.0',
        Source    => <<'EOF',
// Start listening on 'Esc' key presses.
if (this.isModal) document.addEventListener('keyup', this.onEscape);
EOF
        Exception => 1,
    },
    {
        Name      => 'Event Listeners (DOM event listeners, local object)',
        Filename  => 'Test.js',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::JavaScript::Vue::EventListeners)],
        Framework => '8.0',
        Source    => <<'EOF',
// Start listening on 'Esc' key presses.
if (this.isModal) myNewNode.addEventListener('keyup', this.onEscape);
EOF
        Exception => 0,
    },
    {
        Name      => 'Event Listeners (DOM event listeners, whitelisted event)',
        Filename  => 'Test.js',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::JavaScript::Vue::EventListeners)],
        Framework => '8.0',
        Source    => <<'EOF',
// Start listening on 'Esc' key presses.
if (this.isModal) window.addEventListener('beforeunload', this.onEscape);
EOF
        Exception => 0,
    },
    {
        Name      => 'Event Listeners (DOM event listeners, mixed good and bad)',
        Filename  => 'Test.js',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::JavaScript::Vue::EventListeners)],
        Framework => '8.0',
        Source    => <<'EOF',
// Start listening on 'Esc' key presses.
if (this.isModal) window.addEventListener('beforeunload', this.onEscape);
if (this.isModal) document.addEventListener('keyup', this.onEscape);
EOF
        Exception => 1,
    },

);

$Self->scripts::test::OTOBOCodePolicyPlugins::Run( Tests => \@Tests );

1;
