#!/usr/bin/perl
#
#   Hello World application for RestMS
#
use RestMS ();
my $hostname = (shift or "live.zyre.com");
my $domain = RestMS::Domain->new (hostname => $hostname, verbose => 1);
my $feed = $domain->feed (name => "ping", type => "fanout");
my $pipe = $domain->pipe ();
my $join = $feed->join (pipe => $pipe);
my $message = RestMS::Message->new;
$message->content ("Hello World");
$feed->send ($message);
$message = $pipe->recv;
print $message->content."\n";
