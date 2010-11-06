package Module::Flavor;
use strict;
use warnings;
use Cwd;
use Text::Xslate;
use Module::Flavor::Trigger; 
use Module::Pluggable::Object;
use Module::Flavor::Util;
use Module::Flavor::Template;

our $VERSION = '0.01';

sub new {
    my ( $class, %args ) = @_;
    my $self = bless {%args}, $class;
    $self->{basedir} = Cwd::getcwd unless $args{basedir};
    $self->{flavor_class} = $self->_flavor_class( $args{flavor} );

    $self->{__root_dir} = Cwd::getcwd;
    $self->{__renderer} = $self->_create_renderer();
    $self;
}

sub generate {
    my ( $self, $module ) = @_;

    $self->call_trigger('init');
    my $config = $self->load_config;
    $self->create_dist_dir($module);
    my $opts = $self->create_and_set_opts( $module, $config );
    $self->load_plugins;

    $self->call_trigger('before_create_skeleton');
    $self->create_skeleton( $self->{flavor_class}, $opts );
    $self->call_trigger('after_create_skeleton');

    chdir File::Spec->catfile($self->{__root_dir}, $opts->{dist});
    $self->call_trigger('finalize');
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
    return "Module::Flavor::Template::Default" unless $flavor_name;

    if ( $flavor_name =~ m/^\+(\w)/ ) {
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
    mkdir $dist, 0777;
    chdir $dist;
}

sub load_config {
    # TODO Implement me!
    return +{};
}

sub load_plugins {
    my ( $self, $config ) = @_;
    my $plugins = $self->_collect_plugins();
    for my $plugin (@$plugins) {
        $self->load_plugin( $plugin, $config->{$plugin} );
    }
}

sub _collect_plugins {
    my $locator = Module::Pluggable::Object->new(
        search_path => ['Module::Flavor::Plugin'], );
    my @plugins = sort { length $a <=> length $b } $locator->plugins;
    \@plugins;
}

sub load_plugin {
    my ( $self, $plugin, $plugin_config ) = @_;
    my $module = Module::Flavor::Util::load_class($plugin);
    $module->install( $self, $plugin_config );
}

sub create_skeleton {
    my ( $self, $flavor_class, $opts ) = @_;
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
