use Test::More;

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use Test::TKSWeb::Login;

Test::Class->runtests();