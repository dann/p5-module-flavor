package Module::Flavor::Plugin;
use strict;

sub install {
    my( $class, $context, $config) = @_;
    die 'Abstract method! Overide it!';
}

1;
