package Module::Flavor;
use strict;
use warnings;
use Carp ();
use Cwd;
use Text::Xslate;
use File::Path;
use File::Spec;
use Module::Flavor::Trigger;
use Module::Flavor::Util;
use Module::Flavor::Template;
use Module::Flavor::ConfigLoader;
use Module::Flavor::PluginLoader;

our $VERSION = '0.01';

sub new {
    my ( $class, %args ) = @_;
    my $self = bless {%args}, $class;
    $self->{options} = +{}         unless $args{options};
    $self->{basedir} = Cwd::getcwd unless $self->{options}->{basedir};
    $self->{flavor_class}
        = $self->_flavor_class( $self->{options}->{flavor} );

    $self->{__renderer}     = $self->_create_renderer();
    $self->{__configloader} = $self->_create_configloader();
    $self->{__pluginloader} = $self->_create_pluginloader();
    $self;
}

sub _create_configloader {
    Module::Flavor::ConfigLoader->new;
}

sub _create_renderer {
    Module::Flavor::Template->new;
}

sub _create_pluginloader {
    Module::Flavor::PluginLoader->new;
}

sub generate {
    my ( $self, $module ) = @_;
    my $config = $self->load_config( $self->{options} );
    $self->{config} = $config;
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

sub create_skeleton {
    my ( $self, $flavor_class, $opts ) = @_;
    $opts->{config} = +{ %{ $opts->{config} || {} },
        %{ $self->{config}->{config} || {} } };
    $self->{__renderer}->render( $flavor_class, $opts );
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
    return $self->{__configloader}->load_config($options);
}

sub load_plugins {
    my ( $self, $config ) = @_;
    $self->{__pluginloader}->load_plugins( $self, $config );
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
