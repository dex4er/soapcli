#!/usr/bin/perl

use 5.006;

use strict;
use warnings;

use MyModuleBuild;

my $module = 'App::soapcli';

(my $dist = $module) =~ s/::/-/g;

my $build = MyModuleBuild->new(
    module_name             => $module,
    dist_version_from       => 'script/soapcli.pl',
    license                 => 'perl',
    requires                => {
        'perl'                  => 5.006,
        'constant::boolean'     => 0,
        'File::Slurp'           => 0,
        'Getopt::Long::Descriptive' => 0,
        'HTTP::Tiny'            => 0,
        'JSON::PP'              => 0,
        'XML::Compile::SOAP'    => 0,
        'YAML::Syck'            => 0,
    },
    build_requires          => {
        'App::FatPacker'        => 0,
        'Test::More'            => 0,
    },
    script_files => [
        'script/soapcli.pl',
    ],
    auto_configure_requires => 0,
    create_makefile_pl      => 'traditional',
    create_readme           => 1,
    create_license          => 1,
    recursive_test_files    => 0,
    add_to_cleanup          => [
        '*.bak', '*.gz', '*.tgz', '*.ppd', '*.ppmx', '*.deb', '*.bat',
        'Makefile', 'pm_to_blib', 'cover_db', 'Debian_CPANTS.txt',
        "$dist-*",
    ],
    meta_merge              => {
        resources               => {
            bugtracker => "http://rt.cpan.org/NoAuth/Bugs.html?Dist=$dist",
            repository => "http://github.com/dex4er/soapcli",
        },
    },
);

$build->create_build_script;

