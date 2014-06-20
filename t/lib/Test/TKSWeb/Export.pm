use strict;
use warnings;

package Test::TKSWeb::Export;

use base qw(Test::TKSWeb);

use Dancer qw/:syntax :tests/;
use Dancer::Plugin::DBIC qw/schema/;

use Dancer::Test;
use Test::More;

sub test_export_day : Tests(6) {
    my $self = shift;

    # GIVEN
    $self->login;

    $self->create_activity(
        date_time => '2014-07-01 09:00',
        duration => '60',
        wr_number => '17',
        description => 'Made the tea',
    );

    $self->create_activity(
        date_time => '2014-07-01 10:00',
        duration => '30',
        wr_number => '17',
        description => 'Made more tea',
    );

    $self->create_activity(
        date_time => '2014-07-01 12:00',
        duration => '45',
        wr_number => '12345',
        description => 'Actually did a bit of work',
    );

    # WHEN
    my $resp = dancer_response('GET', '/export/catalyst/2014-07-01.tks');

    # THEN
    is($resp->status, 200, "Got correct status");
    my @content = split /\n/, $resp->content;

    is($content[0], "# Export from TKSWeb for Catalyst WRMS, for date: 2014-07-01", "Header line correct");

    is($content[2], "2014-07-01 # Tuesday", "Date line is correct");
    is($content[3], "17       1.00  Made the tea", "First time sheet line correct");
    is($content[4], "17       0.50  Made more tea", "Second time sheet line correct");
    is($content[5], "12345    0.75  Actually did a bit of work", "Third time sheet line correct");
}

sub test_export_range : Tests(8) {
    my $self = shift;

    # GIVEN
    $self->login;

    $self->create_activity(
        date_time => '2014-07-01 09:00',
        duration => '60',
        wr_number => '17',
        description => 'Made the tea',
    );

    $self->create_activity(
        date_time => '2014-07-01 10:00',
        duration => '120',
        wr_number => '17',
        description => 'Made the tea',
    );

    $self->create_activity(
        date_time => '2014-07-02 12:00',
        duration => '5',
        wr_number => '12345',
        description => 'Actually did a bit of work',
    );

    $self->create_activity(
        date_time => '2014-07-03 12:00',
        duration => '15',
        wr_number => '12345',
        description => 'Actually did a bit more work',
    );

    # WHEN
    my $resp = dancer_response('GET', '/export/catalyst/2014-07-01/2014-07-02.tks');

    # THEN
    is($resp->status, 200, "Got correct status");
    my @content = split /\n/, $resp->content;

    is(scalar @content, 8, "Content is correct length");

    is($content[0], "# Export from TKSWeb for Catalyst WRMS, for period: 2014-07-01 to 2014-07-02", "Header line correct");

    is($content[2], "2014-07-01 # Tuesday", "First Date line is correct");
    is($content[3], "17       1.00  Made the tea", "First time sheet line correct");
    is($content[4], "17       2.00  Made the tea", "Second time sheet line correct");

    is($content[6], "2014-07-02 # Wednesday", "First Date line is correct");
    is($content[7], "12345    0.08  Actually did a bit of work", "Third time sheet line correct");
}

1;