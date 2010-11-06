sub readme_from {
    warn
        "You need to install Module::Install::ReadmeFromPod to generate README";
}

sub use_test_base {
    warn "You need to install Test::Base to run make test from git clone";
}

sub author_requires {
    warn
        "You need to install Module::Install::AuthorRequires to install modules author requires";
}
sub author_tests        { }
sub auto_set_repository { }

use inc::Module::Install;

{
    no warnings 'redefine';
    *recommends_hack
        = $Module::Install::VERSION > 0.70
        ? sub { recommends(@_); $_[0] }
        : \&recommends;
}

name 'Module-Flavor';
all_from 'lib/Module/Flavor.pm';

requires(

);
test_requires(
    'Test::More'                   => 0.88,
    'Test::LoadAllModules'         => 0.02,
);
use_test_base;
auto_include;
WriteAll;
