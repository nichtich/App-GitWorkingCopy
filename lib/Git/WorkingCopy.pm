package Git::WorkingCopy;

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

=head1 SEE ALSO

L<Plack::App::Directory::Template>,
L<Git::Repository>, 
L<Plack::Middleware::GitStatus>,
L<Plack::Middleware::GitRevisionInfo>

=cut

1;

__DATA__
<!-- TODO: put in share dir -->
<html>
<head>
</head>
<body>
<p>origin: [% origin %]</p>
## [% branch %]
<table>
[% FOR file in FILES %]
<tr>
  <td class='status'>[% file.status.status %]</td>
  <td class='left'><a href='[% file.url | html %]'>[% file.name | html %]</a></td>
  <td class='left'>[% file.commit.message | html %]</td>
  <td class='right'>[% date.format( file.stat.mtime  ) %]</td>
  <td class='right'>[% file.stat.size %]</td>
</tr>
[% END %]
</table>
</body>
</html>
