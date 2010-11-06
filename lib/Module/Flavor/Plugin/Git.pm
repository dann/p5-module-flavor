package Module::Flavor::Plugin::Git;
use strict;
use warnings;
use base 'Module::Flavor::Plugin';

sub install {
    my ( $class, $pkg, $config ) = @_;
    $pkg->add_trigger(
        finalize => sub {
            !system 'git init'                       or die $?;
            !system 'git add *.*'                    or die $?;
            !system 'git add README'                 or die $?;
            !system 'git add Changes'                or die $?;
            !system 'git add .gitignore'             or die $?;
            !system 'git add .shipit'                or die $?;
            !system 'git add lib'                    or die $?;
            !system 'git add t'                      or die $?;
            !system 'git add xt'                     or die $?;
            !system 'git commit -m "initial commit"' or die $?;
        }
    );
}

1;
