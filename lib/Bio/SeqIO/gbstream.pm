package Bio::SeqIO::gbstream;
use strict;
use warnings;
use Data::Dumper;
use Bio::Seq::Lazy;
#use Bio::SeqIO::Handler::GenericRichSeqHandler;
#use Bio::Seq::SeqFactory;

use base qw(Bio::Stream::IO Bio::SeqIO);

# map all annotation keys to consistent INSDC-based tags for all handlers

my %FTQUAL_NO_QUOTE = map {$_ => 1} qw(
    anticodon           citation
    codon               codon_start
    cons_splice         direction
    evidence            label
    mod_base            number
    rpt_type            rpt_unit
    transl_except       transl_table
    usedin
    );


# 1) change this to indicate what should be secondary, not primary, which allows
# unknown or new stuff to be passed to handler automatically; current behavior
# appends unknowns to previous data, which isn't good since it's subtly passing
# by important data
# 2) add mapping details about how to separate data using specific delimiters


# Features are the only ones postprocessed for now
# Uncomment relevant code in next_seq and add keys as needed...
my %POSTPROCESS_DATA = map {$_ => 1} qw (FEATURES);

sub _initialize {
    my($self,@args) = @_;

    $self->SUPER::_initialize(@args);
    
    #my $handler = $self->_rearrange([qw(HANDLER)],@args);
    # hash for functions for decoding keys.
    #$handler ? $self->seqhandler($handler) :
    #$self->seqhandler(Bio::SeqIO::Handler::LazyHandler->new(
    #                -format => 'genbank',
    #                -verbose => $self->verbose,
    #                -builder => $self->sequence_builder
    #                ));
    #if( ! defined $self->sequence_factory ) {
    #    $self->sequence_factory(Bio::Seq::SeqFactory->new
    #            (-verbose => $self->verbose(),
    #             -type => 'Bio::Seq::RichSeq'));
    #}
}

=head2 next_seq

 Title   : next_seq
 Usage   : $seq = $stream->next_seq()
 Function: returns the next sequence in the stream
 Returns : Bio::Seq object
 Args    :

=cut

# at this point there is minimal sequence validation,
# but the parser seems to hold up nicely so far...

my %STREAM_START = (
    LOCUS       => 'annotation',
    FEATURES    => 'features',
    ORIGIN      => 'sequence',
    '//'        => 'end'
);

my %STREAM_PARSER = (
    'annotation'    => sub {
        my $stream = shift;
        my $data;
        while (my $line = $stream->_readline) {
            if ($line =~ /^(\s{0,3})(\w+)\s+(.*)$}/ox) {
                
            }
        }
    },
);

# these are the stream-specific subs that pull out data into discrete bits
# and 

