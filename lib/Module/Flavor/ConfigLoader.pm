package Module::Flavor::ConfigLoader;
use strict;
use warnings;
use Config::Tiny;
use File::Spec;
use File::Path;

sub new {
    my ( $class ) = @_;
    my $self = bless {}, $class;
    $self;
}

sub load_config {
    my ( $self, $options ) = @_;
    my $option_plugins = delete $options->{plugins} || [];
    my $config = $self->load_config_file($options);
    $config = +{ %{ $config->{config} || {} }, %{$options}, };
    $config->{plugins} ||= [];
    my @enabled_plugins = split ',', $config->{plugins}
        if $config->{plugins};
    $config->{plugins} = \@enabled_plugins if @enabled_plugins;
    push @{ $config->{plugins} }, @$option_plugins;
    my @plugins
        = map { $self->resolve_plugin_name($_); } @{ $config->{plugins} };
    $config->{plugins} = \@plugins;
    $self->{config}    = $config;
    $config;
}

sub load_config_file {
    my ( $self, $options ) = @_;
    my $default_config_path = $self->_create_default_config_if_neccessary;
    my $config_file_path    = $options->{config} || $default_config_path;
    my $config              = Config::Tiny->read($config_file_path);
    $config;
}

sub _create_default_config_if_neccessary {
    my $self = shift;
    my $default_config_path
        = File::Spec->catfile( $ENV{HOME}, '.module-flavor', 'config.ini' );
    unless ( -e $default_config_path ) {
        print "Creating default config to $default_config_path\n";
        File::Path::mkpath(
            File::Spec->catfile( $ENV{HOME}, '.module-flavor' ),
            1, 0777 );
        open my $out, ">", $default_config_path
            or die "$default_config_path: $!";
        print $out "[config]\n";
        print $out "# Comma Separated list of plugins to enable\n";
        print $out "# plugins=TestMakefile,Git\n";
        print $out "plugins=TestMakefile\n";
        print $out "author=your name\n";
        print $out "email=your email\n";
        close $out;
    }
    $default_config_path;
}

sub resolve_plugin_name {
    my ( $self, $plugin ) = @_;
    if ( $plugin =~ /^\+(.*)/ ) {
        $plugin = $1;
    }
    else {
        $plugin = "Module::Flavor::Plugin::${plugin}";
    }
    $plugin;
}

1;
__END__
