use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Bio::Stream',
    license             => 'perl',
    dist_author         => q{Chris Fields <cjfields@bioperl.org>},
    dist_version_from   => 'lib/Bio/Stream.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Bio-Stream-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
