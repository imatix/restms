#
#   news_sub application, implements newsfeed subscriber
#   perl news_sub.pl
#
#   (c) 2009 iMatix, may be freely used in any way desired
#   with no conditions or restrictions.
#
use RestMS ();
my $hostname = (shift or "live.zyre.com");
my $domain = RestMS::Domain->new (hostname => $hostname, verbose => 0);

#   Grab reference to topic feed called 'news'
my $newsfeed = $domain->feed (name => "news", type => "topic");
my $pipe = $domain->pipe ();
my $join = $pipe->join (feed => $newsfeed, address => "rec.pets.*");

#   Receive and print messages
while (1) {
    my $message = $pipe->recv;
    $message->carp ($message->address.": ".$message->content);
}
