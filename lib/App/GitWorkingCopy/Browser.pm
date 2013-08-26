package App::GitWorkingCopy::Browser;
#ABSTRACT: Browse a local git working copy

use strict;
use warnings;
use parent 'Plack::App::Directory::Template';
use Git::Repository;

sub template_vars {
	my ($self, %vars) = @_;

	my $g = $self->{git} //= Git::Repository->new( work_tree => $self->{root} );

	my $path = $vars{path};

    $vars{copy_clean} = !$g->run('status','--porcelain');
	$vars{origin} = $1 if $g->run('remote','-v') =~ /^origin\s+(.+)\s+\(fetch\)$/m;
    $vars{branch} = $1 if $g->run('branch','--list') =~ /^\*\s+(.+)$/m;

	chomp($vars{origin});
	chomp($vars{branch});

	my $gh = $vars{origin} // '';
	$gh =~ s{\.git$}{};
	$gh =~ s{^git\@(github\.com):([^/]+)/(.+)}{https://$1/$2/$3};

	$vars{gh} = $gh;

	my %status = map { ($_->path2 // $_->path1) => $_ } 
				 $g->status('--ignored','./'.$path);
	
	my $filter = sub {
		my $f = shift;
	    return () if $f->{name} =~ qr{^.(git)?/$};
		return $f if $f->{name} eq '../';

		my $full = substr($path . $f->{name},1);
		$f->{status} = $status{ $full };

		# TODO: get commit on renamed files as well ($full => path1)
		($f->{commit}) = $g->log('-1','--',$full);
#		($f->{status}) = $g->status('--ignored','-uall','--',$file->{name});

	    return $f;
	};

	$vars{files} = [ map { $filter->($_) } @{ $vars{files} } ];

    return \%vars;
}

1;

=head1 SEE ALSO

L<Plack::App::Directory::Template>,
L<Git::Repository>, 
L<Plack::Middleware::GitStatus>,
L<Plack::Middleware::GitRevisionInfo>

=cut

=encoding utf8
