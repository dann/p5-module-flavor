package Module::Flavor::Script;
use strict;
use warnings;
use Carp ();
use Getopt::Long;
use Pod::Usage;
use Module::Flavor;

sub run {
    pod2usage(2) unless @ARGV;
    my $options       = setup_options();
    my $module_flavor = Module::Flavor->new( options => $options );
    my $module        = $ARGV[0];
    $module_flavor->generate($module);
}

sub setup_options {
    my $options = {};
    GetOptions(
        'flavor=s'  => \( $options->{flavor} ),
        'plugins=s' => \( $options->{plugins} ),
    );
    my @plugins = split ',', $options->{plugins};
    $options->{plugins} = \@plugins;
    $options;
}

1;

__END__
