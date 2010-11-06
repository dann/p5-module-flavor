package Module::Flavor::Util;
use strict;
use Carp ();

sub load_class {
    my ( $class, $prefix ) = @_;

    if ($prefix) {
        unless ( $class =~ s/^\+// || $class =~ /^$prefix/ ) {
            $class = "$prefix\::$class";
        }
    }

    my $file = $class;
    $file =~ s!::!/!g;
    require "$file.pm";    ## no critic

    return $class;
}

1;
