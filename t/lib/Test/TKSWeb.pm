use strict;
use warnings;

package Test::TKSWeb;

use base qw(Test::Class);

# the order is important
use Dancer qw/:syntax :tests/;
use TKSWeb;
Dancer::set environment => 'unittest';
Dancer::Config->load;

use File::Copy;
use FindBin;

sub test_setup : Tests(setup) {
    # Reset the DB before each test
    copy "$FindBin::Bin/data/tksweb-unittest.db", "/tmp/";
}

sub clear_session {
    session->destroy;
}

1;