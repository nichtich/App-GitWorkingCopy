use Plack::Builder;
use Plack::App::Directory::Template;
use Plack::App::GitHub::WebHook;
use Git::Repository;

use Plack::Middleware::Debug::Panel;

my $webhook = Plack::App::GitHub::WebHook->new( hook => sub {
    # TODO
})->to_app;


builder {
    enable 'Debug';
    enable 'Debug::TemplateToolkit';

    enable_if { $_[0]->{REQUEST_METHOD} eq 'POST' }
        sub { $webhook; };
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

                return $app->($env);
            };
        };
    Plack::App::Directory::Template->new(
        templates => 'templates',
        filter    => sub {
            my $vars = shift;
            my $git  = Git::Repository->new( work_tree => $vars->{dir} );

            $vars->{remote} = $1 if `git remote -v` =~ /^origin\s+(.+)\s+\(fetch\)$/m;
            $vars->{branch} = $1 if `git branch --list` =~ /^\*\s+(.+)$/m;

            $vars->{copy_clean} = !$git->run('status','--porcelain');

            my @ignore = qw(./ .git/);            

            my $dir = $vars->{dir}.'/';

            if (!$vars->{copy_clean}) {
                my @status = $git->run('status','--porcelain','--',$dir);
                $vars->{dir_clean}  = !@status;

# TODO
                @status = $git->run('status','-s','--ignored','--', $dir);
            
#                $dir = '' if $dir eq './';
#                my %ignored = map { $_ => 1 } map {
#                    my $l = length($dir);
#                    substr($_,$l);# if substr($_,0,$l) eq "!! $dir";
#                } @status;

                $vars->{status} = \@status;
            }
            
            my %ignored = map {$_=>1} @ignore;
            $vars->{files} = [
                grep { !$ignored{ $_->{name} } } @{ $vars->{files} }
            ];

            $vars->{ignored} = \@ignore;
        }
    );
};
