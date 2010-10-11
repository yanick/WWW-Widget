package WWW::Widget;
# ABSTRACT: Blog-agnostic widget framework

=head1 SYNOPSIS

    my $widget = WWW::Widget::SomeWidget->new( %conf );
    
    print $widget->as_html;

=head1 DESCRIPTION

C<WWW::Widget> is a minimalistic role which aim to make the 
sharing of widget code easier between blog engines.

The idea is dead simple: the widget gets all its configuration
at creation time. E.g.,

    my $widget = WWW::Widget::PerlIronMan->new( id => 'yanick' );

And when it's time to spit out the widget on the web page, invoke
the C<as_html> method:

    print $widget->as_html


=head1 EXAMPLE WITH CATALYST AND MASON

Say that your application is using L<Catalyst> with L<Mason> as its templating
system.  Your configuration file could look like this

    <widgets>
        <PerlIronMan>
            id yanick
        </PerlIronMan>
        <Twitter>
            username yenzie
        </Twitter>
    </widgets>

and the mason bit that would generate all widgets like that

    % while ( my ( $widget, $conf ) = each %{ $c->config->{widgets} } ) {
    % my $package = 'WWW::Widget::'.$widget;
    % eval "use $package; 1" or next;
    % $conf ||= {};  # in case there's no configuration item
        <% $package->new( %$conf ) %>
    % }

=head1 WRITING WIDGETS

Widget classes that implement the C<WWW::Widget> role must be L<Moose>-based
and provide a C<as_html()> returning the HTML code for the widget as a string.

The HTML code returned by C<as_html()> must B<not> contain the wrapping
'<div>' element -- the wrapping is done by the role.

For styling, the wrapping '<div>' element is assigned two classes: C<WWW-Widget> and
C<WWW-Widget->I<SpecificWidgetClass>.  

As the widgets are meant to be 
blog-agnostic, it is recommended that the HTML produced be as 
generic as possible, leaving display considerations to the CSS.  

=cut

use strict;
use warnings;

use Moose::Role;

requires 'as_html';

around 'as_html' => sub {
    my ( $orig, $self, @args ) = @_;

    my @classes = ( __PACKAGE__, ref $self );
    s/::/-/g for @classes;

    return "<div class='@classes'>" . $orig->( $self, @args ) . '</div>';
};

# http://use.perl.org/~tokuhirom/journal/36582
__PACKAGE__->meta->add_package_symbol( '&()' => sub { } );    # dummy
__PACKAGE__->meta->add_package_symbol( '&(""' => sub { shift->as_html } );

1;
