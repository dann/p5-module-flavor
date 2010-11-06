use inc::Module::Install;
name 'Module-Flavor';
all_from 'lib/Module/Flavor.pm';

tests 't/*.t';
requires(
    'Carp'                      => 0,
    'Cwd'                       => 0,
    'Text::Xslate'              => 0,
    'Class::Trigger'            => 0,
    'Module::Pluggable::Object' => 0,
    'Getopt::Long'              => 0,
    'Pod::Usage'                => 0,
);
test_requires( 'Test::More' => 0.88, );

auto_set_repository;
auto_include;
WriteAll;
