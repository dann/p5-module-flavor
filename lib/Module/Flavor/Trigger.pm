package Module::Flavor::Trigger;
use strict;
use warnings;
use base qw/Exporter/;
use Scalar::Util ();

our @EXPORT = qw/add_trigger call_trigger get_trigger_code/;

# taken from Amon2::Trigger. thanks!

sub add_trigger {
    my ( $class, %args ) = @_;
    while ( my ( $hook, $code ) = each %args ) {
        push @{ $class->{_trigger}->{$hook} }, $code;
    }
}

sub call_trigger {
    my ( $class, $hook, @args ) = @_;
    my @code = $class->get_trigger_code($hook);
    for my $code (@code) {
        $code->( $class, @args );
    }
}

sub get_trigger_code {
    my ( $class, $hook ) = @_;
    my @code;
    if ( Scalar::Util::blessed($class) ) {
        push @code, @{ $class->{_trigger}->{$hook} || [] };
    }
    return @code;
}

1;
