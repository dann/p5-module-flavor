package Module::Flavor::PluginLoader;
use strict;
use warnings;

sub new {
    my ($class) = @_;
    my $self = bless {}, $class;
    $self;
}

sub load_plugins {
    my ( $self, $context, $config ) = @_;
    my $plugins = $config->{plugins};
    for my $plugin (@$plugins) {
        $self->load_plugin( $context, $plugin, $config->{$plugin} );
    }
}

sub load_plugin {
    my ( $self, $context, $plugin, $plugin_config ) = @_;
    my $module = Module::Flavor::Util::load_class($plugin);
    $module->install( $context, $plugin_config || {} );
}

1;
