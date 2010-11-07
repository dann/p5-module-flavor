package Module::Flavor::Plugin::TestMakefile;
use strict;
use warnings;
use base 'Module::Flavor::Plugin';

sub install {
    my ( $class, $context, $config ) = @_;
    $context->add_trigger(
        after_create_skeleton => sub {
            !system "perl Makefile.PL" or die $?;
            !system 'make test'        or die $?;
            !system 'make manifest'    or die $?;
            !system 'make distclean'   or die $?;
        }
    );
}

1;
