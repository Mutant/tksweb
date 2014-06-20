use strict;
use warnings;

package Test::TKSWeb;

use base qw(Test::Class);

# the order is important
use Dancer qw/:syntax :tests/;
use Dancer::Plugin::DBIC qw/schema/;
use TKSWeb;
Dancer::set environment => 'unittest';
Dancer::Config->load;
use Dancer::Test;

use File::Copy;
use FindBin;

sub test_setup : Tests(setup) {
    # Reset the DB before each test
    copy "$FindBin::Bin/data/tksweb-unittest.db", "/tmp/";
}

sub clear_session {
    session->destroy;
}

sub login {
    my $self = shift;

    my %params = (
        email => 'vagrant',
        password => 'vagrant',
    );

    my $resp = dancer_response('POST', '/login', { params => \%params } );

    die "Failed logging in" unless $resp->status eq '302';

}

sub wr_system {
    my $self = shift;

    $self->{wr_system} //= schema->resultset('WRSystem')->find(
        {
            name => 'catalyst',
        }
    );

    return $self->{wr_system};
}

sub user {
    my $self = shift;

    $self->{user} //= schema->resultset('AppUser')->find(
        {
            email => 'vagrant',
        }
    );

    return $self->{user};

}

sub create_activity {
    my $self = shift;
    my %params = @_;

    $params{user} //= $self->user;

    $params{wr_system} //= $self->wr_system;

    schema->resultset('Activity')->create(
        {
            app_user_id => $params{user}->id,
            wr_system_id => $params{wr_system}->id,
            date_time => $params{date_time},
            duration => $params{duration},
            wr_number => $params{wr_number},
            description => $params{description},
        }
    );
}

1;