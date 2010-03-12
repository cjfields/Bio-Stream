#!perl -T

use Test::More tests => 2;

BEGIN {
    use_ok( 'Bio::Stream' );
    use_ok( 'Bio::Stream::IO' );
}

#diag( "Testing Bio::Stream $Bio::Stream::VERSION, Perl $], $^X" );
