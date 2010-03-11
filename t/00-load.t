#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Bio::Stream' );
}

diag( "Testing Bio::Stream $Bio::Stream::VERSION, Perl $], $^X" );
