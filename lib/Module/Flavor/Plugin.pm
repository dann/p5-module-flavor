package Module::Flavor::Plugin;
use strict;

sub install {
    my( $class, $pkg, $config) = @_;
    die 'Abstract method! Overide it!';
}

1;
