#############################################################################
#   RestMS::Pipe class
#
package RestMS::Pipe;
our @ISA = qw(RestMS::Base);
use Alias qw(attr);
use vars qw($NAME $DOMAIN $TYPE $TITLE $MESSAGES);

#   my $pipe = RestMS::Pipe->new ($domain, name => "whatever", type = "fifo",...)
#   If name is specified, looks for existing pipe with name
#
sub new {
    my $proto = shift;
    my $class = (ref ($proto) or $proto);
    my $domain = shift or RestMS::Pipe->croak ("RestMS::Pipe->new() needs a domain argument");
    my %argv = (
        name => undef,
        type => "fifo",
        title => undef,
        expect => undef,
        @_
    );
    my $self = $class->SUPER::new (hostname => $domain->hostname, @_);
    bless ($self, $class);

    #   Set pipe properties as specified
    $self->{NAME}     = $argv {name};
    $self->{DOMAIN}   = $domain;
    $self->{TYPE}     = $argv {type};
    $self->{TITLE}    = $argv {title};
    $self->{MESSAGES} = [];             #   Reference to array

    #   Create pipe on server
    $self->create;
    return $self;
}

#   Get/set properties
sub name {
    my $self = attr shift;
    return $NAME;
}
sub domain {
    my $self = attr shift;
    return $DOMAIN;
}
sub type {
    my $self = attr shift;
    return $TYPE;
}
sub title {
    my $self = attr shift;
    $TITLE = shift if (@_);
    return $TITLE;
}

#   Create pipe on server
#   my $code = $pipe->create
#
sub create {
    my $self = attr shift;

    #   If we're doing pipe caching, check if pipe still exists
    if ($NAME) {
$self->carp ("CACHED: $NAME");
        $URI = "http://$HOSTNAME/restms/resource/$NAME";
        $request = HTTP::Request->new (GET => $URI);
        $request->header (Accept => $mimetype);
        $response = $ua->request ($request);
        if ($self->code == 200) {
            #   Pipe still exists, which is great
            $self->parse ($self->body);
            return ($self->code);
        }
    }
    #   Create new pipe, ignore requested name
    $URI = $DOMAIN->post (document => $self->document);
    if ($URI) {
        $self->parse ($DOMAIN->body);
    }
    else {
        $DOMAIN->trace_request (verbose => 1);
        $DOMAIN->croak ("'Location:' missing after POST pipe to domain");
    }
    return ($DOMAIN->code);
}

#   Pipe specification document
#   print $pipe->document;
#
sub document {
    my $self = attr shift;
    return <<EOF;
<?xml version="1.0"?>
<restms xmlns="http://www.imatix.com/schema/restms">
  <pipe type="$TYPE" name="$NAME" title="$TITLE" />
</restms>
EOF
}

#   Fetches pipe from server, using pipe URI
#   my $code = $pipe->read (expect => undef);
#
sub read {
    my $self = attr shift;
    if ($self->SUPER::read (@_) == 200) {
        $self->parse ($self->body);
    }
    return $self->code;
}

#   Parses document returned from server
#   $pipe->parse ($domain->body);
#
sub parse {
    my $self = attr shift;
    my $content = shift or $self->croak ("parse() requires argument");
    my $restms = XML::Simple::XMLin ($content, forcearray => ['message']);
    #   Always use the @{} form to copy an array out of the parsed XML
    @MESSAGES = @{$restms->{pipe}{message}};
    $NAME = $restms->{pipe}{name};
    $TYPE = $restms->{pipe}{type};
    $TITLE = $restms->{pipe}{title};
}

#   Create new join on pipe
#   my $join = $pipe->join (feed => $feed, address => "*", expect => undef);
#
sub join {
    my $self = attr shift;
    $join = RestMS::Join->new (pipe => $self, @_);
    $join->verbose ($self->verbose);
    return $join;
}

#   Receive message from pipe
#   my $message = $pipe->recv;
#
sub recv {
    my $self = attr shift;

    #   If pipe has no more messages, fetch it again
    $self->read if (scalar (@MESSAGES) == 0);
    $self->croak ("broken pipe") if (scalar (@MESSAGES) == 0);
    my $message_item = shift (@MESSAGES);
    my $message = RestMS::Message->new (hostname => $self->hostname);
    $message->timeout ($self->timeout);
    $message->verbose ($self->verbose);
    if ($message->read ($message_item->{href}) == 500) {
        return undef;
    }
    else {
        #   Remove message from server
        $message->delete;
        return $message;
    }
}

#   Test dynamic pipe
#   $pipe->selftest;
#
sub selftest {
    my $self = attr shift;
    my %argv = (
        verbose => undef,
        @_
    );
    $self->verbose ($argv {verbose}) if $argv {verbose};
    $self->carp ("Running pipe tests (".$self->type.")...");

    $self->title ("title");
    $self->update;
    $self->read;
    $self->croak ("Failed piprop") if $self->title ne "title";

    $self->delete;
    $self->read (expect => 404);
    $self->update (expect => 404);
    $self->delete;

    $self->create;
    $self->read;
    $self->croak ("Failed piredo") if $self->title ne "title";
    $self->update;

    #   Test join from pipe to default feed
    my $feed = RestMS::Feed->new ($self->domain, name => "test.feed");
    $feed->verbose ($self->verbose);
    my $join = $self->join (feed => $feed, address => "*");
    $join->verbose ($self->verbose);
    $join->selftest;

    $self->delete;
}

1;
