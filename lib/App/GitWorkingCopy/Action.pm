package App::GitWorkingCopy::Action;

use strict;
use warnings;

use parent 'Plack::Middleware';

sub call {
    my ($self, $env) = @_;
    my $req = Plack::Request->new($env);
    
    return $self->app->($env) unless $req->param('action');
               
    # do processing, optionally add to tt.vars

# TODO
    #my $logfile = '/tmp/mylog';
    #my $logsep  = '^---*$';
           
    # action=log
#    my $num = 2;
#    my $log = `tac -b -r -s $logsep $logfile | awk '/$logsep/{c++}c>$num{exit}{print}`;

#    [200,['Content-Type' => 'text/plain'], $log];
#	$env->{'tt.vars'}->{'log'} = "...";

    return $self->app->($env);
}

1;

=encoding utf8

__END__
* action=reset
  Reset local changes
    * clean index and working tree
        git reset --hard
    * Remove untracked or ignored local files and directories
        git clean -xdf

* action=update
  Pull from origin (first reset):
    git pull

* action=rollback&file=...
  Checkout previous version of a file
    git checkout HEAD^ -- file

* action=delete&file=...
* action=modify&file=... # modify or add new file (edit)

* action=rollback
  Checkout previous commit
    git checkout HEAD^      # detached state
    git reset --soft master # back to master
