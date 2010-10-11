use strict;
use warnings;

use Test::More tests => 7;                      # last test to print

use WWW::Widget::PerlIronMan;

my $widget = WWW::Widget::PerlIronMan->new( id => 'yanick' );

my $html = $widget->as_html;

ok $html, 'as_html() is working';

is $html => $widget, "string overloading";

like $html, qr#/male/#, 'male avatar';

like $html, qr#^<div\s+class=(['"])(.*?)\1\s*>.*</div>\s*$#sm, "wrapped in <div>";

$html =~ qr#^<div\s+class=(['"])(.*?)\1\s*>.*</div>\s*$#sm;
my @classes = split ' ', $2;

is @classes => 2, 'two classes';

is $classes[0] =>  'WWW-Widget';
is $classes[1] => 'WWW-Widget-PerlIronMan';



