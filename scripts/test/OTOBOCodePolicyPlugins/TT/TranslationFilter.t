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

use strict;
use warnings;
use utf8;

# core modules

# CPAN modules
use Test2::V0;

# OTOBO modules
use scripts::test::OTOBOCodePolicyPlugins;

my @Tests = (
    {
        Name      => 'Simple function translation, invalid',
        Filename  => 'Template.tt',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::TT::TranslationFilter)],
        Framework => '6.0',
        Source    => <<'EOF',
[% Translate("Hello, world!") %]
EOF
        Exception => 1,
    },
    {
        Name      => 'Simple function translation with HTML filter, valid',
        Filename  => 'Template.tt',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::TT::TranslationFilter)],
        Framework => '6.0',
        Source    => <<'EOF',
[% Translate("Hello, world!") | html %]
EOF
        Exception => 0,
    },
    {
        Name      => 'Simple function translation with JSON filter, valid',
        Filename  => 'Template.tt',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::TT::TranslationFilter)],
        Framework => '6.0',
        Source    => <<'EOF',
[% Translate("Hello, world!") | JSON %]
EOF
        Exception => 0,
    },
    {
        Name      => 'Variable function translation, invalid',
        Filename  => 'Template.tt',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::TT::TranslationFilter)],
        Framework => '6.0',
        Source    => <<'EOF',
[% Translate(Data.Language) %]
EOF
        Exception => 1,
    },
    {
        Name      => 'Variable function translation, valid',
        Filename  => 'Template.tt',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::TT::TranslationFilter)],
        Framework => '6.0',
        Source    => <<'EOF',
[% Translate(Data.Language) | html %]
EOF
        Exception => 0,
    },
    {
        Name      => 'Complex function translation, invalid',
        Filename  => 'Template.tt',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::TT::TranslationFilter)],
        Framework => '6.0',
        Source    => <<'EOF',
&ndash; <span title="[% Translate("Created") %]: [% Data.CreateTime | Localize("TimeShort") %]">[% Data.CreateTime | Localize("TimeShort") %]</span> [% Translate("via %s", Translate(Data.CommunicationChannel)) | html %]
EOF
        Exception => 1,
    },
    {
        Name      => 'Complex function translation, valid',
        Filename  => 'Template.tt',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::TT::TranslationFilter)],
        Framework => '6.0',
        Source    => <<'EOF',
&ndash; <span title="[% Translate("Created") | html %]: [% Data.CreateTime | Localize("TimeShort") %]">[% Data.CreateTime | Localize("TimeShort") %]</span> [% Translate("via %s", Translate(Data.CommunicationChannel)) | html %]
EOF
        Exception => 0,
    },
    {
        Name      => 'Function translation with placeholder, invalid',
        Filename  => 'Template.tt',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::TT::TranslationFilter)],
        Framework => '6.0',
        Source    => <<'EOF',
<a href="[% Env("Baselink") %]Action=AdminOTOBOCommunity" class="Button"><i class="fa fa-angle-double-up"></i> [% Translate("Upgrade to %s", OTOBOCommunityLabel) %]</a>
EOF
        Exception => 1,
    },
    {
        Name      => 'Function translation with placeholder, valid',
        Filename  => 'Template.tt',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::TT::TranslationFilter)],
        Framework => '6.0',
        Source    => <<'EOF',
<a href="[% Env("Baselink") %]Action=AdminOTOBOCommunity" class="Button"><i class="fa fa-angle-double-up"></i> [% Translate("Upgrade to %s") | html | ReplacePlaceholders(OTOBOCommunityLabel) %]</a>
EOF
        Exception => 0,
    },
    {
        Name      => 'Function translation with placeholders, invalid',
        Filename  => 'Template.tt',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::TT::TranslationFilter)],
        Framework => '6.0',
        Source    => <<'EOF',
[% Translate('This system uses the %s without a proper license! Please make contact with %s to renew or activate your contract!', OTOBOCommunityLabel, '<a href="mailto:hallo@otobo.de">hallo@otobo.de</a>') %]
EOF
        Exception => 1,
    },
    {
        Name      => 'Function translation with placeholders, valid',
        Filename  => 'Template.tt',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::TT::TranslationFilter)],
        Framework => '6.0',
        Source    => <<'EOF',
[% Translate('This system uses the %s without a proper license! Please make contact with %s to renew or activate your contract!') | html | ReplacePlaceholders(OTOBOCommunityLabel, '<a href="mailto:hallo@otobo.de">hallo@otobo.de</a>') %]
EOF
        Exception => 0,
    },
    {
        Name      => 'Function translation with no spaces, invalid',
        Filename  => 'Template.tt',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::TT::TranslationFilter)],
        Framework => '6.0',
        Source    => <<'EOF',
<button class="Primary CallForAction" type="submit" value="[%Translate("Add")%]"><span>[% Translate("Add") | html %]</span></button>
EOF
        Exception => 1,
    },
    {
        Name      => 'Function translation with no spaces, valid',
        Filename  => 'Template.tt',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::TT::TranslationFilter)],
        Framework => '6.0',
        Source    => <<'EOF',
<button class="Primary CallForAction" type="submit" value="[%Translate("Add")|html%]"><span>[% Translate("Add") | html %]</span></button>
EOF
        Exception => 0,
    },
    {
        Name      => 'Filter translation, invalid',
        Filename  => 'Template.tt',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::TT::TranslationFilter)],
        Framework => '6.0',
        Source    => <<'EOF',
<span title="[% Translate(Data.Content) | html %]">[% Data.Content | Translate | truncate(Data.MaxLength) %]</span>
EOF
        Exception => 1,
    },
    {
        Name      => 'Filter translation, valid',
        Filename  => 'Template.tt',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::TT::TranslationFilter)],
        Framework => '6.0',
        Source    => <<'EOF',
<span title="[% Translate(Data.Content) | html %]">[% Data.Content | Translate | truncate(Data.MaxLength) | html %]</span>
EOF
        Exception => 0,
    },
    {
        Name      => 'Second filter translation, invalid',
        Filename  => 'Template.tt',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::TT::TranslationFilter)],
        Framework => '6.0',
        Source    => <<'EOF',
var Message = [% Data.CustomerRegExErrorMessageServerErrorMessage | Translate %];
EOF
        Exception => 1,
    },
    {
        Name      => 'Second filter translation, valid',
        Filename  => 'Template.tt',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::TT::TranslationFilter)],
        Framework => '6.0',
        Source    => <<'EOF',
var Message = [% Data.CustomerRegExErrorMessageServerErrorMessage | Translate | JSON %];
EOF
        Exception => 0,
    },

);

scripts::test::OTOBOCodePolicyPlugins::Run( Tests => \@Tests );

done_testing;
