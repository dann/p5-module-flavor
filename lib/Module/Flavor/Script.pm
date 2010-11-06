package Module::Flavor::Script;
use strict;
use warnings;
use Carp ();
use Getopt::Long;
use Pod::Usage;
use Module::Flavor;

sub run {
    pod2usage(2) unless @ARGV;
    my $options = setup_options();
    my $module_flavor = Module::Flavor->new(%$options);
    my $module = $ARGV[0];
    $module_flavor->generate($module);
}

sub setup_options {
    my $options = {};
    GetOptions(
        'flavor=s' => \( $options->{flavor} ),
        'test'     => \( $options->{test} ),
    );
    $options;
}

1;

__END__