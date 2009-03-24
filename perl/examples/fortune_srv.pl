#
#   fortune_srv app, implements a Fortune cookie server.
#   perl fortune_srv.pl
#
#   (c) 2009 iMatix, may be freely used in any way desired
#   with no conditions or restrictions.
#
use RestMS ();
my $hostname = (shift or "live.zyre.com");
my $domain = RestMS::Domain->new (hostname => $hostname, verbose => 0);

#   Create a feed called 'fortune' for clients to send requests to
my $fortune = $domain->feed (name => "fortune", type => "service");

#   Create an unnamed pipe and bind it to the feed
my $pipe = $domain->pipe (cached => 1);
my $join = $pipe->join (feed => $fortune);

#   Grab a reference to the default feed, to send replies to
my $default = $domain->feed (name => "default");

$default->carp ("Fortune cookie service initialized OK");

#   Now loop forever, processing requests
while (1) {
    #   See how we don't poll - this will wait until a message arrives
    my $request = $pipe->recv;

    #   Create a new response message
    my $response = RestMS::Message->new;

    #   Grab a fortune via the shell (hopefully fortune is on path)
    $response->content (`fortune`);
    $response->content_type ("text/plain");

    #   Send the response back via the direct feed
    #   We use the reply-to address provided in the request
    $response->send ($default, address => $request->reply_to);
}
