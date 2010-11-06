package Module::Flavor::Plugin::TestMakefile;

sub install {
    my ( $class, $pkg, $config ) = @_;
    $pkg->add_trigger(
        finalize => sub {
            !system "perl Makefile.PL" or die $?;
            !system 'make test'        or die $?;
            !system 'make manifest'    or die $?;
            !system 'make distclean'   or die $?;
        }
    );
}

1;