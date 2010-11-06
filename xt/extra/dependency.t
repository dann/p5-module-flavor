use Test::Dependencies
    exclude => [qw/Test::Dependencies Test::Base Test::Perl::Critic Module::Flavor/],
    style   => 'light';
ok_dependencies();
