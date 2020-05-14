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
        Name      => 'valid function documentation',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::Pod::FunctionPod)],
        Framework => '6.0',
        Source    => <<'EOF',
=head2 Get()

Retrieves a singleton object, and if it not yet exists, implicitly creates one for you.

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # On the second call, this returns the same ConfigObject as above.
    my $ConfigObject2 = $Kernel::OM->Get('Kernel::Config');

=cut

sub Get {
    ...
}
EOF
        Exception => 0,
    },
    {
        Name      => 'heading that is not related to a function',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::Pod::FunctionPod)],
        Framework => '6.0',
        Source    => <<'EOF',
=head2 How does singleton management work?

It creates objects as late as possible and keeps references to them. Upon destruction the objects
are destroyed in the correct order, based on their dependencies (see below).
EOF
        Exception => 0,
    },
    {
        Name      => 'function without parentheses',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::Pod::FunctionPod)],
        Framework => '6.0',
        Source    => <<'EOF',
=head2 Get

Retrieves a singleton object, and if it not yet exists, implicitly creates one for you.

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # On the second call, this returns the same ConfigObject as above.
    my $ConfigObject2 = $Kernel::OM->Get('Kernel::Config');

=cut

sub Get {
    ...
}
EOF
        Exception => 1,
    },
    {
        Name      => 'function with wrong name',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::Pod::FunctionPod)],
        Framework => '6.0',
        Source    => <<'EOF',
=head2 WrongName()

Retrieves a singleton object, and if it not yet exists, implicitly creates one for you.

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # On the second call, this returns the same ConfigObject as above.
    my $ConfigObject2 = $Kernel::OM->Get('Kernel::Config');

=cut

sub Get {
    ...
}
EOF
        Exception => 1,
    },
    {
        Name      => 'wrong function call used in example',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::Pod::FunctionPod)],
        Framework => '6.0',
        Source    => <<'EOF',
=head2 Get()

Retrieves a singleton object, and if it not yet exists, implicitly creates one for you.

    my $ConfigObject = $Kernel::OM->WrongFunction('Kernel::Config');

    # On the second call, this returns the same ConfigObject as above.
    my $ConfigObject2 = $Kernel::OM->Get('Kernel::Config');

=cut

sub Get {
    ...
}
EOF
        Exception => 1,
    },
    {
        Name      => 'valid constructor with Create',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::Pod::FunctionPod)],
        Framework => '6.0',
        Source    => <<'EOF',
=head2 new()

Creates a DateTime object. Do not use new() directly, instead use the object manager:


    # Create an object with current date and time
    # within time zone set in SysConfig OTOBOTimeZone:
    my $DateTimeObject = $Kernel::OM->Create(
        'Kernel::System::DateTime'
    );

=cut

sub new {
    ...
}
EOF
        Exception => 0,
    },
    {
        Name      => 'valid constructor with Get',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::Pod::FunctionPod)],
        Framework => '6.0',
        Source    => <<'EOF',
=head2 new()

Don't use the constructor directly, use the ObjectManager instead:

    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

=cut

sub new {
    ...
}
EOF
        Exception => 0,
    },
    {
        Name      => 'valid constructor with new',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::Pod::FunctionPod)],
        Framework => '6.0',
        Source    => <<'EOF',
=head2 new()

Fake for testing.

    my $TicketObject = Kernel::System::Ticket->new();

=cut

sub new {
    ...
}
EOF
        Exception => 0,
    },
);

$Self->scripts::test::OTOBOCodePolicyPlugins::Run( Tests => \@Tests );

1;
