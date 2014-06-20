use strict;
use warnings;

package Test::TKSWeb::Login;

use base qw(Test::TKSWeb);

use Dancer qw/:syntax :tests/;

use Dancer::Test;
use Test::More;

sub test_redirected_to_login_screen : Tests(2) {
    my $self = shift;

    # GIVEN
    $self->clear_session;

    # WHEN
    my $resp = dancer_response('GET', '/');

    # THEN
    is($resp->status, '302', 'response for root is a redirect');
    is($resp->header('Location'), 'http://localhost/login', 'redirected to login screen');
}

sub test_redirect_when_logged_in : Tests(2) {
    my $self = shift;

    # GIVEN
    $self->login;

    # WHEN
    my $resp = dancer_response('GET', '/');

    # THEN
    is($resp->status, '302', 'response for root is a redirect');
    like($resp->header('Location'), qr{http://localhost/week/\d{4}-\d{2}-\d{2}}, 'redirected correctly');
}

# Test login screen displays correctly
sub test_login_screen_non_ldap : Tests(2) {
    my $self = shift;

    response_content_like(['GET' => '/login'], qr{Log in to TKS-Web}, "Login screen displayed");
    response_content_like(['GET' => '/login'], qr{Email Address}, "Email Address requested");
}

# Test login with a local user
sub test_login_non_ldap : Tests(3) {
    my $self = shift;

    # GIVEN
    my %params = (
        email => 'vagrant',
        password => 'vagrant',
    );

    # WHEN
    my $resp = dancer_response('POST', '/login', { params => \%params } );

    # THEN
    is($resp->status, '302', "Redirected after successful login");
    is($resp->header('location'), 'http://localhost/', "Redirected back to root");
    is(session->{email}, 'vagrant', "'Email' saved in session");
}

# Test unsuccessful login
sub test_login_non_ldap_failure : Tests(3) {
    my $self = shift;

    # GIVEN
    my %params = (
        email => 'vagrant',
        password => 'wrong',
    );

    # WHEN
    my $resp = dancer_response('POST', '/login', { params => \%params } );

    # THEN
    is($resp->status, '200', "Correct status");
    like($resp->content, qr{Invalid username or password}, "Error message returned");
    like($resp->content, qr{value="vagrant"}, "Form pre-populated");
}

1;