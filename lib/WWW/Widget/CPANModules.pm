package WWW::Widget::CPANModules;

use strict;
use warnings;

use LWP::Simple;
use pQuery;
use DateTime::Format::Flexible;

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

    my $page = get $self->author_cpan_url;

    my $dists = pQuery($page)->find('table:eq(1) tr');

    my @dists;

    $dists->each(
        sub {
            return unless shift;    # first one is headers

            my $row  = pQuery($_);
            my $name = $row->find('td:eq(0) a')->text();

            $name =~ s/-v?([\d._]*)$//;    # remove version

            my $version = $1;

            my $url = "http://search.cpan.org/dist/$name";

            $name =~ s/-/::/g;

            my $desc = $row->find('td:eq(1)')->text();
            my $date = DateTime::Format::Flexible->parse_datetime(
                $row->find('td:eq(3)')->text );

            push @dists,
              { name    => $name,
                url     => $url,
                desc    => $desc,
                date    => $date,
                version => $version,
              };
        } );

    return @dists;
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
        div { class is 'version';      $dist->{version} }
        div { class is 'release_date'; $dist->{date}->strftime('%b %e, %Y') };
    }
};

1;
