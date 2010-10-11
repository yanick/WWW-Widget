package WWW::Widget::Twitter;

use strict;
use warnings;

use Moose;

with 'WWW::Widget';

has username => (
    is       => 'ro',
    required => 1,
);

sub as_html {
    my $self = shift;

    ( my $html = do { local $/ = <DATA> } ) =~ s/%USERNAME%/$self->username/ge;

    return $html;
}

1;

__DATA__
<script src="http://widgets.twimg.com/j/2/widget.js"></script>
<script>
new TWTR.Widget({
  version: 2,
  type: 'profile',
  rpp: 4,
  interval: 6000,
  width: 190,
  height: 300,
  theme: {
    shell: {
      background: '#333333',
      color: '#ffffff'
    },
    tweets: {
      background: '#000000',
      color: '#ffffff',
      links: '#4aed05'
    }
  },
  features: {
    scrollbar: true,
    loop: false,
    live: false,
    hashtags: true,
    timestamp: true,
    avatars: false,
    behavior: 'all'
  }
}).render().setUser('%USERNAME%').start();
</script>
