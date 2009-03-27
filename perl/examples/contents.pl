#
#   Demonstrates different ways of sending message contents
#   perl contents.pl
#
#   (c) 2009 iMatix, may be freely used in any way desired
#   with no conditions or restrictions.
#
use RestMS ();
my $hostname = (shift or "live.zyre.com");
my $domain = RestMS::Domain->new (hostname => $hostname, verbose => 0);

#   We'll send the messages to ourselves using Housecat
#   - we create a pipe and use its name as the address
#   - we send our messages to the default feed
my $default = $domain->feed (name => "default");
my $pipe = $domain->pipe ();

#   Send a message with no content
my $out = RestMS::Message->new;
$out->send ($default, address => $pipe->name);
my $in = $pipe->recv;
length ($in->content) == 0 || die "test failed - content is not empty\n";

#   Send a message with separate content
$out->content ("This is a string");
$out->content_type ("text/plain");
$out->send ($default, address => $pipe->name);
$in = $pipe->recv;
$in->content eq "This is a string" || die "test failed - content is not a string\n";

#   Send a message with embedded plain content
$out->content ("A plain string");
$out->content_type ("text/plain");
$out->encoding ("plain");
$out->send ($default, address => $pipe->name);
$in = $pipe->recv;
$in->content eq "A plain string" || die "test failed - content is not plain\n";

#   Send a message with embedded Base64 content
$out->content ("A base64 string");
$out->content_type ("text/plain");
$out->encoding ("base64");
$out->send ($default, address => $pipe->name);
$in = $pipe->recv;
$in->content eq "A base64 string" || die "test failed - content is not basic64\n";

#   Cleanup
$pipe->delete;
