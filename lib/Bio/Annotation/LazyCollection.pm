package Bio::Annotation::LazyCollection;

use strict;

# Object preamble - inherits from Bio::Root::Root

use Bio::Annotation::TypeManager;
use Bio::Annotation::SimpleValue;

use base qw(Bio::Root::Root
Bio::AnnotationCollectionI
Bio::AnnotationI
Bio::Stream::CollectionI
Bio::Stream::GenericStreamI);

sub new{
   my ($class,@args) = @_;
   
   my $self = $class->SUPER::new(@args);
   
   #my ($handler) = $self->_rearrange([qw(HANDLER)], @args);
   
   #$self->{'_annotation'} = {};
   #$self->_typemap(Bio::Annotation::TypeManager->new());
   #
   #return $self;
}

sub add_stream {
    my ($self, $stream) = @_;
    return unless $stream;
    $self->throw('Must implement Bio::Stream::GenericStreamI') unless $stream->isa('Bio::Stream::GenericStreamI');
    push @{$self->{streams}}, $stream;
    1;
}

sub remove_streams {
    my ($self) = @_;
    my $streams = $self->{streams};
    $self->{streams} = [];
    $streams;
}

sub next_dataset {
    my $self = shift;
    my $ds;
    for my $stream (@{$self->{streams}}) {
        $ds = $stream->next_dataset;
        next unless defined $ds;
    }
    $ds;
}

sub reset_stream {
    my $self = shift;
    for my $stream (@{$self->{streams}}) {
        $ds = $stream->next_dataset;
        next unless defined $ds;
    }
}

# alias
*reset_streams = \&reset_stream;

sub pull_dataset {
    
}

sub get_all_annotation_keys{
    shift->throw_not_implemented;
}

sub get_Annotations{
    shift->throw_not_implemented;
}

sub get_nested_Annotations {
    shift->throw_not_implemented;
}

sub get_all_Annotations{
    shift->throw_not_implemented;
}

sub get_num_of_annotations{
   shift->throw_not_implemented;
}

sub add_Annotation{
   shift->throw_not_implemented;
}

sub remove_Annotations{
    shift->throw_not_implemented;
}

sub flatten_Annotations{
    shift->throw_not_implemented;
}

sub as_text{
    shift->throw_not_implemented;
}

{
   # this just calls the default display_text output for
   # any AnnotationI
    my $DEFAULT_CB = sub {};

    sub display_text {
      shift->throw_not_implemented;
    }
}

sub hash_tree{
    shift->throw_not_implemented;
}

sub tagname{
    shift->throw_not_implemented;
}

1;

__END__

=head1 NAME

Bio::Annotation::LazyCollection - <One-line description of module's purpose>

=head1 VERSION

This documentation refers to Bio::Annotation::LazyCollection version .

=head1 SYNOPSIS

   use Bio::Annotation::LazyCollection;
   # Brief but working code example(s) here showing the most common usage(s)

   # This section will be as far as many users bother reading,

   # so make it as educational and exemplary as possible.

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 new

 Title   : new
 Usage   : $coll = Bio::Annotation::Collection->new()
 Function: Makes a new Annotation::Collection object. 
 Returns : Bio::Annotation::Collection
 Args    : none

=head1 L<Bio::AnnotationCollectionI> implementing methods

=head2 get_all_annotation_keys

 Title   : get_all_annotation_keys
 Usage   : $ac->get_all_annotation_keys()
 Function: gives back a list of annotation keys, which are simple text strings
 Returns : list of strings
 Args    : none

=head2 get_Annotations

 Title   : get_Annotations
 Usage   : my @annotations = $collection->get_Annotations('key')
 Function: Retrieves all the Bio::AnnotationI objects for one or more
           specific key(s).

           If no key is given, returns all annotation objects.

           The returned objects will have their tagname() attribute set to
           the key under which they were attached, unless the tagname was
           already set.

 Returns : list of Bio::AnnotationI - empty if no objects stored for a key
 Args    : keys (list of strings) for annotations (optional)

