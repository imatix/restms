#!/usr/bin/perl
#
#   Hello World application for RestMS
#
use RestMS ();
my $domain = RestMS::Domain->new (hostname => "live.zyre.com");
$domain->verbose (1);
my $feed = $domain->feed (name => "ping", type => "fanout");
my $pipe = $domain->pipe ();
my $join = $feed->join (pipe => $pipe);
my $message = RestMS::Message->new;
$message->content ("Hello World");
$feed->send ($message);
$message = $pipe->recv;
print $message->content."\n";