sub next_seq {
    my $self = shift;
    local($/) = "\n";
    my $seenlocus;
    my $seq;
    my $stream;
    my $prior_stream;
    my $fh = $self->_fh;
    PARSER:
    while (defined(my $line = $self->_readline)) {
        next if $line =~ m{^\s*$};
        if ($line =~ m{^(LOCUS|FEATURES|ORIGIN|//)\s+}ox) {
            my $ann = $1;
            unless ($seenlocus) {
                $self->throw("No LOCUS found.  Not GenBank in my book!")
                    if ($ann ne 'LOCUS');
                $seenlocus = 1;
            }
            $seq ||= Bio::Seq::Lazy->new();
            $stream = $STREAM_START{$ann};
        } else {
            next;
        }
        $self->throw("Stream type not defined") if !defined $stream;

        #local $/ = $mode eq 'sequence' ? "\n//" : "\n";
        
        # if we get here, we start a new stream based on the mode
        # trick here is, do we want to hand this off to the handler, or
        # do within the sequence object?  For now just pass in the streams to
        # the sequence object, work it out from there
        if ($stream ne 'end') {
            my $pos = tell($fh) - length($line);
            $seq->stream($stream,
                         $self->spawn_stream('start' => $pos,
                                             'current' => $pos));
            $seq->stream($prior_stream)->_set_marker_pos('end', $pos) if $prior_stream;
        } else {
            last PARSER;
        }
        $prior_stream = $stream;
    }
    # fencepost
    $seq->stream($prior_stream)->_set_marker_pos('end', tell($fh)) if $seq;
    return $seq;
}

=head2 write_seq

 Title   : write_seq
 Usage   : $stream->write_seq($seq)
 Function: writes the $seq object (must be seq) to the stream
 Returns : 1 for success and 0 for error
 Args    : array of 1 to n Bio::SeqI objects

=cut

sub write_seq {
    shift->throw("Use Bio::SeqIO::genbank for output");
    # maybe make a Writer class as well????
}

package Bio::SeqIO::gbstream::annotation;

use base qw(Bio::Stream::IO);

1;

__END__

=head1 NAME

Bio::SeqIO::gbstream - <One-line description of module's purpose>

=head1 VERSION

This documentation refers to Bio::SeqIO::gbstream version Biome.

=head1 SYNOPSIS

   use Bio::SeqIO::gbstream;
   # Brief but working code example(s) here showing the most common usage(s)

   # This section will be as far as many users bother reading,

   # so make it as educational and exemplary as possible.

=head1 DESCRIPTION

<TODO>
A full description of the module and its features.
May include numerous subsections (i.e., =head2, =head3, etc.).

=head1 SUBROUTINES/METHODS

<TODO>
A separate section listing the public components of the module's interface.
These normally consist of either subroutines that may be exported, or methods
that may be called on objects belonging to the classes that the module provides.
Name the section accordingly.

In an object-oriented module, this section should begin with a sentence of the
form "An object of this class represents...", to give the reader a high-level
context to help them understand the methods that are subsequently described.

=head1 DIAGNOSTICS

<TODO>
A list of every error and warning message that the module can generate
(even the ones that will "never happen"), with a full explanation of each
problem, one or more likely causes, and any suggested remedies.

=head1 CONFIGURATION AND ENVIRONMENT

<TODO>
A full explanation of any configuration system(s) used by the module,
including the names and locations of any configuration files, and the
meaning of any environment variables or properties that can be set. These
descriptions must also include details of any configuration language used.

=head1 DEPENDENCIES

<TODO>
A list of all the other modules that this module relies upon, including any
restrictions on versions, and an indication of whether these required modules are
part of the standard Perl distribution, part of the module's distribution,
or must be installed separately.

=head1 INCOMPATIBILITIES

<TODO>
A list of any modules that this module cannot be used in conjunction with.
This may be due to name conflicts in the interface, or competition for
system or program resources, or due to internal limitations of Perl
(for example, many modules that use source code filters are mutually
incompatible).

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.

User feedback is an integral part of the evolution of this and other Biome and
BioPerl modules. Send your comments and suggestions preferably to one of the
BioPerl mailing lists. Your participation is much appreciated.

  bioperl-l@bioperl.org                  - General discussion
  http://bioperl.org/wiki/Mailing_lists  - About the mailing lists

Patches are always welcome.

=head2 Support 
 
Please direct usage questions or support issues to the mailing list:
  
L<bioperl-l@bioperl.org>
  
rather than to the module maintainer directly. Many experienced and reponsive
experts will be able look at the problem and quickly address it. Please include
a thorough description of the problem with code and data examples if at all
possible.

=head2 Reporting Bugs

Preferrably, Biome bug reports should be reported to the GitHub Issues bug
tracking system:

  http://github.com/cjfields/biome/issues

Bugs can also be reported using the BioPerl bug tracking system, submitted via
the web:

  http://bugzilla.open-bio.org/

=head1 EXAMPLES

<TODO>
Many people learn better by example than by explanation, and most learn better
by a combination of the two. Providing a /demo directory stocked with
well-commented examples is an excellent idea, but your users might not have
access to the original distribution, and the demos are unlikely to have been
installed for them. Adding a few illustrative examples in the documentation
itself can greatly increase the "learnability" of your code.

=head1 FREQUENTLY ASKED QUESTIONS

<TODO>
Incorporating a list of correct answers to common questions may seem like extra
work (especially when it comes to maintaining that list), but in many cases it
actually saves time. Frequently asked questions are frequently emailed
questions, and you already have too much email to deal with. If you find
yourself repeatedly answering the same question by email, in a newsgroup, on a
web site, or in person, answer that question in your documentation as well. Not
only is this likely to reduce the number of queries on that topic you
subsequently receive, it also means that anyone who does ask you directly can
simply be directed to read the fine manual.

=head1 COMMON USAGE MISTAKES

<TODO>
This section is really "Frequently Unasked Questions". With just about any kind
of software, people inevitably misunderstand the same concepts and misuse the
same components. By drawing attention to these common errors, explaining the
misconceptions involved, and pointing out the correct alternatives, you can once
again pre-empt a large amount of unproductive correspondence. Perl itself
provides documentation of this kind, in the form of the perltrap manpage.

=head1 SEE ALSO

<TODO>
Often there will be other modules and applications that are possible
alternatives to using your software. Or other documentation that would be of use
to the users of your software. Or a journal article or book that explains the
ideas on which the software is based. Listing those in a "See Also" section
allows people to understand your software better and to find the best solution
for their problem themselves, without asking you directly.

By now you have no doubt detected the ulterior motive for providing more
extensive user manuals and written advice. User documentation is all about not
having to actually talk to users.

=head1 (DISCLAIMER OF) WARRANTY

<TODO>
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=head1 ACKNOWLEDGEMENTS

<TODO>
Acknowledging any help you received in developing and improving your software is
plain good manners. But expressing your appreciation isn't only courteous; it's
also enlightened self-interest. Inevitably people will send you bug reports for
your software. But what you'd much prefer them to send you are bug reports
accompanied by working bug fixes. Publicly thanking those who have already done
that in the past is a great way to remind people that patches are always
welcome.

=head1 AUTHOR

Chris Fields  C<< <cjfields at bioperl dot org> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2010 Chris Fields (cjfields at bioperl dot org). All rights reserved.

followed by whatever licence you wish to release it under.
For Perl code that is often just:

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
