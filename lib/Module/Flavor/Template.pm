package Module::Flavor::Template;
use warnings;
use Text::Xslate;
use YAML;
use File::Spec;
use File::Basename ();
use ExtUtils::MakeMaker qw(prompt);

sub new {
    my ( $class, %args ) = @_;
    my $self = bless {%args}, $class;
    $self->{renderer} = _create_renderer();
    $self;
}

sub _create_renderer {
    Text::Xslate->new( syntax => 'TTerse', );
}

sub render {
    my ( $self, $flavor_class, $opts ) = @_;
    my $templates = $self->_get_flavor($flavor_class);
    foreach my $template (@$templates) {
        unless ( $template->{skip_expand} ) {
            $template->{template}
                = $self->_render( $template->{template}, $opts );
        }
        $self->_write_to_file( $template, $opts );
    }
}

sub _get_flavor {
    my ( $self, $package ) = @_;
    Module::Flavor::Util::load_class($package);
    my $flavors_datasection = $self->_get_data_section($package);

    no strict 'refs';
    my @templates = YAML::Load($flavors_datasection);
    \@templates;
}

sub _render {
    my ( $self, $template, $params ) = @_;
    my $body = $self->{renderer}->render_string( $template, $params );
    $body;
}

sub _write_to_file {
    my ( $self, $skelton, $opts ) = @_;

    my $file = $skelton->{file};
    my $module_path = $opts->{path};
    $file =~ s/\$path/$module_path/g; 

    my $path = File::Spec->catfile( $opts->{basedir}, $opts->{dist},
        $file );
    if ( -e $path ) {
        my $ans = prompt( "$path exists. Override? [yN] ", 'n' );
        return if $ans !~ /[Yy]/;
    }

    my $dir = File::Basename::dirname($path);
    unless ( -e $dir ) {
        warn "Creating directory $dir\n";
        File::Path::mkpath( $dir, 1, 0777 );
    }

    my $template = $skelton->{template};

    warn "Creating $path\n";
    open my $out, ">", $path or die "$path: $!";
    print $out $template;
    close $out;

    chmod oct( $skelton->{chmod} ), $path if $skelton->{chmod};
}

sub _get_data_section {
    my ( $self, $package ) = @_;
    my $d = do { no strict 'refs'; \*{ $package . "::DATA" } };
    return unless defined fileno $d;
    seek $d, 0, 0;
    my $content = join '', <$d>;
    $content =~ s/^.*\n__DATA__\n/\n/s;    # for win32
    $content =~ s/\n__END__\n.*$/\n/s;
    $content;
}

1;
