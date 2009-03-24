#!/usr/bin/perl
#
#   uSpeak app, writes a line of text to the ublog feed
#   perl uspeak.pl "some line of text"
#
#   (c) 2009 iMatix, may be freely used in any way desired
#   with no conditions or restrictions.
#
use RestMS ();
my $hostname = (shift or "live.zyre.com");
my $domain = RestMS::Domain->new (hostname => $hostname, verbose => 0);
my $feed = $domain->feed (name => "ublog", type => "fanout");
my $message = RestMS::Message->new;
$message->content (shift);
$message->headers (name => "Jeep Nine Thirst");
$feed->send ($message);
