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

use App::GitWorkingCopy::Action;
use App::GitWorkingCopy::Browser;

builder {
    enable 'Debug';
    enable 'Debug::TemplateToolkit';

    enable_if { $_[0]->{REQUEST_METHOD} eq 'POST' }
        sub { $webhook; };

	enable '+App::GitWorkingCopy::Action';

	enable 'Static',
		path => qr{\.(css|js|png|ico)$},
		root => 'templates',
		pass_through => 1;

    App::GitWorkingCopy::Browser->new( templates => 'templates' );
};

