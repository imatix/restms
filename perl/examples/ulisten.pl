#!/usr/bin/perl
#
#   uListen app, writes a line of text to the ublog feed
#   perl ulisten.pl
#
#   (c) 2009 iMatix, may be freely used in any way desired
#   with no conditions or restrictions.
#
use RestMS ();
my $hostname = (shift or "live.zyre.com");
my $domain = RestMS::Domain->new (hostname => $hostname, verbose => 0);
my $feed = $domain->feed (name => "ublog", type => "fanout");
my $pipe = $domain->pipe (cached => 1);
my $join = $feed->join (pipe => $pipe);

#   Now listen and print whatever people say
while (1) {
    $message = $pipe->recv;
    $pipe->carp ($message->headers (name).":".$message->content);
}
