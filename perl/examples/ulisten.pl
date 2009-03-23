#!/usr/bin/perl
#
#   uListen app, writes a line of text to the ublog feed
#   perl ulisten.pl
#
#   (c) 2009 iMatix, may be freely used in any way desired
#   with no conditions or restrictions.
#
use RestMS ();
my $domain = RestMS::Domain->new (hostname => "localhost:8080");
my $feed = $domain->feed (name => "ublog", type => "fanout");
#   Create pipe and join it to the ublog feed
my $pipe = $domain->pipe ();
my $join = $feed->join (pipe => $pipe);

#   Now listen and print whatever people say
while (1) {
    $message = $pipe->recv;
    $pipe->carp ($message->headers (name).":".$message->content);
}
