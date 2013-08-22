use Plack::Builder;
use Plack::App::Directory::Template 0.24;
use Plack::App::GitHub::WebHook;
use Git::Repository qw(Log Status);

use Plack::Middleware::Debug::Panel;

my $webhook = Plack::App::GitHub::WebHook->new(
  hook => sub {
    # TODO
    # git update-server-info # to allow cloning via HTTP(S)
})->to_app;

use Git::WorkingCopy;

builder {
    enable 'Debug';
    enable 'Debug::TemplateToolkit';

    enable_if { $_[0]->{REQUEST_METHOD} eq 'POST' }
        sub { $webhook; };

	# TODO
    enable_if { Plack::Request->new($_[0])->param('action') }
        sub {
            my $app = shift;
            sub {
                my $env = shift;
                
                # do processing, optionally add to tt.vars
                # e.g.:

                my $logfile = '/tmp/mylog';
                my $logsep  = '^---*$';
           
                # action=log
                my $num = 2;
                my $log = `tac -b -r -s $logsep $logfile | awk '/$logsep/{c++}c>$num{exit}{print}`;

                [200,['Content-Type' => 'text/plain'], $log];

				$env->{'tt.vars'}->{log} = "...";

                return $app->($env);
            };
        };

	enable 'Static',
		path => qr{\.(css|js|png|ico)$},
		root => 'templates',
		pass_through => 1;

    Git::WorkingCopy->new( templates => 'templates' );
};

