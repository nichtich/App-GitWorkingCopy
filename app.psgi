use Plack::Builder;
use App::GitWorkingCopy;

my $debug = $ENV{PLACK_ENV} eq 'development';

builder {
    enable_if { $debug } 'Debug';
    enable_if { $debug } 'Debug::TemplateToolkit';
    App::GitWorkingCopy->new();
};
