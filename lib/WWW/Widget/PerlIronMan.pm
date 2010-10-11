package WWW::Widget::PerlIronMan;

use strict;
use warnings;

use Moose;


with 'WWW::Widget';

has id => (
    is       => 'ro',
    required => 1,
);

has gender => (
    is      => 'ro',
    default => 'male',
);

sub as_html {
    my $self = shift;

    Template::Declare->init(
        dispatch_to => ['WWW::Widget::PerlIronMan::Template'] );
    return Template::Declare->show( 'widget', $self );
}

no Moose;

package WWW::Widget::PerlIronMan::Template;

use parent 'Template::Declare';

use Template::Declare::Tags;

template widget => sub {
    my $self   = shift;
    my $widget = shift;

    my $id     = $widget->id;
    my $gender = $widget->gender;

    div {
        class is 'title';
        a {
            href is 'http://ironman.enlightenedperl.org/';
            'Perl Iron Man Challenge';
        }
    };

    div {
        align is 'center';
        img {
            src is
              "http://ironman.enlightenedperl.org/munger/mybadge/$gender/${id}.png";
        };
    }

};

1;