=head2 get_nested_Annotations

 Title   : get_nested_Annotations
 Usage   : my @annotations = $collection->get_nested_Annotations(
                                '-key' => \@keys,
                                '-recursive => 1);
 Function: Retrieves all the Bio::AnnotationI objects for one or more
           specific key(s). If -recursive is set to true, traverses the nested 
           annotation collections recursively and returns all annotations 
           matching the key(s).

           If no key is given, returns all annotation objects.

           The returned objects will have their tagname() attribute set to
           the key under which they were attached, unless the tagname was
           already set.

 Returns : list of Bio::AnnotationI - empty if no objects stored for a key
 Args    : -keys      => arrayref of keys to search for (optional)
           -recursive => boolean, whether or not to recursively traverse the 
            nested annotations and return annotations with matching keys.

=head2 get_all_Annotations

 Title   : get_all_Annotations
 Usage   :
 Function: Similar to get_Annotations, but traverses and flattens nested
           annotation collections. This means that collections in the
           tree will be replaced by their components.

           Keys will not be passed on to nested collections. I.e., if the
           tag name of a nested collection matches the key, it will be
           flattened in its entirety.

           Hence, for un-nested annotation collections this will be identical
           to get_Annotations.
 Example :
 Returns : an array of L<Bio::AnnotationI> compliant objects
 Args    : keys (list of strings) for annotations (optional)

=head2 get_num_of_annotations

 Title   : get_num_of_annotations
 Usage   : my $count = $collection->get_num_of_annotations()
 Function: Returns the count of all annotations stored in this collection 
 Returns : integer
 Args    : none

=head1 Implementation specific functions - mainly for adding

=head2 add_Annotation

 Title   : add_Annotation
 Usage   : $self->add_Annotation('reference',$object);
           $self->add_Annotation($object,'Bio::MyInterface::DiseaseI');
           $self->add_Annotation($object);
           $self->add_Annotation('disease',$object,'Bio::MyInterface::DiseaseI');
 Function: Adds an annotation for a specific key.

           If the key is omitted, the object to be added must provide a value
           via its tagname().

           If the archetype is provided, this and future objects added under
           that tag have to comply with the archetype and will be rejected
           otherwise.

 Returns : none
 Args    : annotation key ('disease', 'dblink', ...)
           object to store (must be Bio::AnnotationI compliant)
           [optional] object archetype to map future storage of object 
                      of these types to

=head2 remove_Annotations

 Title   : remove_Annotations
 Usage   :
 Function: Remove the annotations for the specified key from this collection.
 Example :
 Returns : an array Bio::AnnotationI compliant objects which were stored
           under the given key(s)
 Args    : the key(s) (tag name(s), one or more strings) for which to
           remove annotations (optional; if none given, flushes all
           annotations)

=head2 flatten_Annotations

 Title   : flatten_Annotations
 Usage   :
 Function: Flattens part or all of the annotations in this collection.

           This is a convenience method for getting the flattened
           annotation for the given keys, removing the annotation for
           those keys, and adding back the flattened array.

           This should not change anything for un-nested collections.
 Example :
 Returns : an array Bio::AnnotationI compliant objects which were stored
           under the given key(s)
 Args    : list of keys (strings) the annotation for which to flatten,
           defaults to all keys if not given

=head1 Bio::AnnotationI methods implementations

   This is to allow nested annotation: you can use a collection as an
   annotation object for an annotation collection.

=head2 as_text

 Title   : as_text
 Usage   :
 Function: See L<Bio::AnnotationI>
 Example :
 Returns : a string
 Args    : none

=head2 display_text

 Title   : display_text
 Usage   : my $str = $ann->display_text();
 Function: returns a string. Unlike as_text(), this method returns a string
           formatted as would be expected for te specific implementation.

           One can pass a callback as an argument which allows custom text
           generation; the callback is passed the current instance and any text
           returned
 Example :
 Returns : a string
 Args    : [optional] callback

=head2 hash_tree

 Title   : hash_tree
 Usage   :
 Function: See L<Bio::AnnotationI>
 Example :
 Returns : a hash reference
 Args    : none

=head2 tagname

 Title   : tagname
 Usage   : $obj->tagname($newval)
 Function: Get/set the tagname for this annotation value.

           Setting this is optional. If set, it obviates the need to
           provide a tag to Bio::AnnotationCollectionI when adding
           this object. When obtaining an AnnotationI object from the
           collection, the collection will set the value to the tag
           under which it was stored unless the object has a tag
           stored already.

 Example : 
 Returns : value of tagname (a scalar)
 Args    : new value (a scalar, optional)

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
