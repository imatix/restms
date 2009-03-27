#
#   news_pub application, implements newsfeed publisher
#   perl news_pub.pl
#
#   (c) 2009 iMatix, may be freely used in any way desired
#   with no conditions or restrictions.
#
use RestMS ();
my $hostname = (shift or "live.zyre.com");
my $domain = RestMS::Domain->new (hostname => $hostname, verbose => 0);

#   Create a topic feed called 'news'
my $newsfeed = $domain->feed (name => "news", type => "topic");
my $message = RestMS::Message->new;

#   Create a message with embedded plain content
$message->content_type ("text/plain");
$message->encoding ("plain");

#   Now send our articles to the news feed
$message->content ("Montreal: Canine Championship series opens");
$message->send ($newsfeed, address => "rec.pets.dogs");
$message->content ("The oil shock: does it affect you?");
$message->send ($newsfeed, address => "rec.cars");
$message->content ("Steroids: the ugly truth from Montreal");
$message->send ($newsfeed, address => "rec.pets.dogs");
$message->content ("Cat vs. dog: facts or fictions?");
$message->send ($newsfeed, address => "rec.pets.cats");
$message->content ("Montreal in chaos: winner is a cat!");
$message->send ($newsfeed, address => "rec.pets.dogs");
$message->content ("Red, white, or blue: what it says about you");
$message->send ($newsfeed, address => "rec.cars");
$message->content ("Parking - who, where, why: a new survey");
$message->send ($newsfeed, address => "rec.cars");
$message->content ("Superiority: it comes naturally");
$message->send ($newsfeed, address => "rec.pets.cats");
