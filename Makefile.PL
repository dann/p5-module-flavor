use inc::Module::Install;
name 'Module-Flavor';
all_from 'lib/Module/Flavor.pm';

tests 't/*.t';
requires(
    'Carp'                      => 0,
    'Cwd'                       => 0,
    'Text::Xslate'              => 0,
    'Getopt::Long'              => 0,
    'Pod::Usage'                => 0,
    'Exporter'                  => 0,
    'Scalar::Util'              => 0,
    'YAML'                      => 0,
    'File::Spec'                => 0,
    'File::Basename'            => 0,
);
test_requires( 'Test::More' => 0.88, );

auto_set_repository;
auto_include;

install_script('bin/module-flavor');

WriteAll;

