use Test::More;
use Plack::Test;
use HTTP::Request::Common;

use_ok('App::GitWorkingCopy');

my $app = App::GitWorkingCopy->new();

test_psgi $app, sub {
    my $cb = shift;

    my $res = $cb->(GET '/');
    is $res->code, 200, 'HTTP Ok';
};

done_testing;
