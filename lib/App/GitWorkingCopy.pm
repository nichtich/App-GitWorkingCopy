package App::GitWorkingCopy;
#ABSTRACT: Web interface to a git working copy

use strict;
use warnings;

use parent 'Plack::Component';

use Plack::Util::Accessor qw(app);

use Plack::Builder;
use Plack::App::Directory::Template;
use Plack::App::GitHub::WebHook;
use Git::Repository qw(Log Status);

use App::GitWorkingCopy::Action;
use App::GitWorkingCopy::Browser;

sub prepare_app {
    my $self = shift;

    my $webhook = Plack::App::GitHub::WebHook->new(
      hook => sub {
        # TODO
        # git update-server-info # to allow cloning via HTTP(S)
    })->to_app;

    $self->app( builder {
        enable_if { $_[0]->{REQUEST_METHOD} eq 'POST' }
            sub { $webhook; };

        enable '+App::GitWorkingCopy::Action';

        enable 'Static',
            path => qr{\.(css|js|png|ico)$},
            root => 'templates', # TODO: shareDir
            pass_through => 1;

        App::GitWorkingCopy::Browser->new( templates => 'templates' );
    });
}

sub call {
    my ($self,$env) = @_;
    $self->app->($env);
}

1;

=encoding utf8
