#!perl

use Bio::Root::Test;
use File::Spec;

plan skip_all => "MANIFEST doesn't exist" if ! -e 'MANIFEST';
# pull in modules from MANIFEST here
open (my $MANIFEST, '<', 'MANIFEST') || die "Can't open file: $!";
my @modules = map {
        chomp;
        s{^lib[\\\/]([\\\/\w]+)\.pm$}{$1};
        s{[\\\/]}{::}g;
        $_;
    } grep { /\.pm$/ } <$MANIFEST>;
close $MANIFEST;
    
for (@modules) {
    use_ok( $_, "$_ tested" );
}

done_testing();

#diag( "Testing Bio::Stream $Bio::Stream::VERSION, Perl $], $^X" );
