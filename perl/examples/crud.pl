#!/usr/bin/perl
#
#   Create-Retrieve-Update-Delete example
#
use RestMS ();
my $domain = RestMS::Domain->new (hostname => "localhost:8080");
$domain->verbose (1);
my $pipe = $domain->pipe ();
$pipe->read;
$pipe->title ("Example pipe");
$pipe->update;
$pipe->delete;
