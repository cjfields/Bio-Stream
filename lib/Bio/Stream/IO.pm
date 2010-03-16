package Bio::Stream::IO;

use strict;
use warnings;
use base qw(Bio::Root::IO Bio::Stream::GenericStreamI);

# TODO: deal with non-seekable streams; do we really care to implement support
# for these (it would be just as easy to push data into a tempfile and run from
# it, though I hate the approach)

sub new {
    my ($caller, @args) = @_;
    # this should only call Bio::Root::Root::new()
    my $self = Bio::Root::Root::new($caller, @args);
    
    my ($io, $markers, $methods) = $self->_rearrange([qw[STREAM MARKERS METHODS]], @args);
    if ($io) {
        $self->_init_from_stream($io, $markers, $methods)
    } else {
        $self->_initialize_io(@args);
        $self->_set_markers(qw(start current));
    }
    
    $self->noclose(1); 
    return $self;
}

sub next_dataset {
    return $_[0]->{next_dataset}->($_[0]);
}

sub pull_dataset {
    shift->throw_not_implemented;
}

sub reset_stream {
    my $self = shift;
    CORE::seek($self->_fh, $self->tell('start'), 0);
    1;
}

sub _init_from_stream {
    my ($self, $io, $markers, $methods) = @_;
    if ($io && ref $io) {
        $self->throw("Must use a Bio::Root::IO")
            unless $io->isa('Bio::Root::IO');
        
        # this is pretty naive ATM, should change to be more generic
        my $fh = $io->_fh;
        $self->_initialize_io(-fh => $io->_fh);
        if ($markers && ref $markers eq 'HASH') {
            for my $key (keys %$markers) {
                $self->_set_marker_pos($key, $markers->{$key});
            }
        } else {
            # implicitly set markers to wherever the file marker is now...
            $self->_set_markers(qw(start current));
        }
        if ($methods && ref $methods eq 'HASH') {
            
            #only two methods are allowed, next_dataset && pull_dataset
            for my $sub (qw(next_dataset pull_dataset)) {
                next if !exists $methods->{$sub} || ref($methods->{$sub}) ne 'CODE';
                $self->{$sub} = $methods->{$sub};
            }
        }
        # carry over any buffers
        $self->_buffer($io->{_readbuffer});
        $self->parent_stream($io);
    } else {
        $self->throw("_init_from_io() requires a Bio::Root::IO");
    }
}

sub _buffer {
    my ($self, $buffer) = @_;
    if ($buffer && ref $buffer eq 'ARRAY') {
        @{$self->{_readbuffer}} = @$buffer;
    }
    return $self->{_readbuffer}
}

# TODO: rename as pos(), as this isn't the same as tell(), so confusing
sub tell {
    my ($self, $type) = @_;
    return unless $type;
    $self->{_pos}->{$type};
}

# TODO: rename to something non-CORE (stream_seek maybe)
sub seek {
    my ($self, $type) = @_;
    return unless $type;
    CORE::seek($self->_fh, $self->tell($type), 0);
}

sub _set_markers {
    my ($self, @types) = @_;
    return unless @types;
    my $pos = CORE::tell($self->_fh);
    for my $type (@types) {
        next unless $type;
        $self->{_pos}->{$type} = $pos;
    }
}

sub _set_marker_pos {
    my ($self, $type, $pos) = @_;
    return unless $type && defined $pos;
    $self->{_pos}->{$type} = $pos;
}

sub _readline {
    my $self = shift;
    my ($current, $end) = ($self->tell('current'), $self->tell('end'));
    return if defined $end && $current >= $end; # end of the stream
    $self->seek('current') if CORE::tell($self->_fh) != $current;
    my $line = $self->SUPER::_readline(@_);
    $self->_set_markers('current');
    $line;
}

sub _read_from_start {
    my $self = shift;
    my ($start, $end, $fh) = ($self->tell('start'), $self->tell('end'), $self->_fh);
    CORE::seek($fh,$start, 0);
    my $chunk; 
    read($fh, $chunk, $end - $start);
    $chunk;
}

sub parent_stream {
    my $self = shift;
    return $self->{_parent_stream} = shift if @_;
    return $self->{_parent_stream};
}

sub spawn_stream {
    my ($self, %markers) = @_;
    my $spawn = $self->new(-stream => $self);
    if (%markers) {
        $spawn->_set_marker_pos($_, $markers{$_}) for keys %markers;
    }
    $spawn;
}

# need to do a little more investigation into ensuring this works as advertised...
sub DESTROY {
    my $self = shift;
    # if in parent stream...
    if (!defined ($self->parent_stream)) {
        close $self->_fh unless $self->_fh->isa('IO::String');
    }
}

1;

__END__

=head1 NAME

Bio::Stream::IO - <One-line description of module's purpose>

=head1 VERSION

This documentation refers to Bio::Stream::GenericStreamI version .

=head1 SYNOPSIS

   use Bio::Stream::GenericStreamI;
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
