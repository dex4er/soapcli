package MyModuleBuild;
use base 'Module::Build';

use File::Spec;

# Remove *.pl suffix from scripts' filenames
sub copy_if_modified {
    my $self = shift;
    my %args = (@_ > 3 ? ( @_ ) : ( from => shift, to_dir => shift, flatten => shift ) );
    if ($args{from} =~ /\.pl$/ and $args{to_dir}) {
        my (undef, undef, $file) = File::Spec->splitpath($args{from});
        $file =~ s/\.pl$//;
        $args{to} = File::Spec->catfile($args{to_dir}, $file);
        delete $args{to_dir};
    };
    $self->SUPER::copy_if_modified(%args);
}

1;
