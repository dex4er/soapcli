package MyModuleBuild;

use base 'Module::Build';

use File::Spec;

# Use FatPacker to replace *.pl file with fatpacked script

sub process_script_files {
    my $self = shift;

    local *copy_if_modified = sub {
        my $self = shift;
        my %args = (@_ > 3 ? ( @_ ) : ( from => shift, to_dir => shift, flatten => shift ) );
        # Only for script/*.pl files
        if ($args{from} =~ /\bscript\/.*\.pl$/ and $args{to_dir}) {
            my (undef, undef, $file) = File::Spec->splitpath($args{from});
            $file =~ s/\.pl$//;
            $args{to} = File::Spec->catfile($args{to_dir}, $file);
            delete $args{to_dir};
            no warnings 'redefine';
            local *File::Copy::copy = sub {
                my ($file, $dest) = @_;
                open my $in,  "<", $file or die $!;
                open my $out, ">", $dest or die $!;
                local @ARGV = qw(file);
                while (<$in>) {
                    s/^__(?:END)__$/scalar(`$^X -e "use App::FatPacker -run_script" file`)/e;
                    print $out $_;
                };
                return 1;
            };
            return $self->SUPER::copy_if_modified(%args);
        };
        return $self->SUPER::copy_if_modified(%args);
    };

    $self->SUPER::process_script_files;
};

1;
