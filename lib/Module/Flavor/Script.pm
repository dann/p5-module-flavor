package Module::Flavor::Script;
use strict;
use warnings;
use Carp ();
use Getopt::Long;
use Pod::Usage;
use Module::Flavor;

sub run {
    usage() unless @ARGV;
    my $options = setup_options();
    my $module_flavor = Module::Flavor->new(%$options);
    my $module = $ARGV[0];
    $module_flavor->generate($module);
}

sub usage {
    pod2usage(1);
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

=head1 NAME

module-flavor - create a module skeleton

=head1 SYNOPSIS

module-flavor [options] module_name

  Examples:
    module-flavor MyApp::Simple

    module-flavor --flavor Catalyst MyApp::Simple

=cut

