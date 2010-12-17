package WWW::Widget::CPANModules;

use strict;
use warnings;

use LWP::Simple;
use pQuery;
use DateTime::Format::Flexible;
use JSON;

use Moose;

with 'WWW::Widget';

has author_id => (
    is       => 'ro',
    required => 1,
);

sub author_cpan_url {
    my $self = shift;

    return 'http://search.cpan.org/~' . $self->author_id;
}

sub as_html {
    my $self = shift;

    Template::Declare->init(
        dispatch_to => ['WWW::Widget::CPANModules::Template'] );
    return Template::Declare->show(
        'widget',
        author_cpan_url => $self->author_cpan_url,
        distributions   => [
            reverse sort { DateTime->compare( $a->{date}, $b->{date} ) }
              $self->distributions
        ],
    );
}

sub distributions {
    my $self = shift;

    my $page =
      get sprintf 'http://api.metacpan.org/dist/_search?q=author:"%s"',
      $self->author_id;

    my $json = from_json($page);

    return map { {
            name    => $_->{name},
            version => $_->{version},
            url     => 'http://search.cpan.org/dist/' . $_->{name},
            date    => DateTime::Format::Flexible->parse_datetime(
                $_->{release_date}
            ),
        }
      }
      map { $_->{_source} } @{ $json->{hits}{hits} };

}

no Moose;

package WWW::Widget::CPANModules::Template;

use parent 'Template::Declare';

use Template::Declare::Tags;

template widget => sub {
    my $self = shift;
    my %arg  = @_;

    div {
        class is 'title';
        a {
            href is $arg{author_cpan_url};
            'CPAN Modules';
        }
    };

    show( 'distribution', dist => $_ ) for @{ $arg{distributions} };
};

template distribution => sub {
    my $self = shift;
    my %arg  = @_;
    my $dist = $arg{dist};

    div {
        class is 'distribution';
        div {
            class is 'name';
            a {
                href is $dist->{url};
                $dist->{name};
            }
        }
        div {
            class is 'version';
            $dist->{version};
        }
        div {
            class is 'release_date';
            $dist->{date}->strftime('%b %e, %Y');
        };
    }
};

1;
