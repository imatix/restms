#
#   fortune_cli app, implements a Fortune cookie client.
#   perl fortune_cli.pl
#
#   (c) 2009 iMatix, may be freely used in any way desired
#   with no conditions or restrictions.
#
use RestMS ();
my $hostname = shift;
$hostname = "live.zyre.com" unless $hostname;
my $domain = RestMS::Domain->new (hostname => $hostname);
$domain->verbose (1);

#   Grab a reference to the 'default' feed, so we can get our replies
my $default = $domain->feed (name => "default");

#   Create an unnamed pipe and bind it to the default feed
my $pipe = $domain->pipe ();
my $join = $pipe->join (feed => $default);

#   Grab a reference to the 'fortune' feed
my $fortune = $domain->feed (name => "fortune", type => "service");

#   Send a request to the fortune feed
my $request = RestMS::Message->new;
$request->send ($fortune, $reply_to => $pipe->name);

#   Wait for the response, and print it
my $response = $pipe->recv;
print $response->content;

#   Free up the pipe, which we no longer need
$pipe->delete;
