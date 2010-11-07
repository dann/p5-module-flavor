package Module::Flavor;
use strict;
use warnings;
use Carp ();
use Cwd;
use Text::Xslate;
use Module::Flavor::Trigger;
use Module::Flavor::Util;
use Module::Flavor::Template;
use File::Path;
use File::Spec;
use Config::Tiny;

our $VERSION = '0.01';

sub new {
    my ( $class, %args ) = @_;
    my $self = bless {%args}, $class;
    $self->{options} = +{}         unless $args{options};
    $self->{basedir} = Cwd::getcwd unless $self->{options}->{basedir};
    $self->{flavor_class}
        = $self->_flavor_class( $self->{options}->{flavor} );

    $self->{__renderer} = $self->_create_renderer();
    $self;
}

sub generate {
    my ( $self, $module ) = @_;
    my $config = $self->load_config( $self->{options} );
    $self->create_dist_dir($module);
    my $opts = $self->create_and_set_opts( $module, $config );
    $self->load_plugins($config);
    $self->call_trigger('init');

    $self->change_to_dist_dir($opts);
    $self->call_trigger('before_create_skeleton');
    $self->create_skeleton( $self->{flavor_class}, $opts );
    $self->call_trigger('after_create_skeleton');

    $self->change_to_basedir();
    $self->call_trigger('finalize');
}

sub change_to_dist_dir {
    my ( $self, $opts ) = @_;
    chdir File::Spec->catfile( $self->{basedir}, $opts->{dist} );
}

sub change_to_basedir {
    my $self = shift;
    chdir File::Spec->catfile( $self->{basedir} );
}

sub create_and_set_opts {
    my ( $self, $module, $config ) = @_;

    # $module = "Foo::Bar"
    # $dist   = "Foo-Bar"
    # $path   = "Foo/Bar.pm"
    my @pkg = split /::/, $module;
    my $dist = join "-", @pkg;
    my $path = join( "/", @pkg ) . ".pm";

    my $opts = {
        module    => $module,
        dist      => $dist,
        path      => $path,
        config    => $config,
        localtime => scalar localtime,
        basedir   => $self->{basedir},
    };
}

sub _flavor_class {
    my ( $self, $flavor_name ) = @_;
    return "Module::Flavor::Template::Module" unless $flavor_name;

    if ( $flavor_name =~ /^\+(.*)/ ) {
        return $1;
    }
    else {
        return "Module::Flavor::Template::${flavor_name}";
    }
}

sub create_dist_dir {
    my ( $self, $module ) = @_;
    my @pkg = split /::/, $module;
    my $dist = join "-", @pkg;
    File::Path::mkpath( File::Spec->catfile( $self->{basedir}, $dist ),
        1, 0777 );
}

sub load_config {
    my ( $self, $options ) = @_;
    my $option_plugins = delete $options->{plugins} || [];
    my $config = $self->load_config_file($options);
    $config = +{ %{$config}, %{$options}, };
    $config->{plugins} ||= [];
    my @enabled_plugins = split ',', $config->{plugins}->{enable}
        if $config->{plugins}->{enable};
    $config->{plugins} = \@enabled_plugins;
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
        warn "Creating default config to $default_config_path";
        File::Path::mkpath(
            File::Spec->catfile( $ENV{HOME}, '.module-flavor' ),
            1, 0777 );
        open my $out, ">", $default_config_path
            or die "$default_config_path: $!";
        print $out "[plugins]\nenable=TestMakefile,Git\n";
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

sub load_plugins {
    my ( $self, $config ) = @_;
    my $plugins = $config->{plugins};
    for my $plugin (@$plugins) {
        $self->load_plugin( $plugin, $config->{$plugin} );
    }
}

sub load_plugin {
    my ( $self, $plugin, $plugin_config ) = @_;
    my $module = Module::Flavor::Util::load_class($plugin);
    $module->install( $self, $plugin_config || {} );
}

sub create_skeleton {
    my ( $self, $flavor_class, $opts ) = @_;
    $opts->{config}
        = +{ %{ $opts->{config} || {} }, %{ $self->{config} || {} } };
    $self->{__renderer}->render( $flavor_class, $opts );
}

sub _create_renderer {
    Module::Flavor::Template->new;
}

1;

__END__

=encoding utf-8

=head1 NAME

Module::Flavor - createa module skeleton

=head1 SYNOPSIS

  use Module::Flavor;

=head1 DESCRIPTION

Module::Flavor is 

=head1 SOURCE AVAILABILITY

This source is in Github:

  http://github.com/dann/

=head1 CONTRIBUTORS

Many thanks to:


=head1 AUTHOR

dann E<lt>techmemo@gmail.comE<gt>

=head1 SEE ALSO

L<Module::Setup>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
