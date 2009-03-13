#############################################################################
#   RestMS::Base class
#
package RestMS::Base;
use Alias qw(attr);
#   Internal use only
use vars qw($myclass $ua $request $response $mimetype);
#   Exported via methods
use vars qw($HOSTNAME $URI $VERBOSE $DATETIME);

#   Base constructor
#   $resource = RestMS::Base->new (hostname => "localhost");
#
sub new {
    my $proto = attr shift;
    my $class = (ref ($proto) or $proto);
    my %argv = (
        hostname => undef,
        @_
    );
    my $self = {
        myclass  => $class,
        ua       => new LWP::UserAgent,
        request  => undef,
        response => undef,
        mimetype => "application/restms+xml",
        HOSTNAME => undef,
        URI      => undef,
        VERBOSE  => 0,
        DATETIME => 0,
    };
    bless ($self, $class);
    $self->hostname ($argv {hostname});
    return $self;
}

#   Get/set hostname
#   print $resource->hostname;
#
sub hostname {
    my $self = attr shift;
    if (@_) {
        $HOSTNAME = shift;
        $ua->credentials ($HOSTNAME, "RestMS::", "guest", "guest");
    }
    return $HOSTNAME;
}

#   Get resource URI
#   print $resource->uri;
#
sub uri {
    my $self = attr shift;
    return $URI;
}

#   Enables/disables verbose tracing
#   $resource->verbose (0|1);
#   print $resource->verbose;
#
sub verbose {
    my $self = attr shift;
    $VERBOSE = shift if (@_);
    return $VERBOSE;
}

#   Enables/disables date/time tracing
#   $resource->datetime (0|1);
#   print $resource->datetime;
#
sub datetime {
    my $self = attr shift;
    $DATETIME = shift if (@_);
    return $DATETIME;
}

#   Get/set connection timeout, in seconds
#   $resource->timeout (seconds);
#   print $resource->timeout;
#
sub timeout {
    my $self = attr shift;
    $ua->timeout (shift) if (@_);
    return $ua->timeout;
}

#   Resource specification document
#   print $resource->document;
#
sub document {
    my $self = attr shift;
    return <<EOF;
<?xml version="1.0"?>
<restms xmlns="http://www.imatix.com/schema/restms">
</restms>
EOF
}

#   Fetches resource from server, using resource URI
#   my $code = $resource->read (expect => undef);
#
sub read {
    my $self = attr shift;
    my %argv = (
        expect => undef,
        @_
    );
    $request = HTTP::Request->new (GET => $URI);
    $request->header (Accept => $mimetype);
    $response = $ua->request ($request);
    $self->trace;
    #   500 can be treated as a timeout
    $self->assert ($argv {expect}) unless ($self->code == 500);
    return $self->code;
}

#   Updates resource on server using resource URI
#   my $code = $resource->update (expect => undef);
#
sub update {
    my $self = attr shift;
    my %argv = (
        expect => undef,
        @_
    );
    $request = HTTP::Request->new (PUT => $URI);
    $request->content ($self->document);
    $request->content_type ($mimetype);
    $response = $ua->request ($request);
    $self->trace;
    $self->assert ($argv {expect});
    return $self->code;
}

#   Fetches resource from server, using resource URI
#   my $code = $resource->delete (expect => undef);
#
sub delete {
    my $self = attr shift;
    my %argv = (
        expect => undef,
        @_
    );
    $request = HTTP::Request->new (DELETE => $URI);
    $response = $ua->request ($request);
    $self->trace;
    $self->assert ($argv {expect});
    return $self->code;
}

#   Posts document to server, using resource URI
#   my $location = $resource->post (document => xmlstring, expect => undef);
#
sub post {
    my $self = attr shift;
    my %argv = (
        document => undef,
        document_type => $mimetype,
        expect => undef,
        @_
    );
    $request = HTTP::Request->new (POST => $URI);
    $request->content ($argv {document});
    $request->content_type ($argv {document_type});
    $response = $ua->request ($request);
    $self->trace;
    $self->assert ($arg {expect});
    return $response->header ("Location");
}

#   Issue message with date/time stamp
#   $resource->carp ("Life is tough");
#
sub carp {
    my $self = attr shift;
    my $string = shift;
    if ($DATETIME) {
        ($sec, $min, $hour, $day, $month, $year) = localtime;
        $date = sprintf ("%04d-%02d-%02d", $year + 1900, $month + 1, $day);
        $time = sprintf ("%2d:%02d:%02d", $hour, $min, $sec);
        print "$date $time $string\n";
    }
    else {
        print "$string\n";
    }
}

#   Carp and die
#   $resource->croak ("and then you die");
#
sub croak {
    my $self = attr shift;
    my $string = (shift or "E: unspecified error");
    $self->carp ("$myclass: $string");
    exit (1);
}

#   Returns the reply code from the last HTTP request
#   print $resource->code;
#
sub code {
    my $self = attr shift;
    return $response->code;
}

#   Returns the response data from the last HTTP request
#   print $resource->body
#
sub body {
    my $self = attr shift;
    return $response->content;
}

#   Trace the request and response, if verbose
#   $resource->trace;
#
sub trace {
    my $self = attr shift;
    my %argv = (
        verbose => undef,
        @_
    );
    $VERBOSE = $argv {verbose} if $argv {verbose};
   if ($VERBOSE) {
        $self->carp ("\nClient:");
        $self->carp ("-------------------------------------------------");
        my $headers = $request->headers_as_string;
        $self->carp ($request->method . " " . $request->uri);
        $self->carp ($headers);
        $self->carp ($request->content) if $request->content;

        $self->carp ("Server:");
        $self->carp ("-------------------------------------------------");
        $self->carp ("HTTP/1.1 " . $response->status_line);
        my $headers = $response->headers_as_string;
        $self->carp ($headers);
        $self->carp ($response->content) if $response->content;
    }
}

#   Assert expected return code, croak if it's wrong
#   $resource->assert (expect);
#
sub assert {
    my $self = attr shift;
    my $expect = shift;

    if (($expect and $self->code != $expect)
    or (!$expect and $self->code >= 300)) {
        $self->carp ("$myclass: E: " . $request->method . " " . $request->uri);
        if ($expect) {
            $self->carp (
                "Expected $expect, got ".
                    $response->status_line .": \"".
                    $response->content ."\"");
        }
        exit (1);
    }
}

1;
