#!perl

use strict;
use warnings;
BEGIN {
    use Bio::Root::Test;
    use_ok('Bio::Stream::IO');
}

use Bio::Root::IO;

{

    my $io = Bio::Root::IO->new(-file => test_input_file('AnnIX-v003.gbk'));
    
    my $line = $io->_readline;
    
    like($line, qr/^LOCUS/);
    
    my $stream = Bio::Stream::IO->new(-file => test_input_file('AnnIX-v003.gbk'));
    
    # file markers
    is($stream->tell('start'), 0);
    is($stream->tell('current'), 0);

    $line = $stream->_readline;
    like($line, qr/^LOCUS/);
    
    # current marker should move
    cmp_ok($stream->tell('current'), '>', 0);
}

# passing IO from one stream to another, each stream maintaining a file pointer
{
    my $str1 = Bio::Stream::IO->new(-file => test_input_file('AnnIX-v003.gbk'));
    
    is($str1->tell('start'), 0, 'at beginning');
    
    my $line = $str1->_readline;
    like($line, qr/^LOCUS/);
    
    my $str2 = $str1->spawn_stream();
    is($str2->tell('start'), $str1->tell('current'), 'new stream starts where last stream left off');

    $line = $str2->_readline;
    like($line, qr/^DEFINITION/);
    $str2->_pushback($line);
    
    my $str3 = $str2->spawn_stream();
    $line = $str3->_readline;
    like($line, qr/^DEFINITION/);

    $line = $str1->_readline;
    like($line, qr/^DEFINITION/, 'streams are independent from one another');
    
    # this should 
    $line = $str2->_readline;
    like($line, qr/^DEFINITION/,'retains independent buffer, recalls _pushback data');
    
    $line = $str2->_readline;
    like($line, qr/^ACCESSION/, 'streams are independent');
    
    $line = $str3->_readline;
    like($line, qr/^ACCESSION/, 'streams are independent');
}

# check that filehandle is being closed only when parent stream is destroyed
my $parent_fh;
my $child_fh;
{
    my $str1;

    {
        $str1 = Bio::Stream::IO->new(-file => test_input_file('AnnIX-v003.gbk'));;
        my $str2 = Bio::Stream::IO->new(-stream => $str1);
        $child_fh = $str2->_fh;
    }
    ok(fileno $child_fh);
    $parent_fh = $str1->_fh;
    ok(fileno $parent_fh);
}
is($child_fh, $parent_fh); # same reference
ok(!fileno $parent_fh);

done_testing();
