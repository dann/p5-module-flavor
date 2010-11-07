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
name 'Module-Flavor';
all_from 'lib/Module/Flavor.pm';

tests 't/*.t';

requires(
    'Carp'                      => 0,
    'Cwd'                       => 0,
    'Config::Tiny'              => 0,
    'Text::Xslate'              => 0,
    'Getopt::Long'              => 0,
    'Pod::Usage'                => 0,
    'Exporter'                  => 0,
    'Scalar::Util'              => 0,
    'YAML'                      => 0,
    'File::Spec'                => 0,
    'File::Basename'            => 0,
    'File::Path'                => 0,
    'ExtUtils::MakeMaker'       => 0,
);
test_requires( 'Test::More' => 0.88, );

auto_set_repository;
auto_include;

install_script('bin/module-flavor');

WriteAll;

