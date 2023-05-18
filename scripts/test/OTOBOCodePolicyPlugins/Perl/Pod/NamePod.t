# --
# OTOBO is a web-based ticketing system for service organisations.
# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# Copyright (C) 2019-2023 Rother OSS GmbH, https://otobo.de/
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
        Name      => 'valid package name with no critic',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::Pod::NamePod)],
        Framework => '6.0',
        Source    => <<'EOF',
package scripts::test::Pod::Test;    ## no critic

use strict;
use warnings;

use parent qw(scripts::DBUpdate::Base);

our @ObjectDependencies = (
    'Kernel::System::DB',
    'Kernel::System::Log',
);

=head1 NAME

scripts::test::Pod::Test -  Testing file.

=cut

sub Run {
    ...
}
EOF
        Exception => 0,
    },
    {
        Name      => 'valid package name with out no critic',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::Pod::NamePod)],
        Framework => '6.0',
        Source    => <<'EOF',
package scripts::test::Pod::Test;

use strict;
use warnings;

use parent qw(scripts::DBUpdate::Base);

our @ObjectDependencies = (
    'Kernel::System::DB',
    'Kernel::System::Log',
);

=head1 NAME

scripts::test::Pod::Test -  Testing file.

=cut

sub Run {
    ...
}
EOF
        Exception => 0,
    },
    {
        Name      => 'wrong package name correct format',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::Pod::NamePod)],
        Framework => '6.0',
        Source    => <<'EOF',
package scripts::test::Pod::Test;    ## no critic

use strict;
use warnings;

use parent qw(scripts::DBUpdate::Base);

our @ObjectDependencies = (
    'Kernel::System::DB',
    'Kernel::System::Log',
);

=head1 NAME

scripts::test::Test -  Testing file.

=cut

sub Run {
    ...
}
EOF
        Exception => 0,
        Result    => <<'EOF',
package scripts::test::Pod::Test;    ## no critic

use strict;
use warnings;

use parent qw(scripts::DBUpdate::Base);

our @ObjectDependencies = (
    'Kernel::System::DB',
    'Kernel::System::Log',
);

=head1 NAME

scripts::test::Pod::Test -  Testing file.

=cut

sub Run {
    ...
}
EOF
    },
    {
        Name      => 'wrong package name slashes',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::Pod::NamePod)],
        Framework => '6.0',
        Source    => <<'EOF',
package scripts::test::Pod::Test;    ## no critic

use strict;
use warnings;

use parent qw(scripts::DBUpdate::Base);

our @ObjectDependencies = (
    'Kernel::System::DB',
    'Kernel::System::Log',
);

=head1 NAME

scripts/test/Pod/Test.pm -  Testing file.

=cut

sub Run {
    ...
}
EOF
        Exception => 0,
        Result    => <<'EOF',
package scripts::test::Pod::Test;    ## no critic

use strict;
use warnings;

use parent qw(scripts::DBUpdate::Base);

our @ObjectDependencies = (
    'Kernel::System::DB',
    'Kernel::System::Log',
);

=head1 NAME

scripts::test::Pod::Test -  Testing file.

=cut

sub Run {
    ...
}
EOF
    },
    {
        Name      => 'wrong package name slashes custom file', # Does not modify the file even it its wrong
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::Pod::NamePod)],
        Framework => '6.0',
        Source    => <<'EOF',
# $origin: otobo - d152f0ba9f7b326b4bd3b8624cc2c99944e2a956 - scripts/test/Pod/Test.pm
package scripts::test::Pod::Test;    ## no critic

use strict;
use warnings;

use parent qw(scripts::DBUpdate::Base);

our @ObjectDependencies = (
    'Kernel::System::DB',
    'Kernel::System::Log',
);

=head1 NAME

scripts/test/Pod/Test.pm -  Testing file.

=cut

sub Run {
    ...
}
EOF
        Exception => 0,
        Result    => <<'EOF',
# $origin: otobo - d152f0ba9f7b326b4bd3b8624cc2c99944e2a956 - scripts/test/Pod/Test.pm
package scripts::test::Pod::Test;    ## no critic

use strict;
use warnings;

use parent qw(scripts::DBUpdate::Base);

our @ObjectDependencies = (
    'Kernel::System::DB',
    'Kernel::System::Log',
);

=head1 NAME

scripts/test/Pod/Test.pm -  Testing file.

=cut

sub Run {
    ...
}
EOF
    },
    {
        Name      => 'wrong package name just name',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::Pod::NamePod)],
        Framework => '6.0',
        Source    => <<'EOF',
package scripts::test::Pod::Test;    ## no critic

use strict;
use warnings;

use parent qw(scripts::DBUpdate::Base);

our @ObjectDependencies = (
    'Kernel::System::DB',
    'Kernel::System::Log',
);

=head1 NAME

Test.pm -  Testing file.

=cut

sub Run {
    ...
}
EOF
        Exception => 0,
        Result    => <<'EOF',
package scripts::test::Pod::Test;    ## no critic

use strict;
use warnings;

use parent qw(scripts::DBUpdate::Base);

our @ObjectDependencies = (
    'Kernel::System::DB',
    'Kernel::System::Log',
);

=head1 NAME

scripts::test::Pod::Test -  Testing file.

=cut

sub Run {
    ...
}
EOF
    },

    {
        Name      => 'wrong package name correct format extended POD',
        Filename  => 'test.pl',
        Plugins   => [qw(TidyAll::Plugin::OTOBO::Perl::Pod::NamePod)],
        Framework => '6.0',
        Source    => <<'EOF',
package scripts::test::Pod::Test;    ## no critic

use strict;
use warnings;

use parent qw(scripts::DBUpdate::Base);

our @ObjectDependencies = (
    'Kernel::System::DB',
    'Kernel::System::Log',
);

=head1 NAME

scripts::test::Test -  Testing file.

=head1 DESCRIPTION

some description

=head1 SYNOPSIS

some synopsys

=cut

sub Run {
    ...
}
EOF
        Exception => 0,
        Result    => <<'EOF',
package scripts::test::Pod::Test;    ## no critic

use strict;
use warnings;

use parent qw(scripts::DBUpdate::Base);

our @ObjectDependencies = (
    'Kernel::System::DB',
    'Kernel::System::Log',
);

=head1 NAME

scripts::test::Pod::Test -  Testing file.

=head1 DESCRIPTION

some description

=head1 SYNOPSIS

some synopsys

=cut

sub Run {
    ...
}
EOF
    },
);

scripts::test::OTOBOCodePolicyPlugins::Run( Tests => \@Tests );

done_testing;
