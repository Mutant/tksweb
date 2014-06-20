use strict;
use warnings;

package Test::TKSWeb::Activity::Create;

use base qw(Test::TKSWeb);

use Dancer qw/:syntax :tests/;
use Dancer::Plugin::DBIC qw/schema/;
use Dancer::Test;
use Test::More;

sub test_create_activity : Tests(7) {
    my $self = shift;

    # GIVEN
    $self->login;

    my %params = (
        date => '2014-07-01',
        description => 'A new activity',
        duration => 60,
        start_time => 810,
        wr_number => 12345,
        wr_system_id => $self->wr_system->id,
    );

    # WHEN
    my $resp = dancer_response('POST', '/activity', { body => to_json \%params } );

    # THEN
    is($resp->status, 200, "Correct status returned");
    my $content = from_json $resp->content;

    my $activity = schema->resultset('Activity')->find($content->{id});

    is($activity->description, 'A new activity', "description is correct");
    is($activity->date_time, '2014-07-01T13:30:00', "date_time is correct");
    is($activity->duration, '60', "duration is correct");
    is($activity->wr_number, '12345', "wr_number is correct");
    is($activity->app_user_id, $self->user->id, "user_id is correct");
    is($activity->wr_system_id, $self->wr_system->id, "wr_system_id is correct");
}

sub test_create_activity_overlapping : Tests() {
    my $self = shift;

    # GIVEN
    $self->login;

    $self->create_activity(
        date_time => '2014-07-01 13:30',
        description => 'A new activity',
        duration => 180,
        wr_number => 54321,
    );

    my %params = (
        date => '2014-07-01',
        description => 'Another activity',
        duration => 30,
        start_time => 900,
        wr_number => 12345,
        wr_system_id => $self->wr_system->id,
    );

    # WHEN
    my $resp = dancer_response('POST', '/activity', { body => to_json \%params } );

    # THEN
    is($resp->status, 409, "Correct status returned");
    warn $resp->content;
}

1;